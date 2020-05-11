function Sync-Guid {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $DontViewEntireForest,

        [Parameter(Mandatory)]
        [string]
        $DomainController
    )
    $Script:RestartConsole = $null
    Connect-CloudModuleImport -EXO2
    if ($RestartConsole) {
        return
    }
    Get-PSSession | Remove-PSSession
    while (-not $Server ) {
        Write-Host "Enter the name of the Exchange Server. Example: ExServer01.domain.com" -ForegroundColor Cyan
        $Server = Read-Host "Exchange Server Name"
    }
    Connect-Exchange @PSBoundParameters -PromptConfirm -Server $Server

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath ('RemoteMailboxSyncGuid_{0}.xml' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    Write-Host "Fetching Remote Mailboxes..." -ForegroundColor Cyan

    Get-RemoteMailbox -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
    $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OrganizationalUnit
    $RMHash = Get-RemoteMailboxHash -DomainController $DomainController -Key UserPrincipalName -RemoteMailboxList $RemoteMailboxList

    Get-PSSession | Remove-PSSession

    # Cloud ( Mailbox )
    Write-Host "`r`nEnter Exchange Online credentials`r`n" -ForegroundColor Cyan
    Connect-ExchangeOnline
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
    Write-Host "`r`nConnected to Exchange Online Tenant: $InitialDomain`r`n" -ForegroundColor Green
    $CloudHash = Get-CloudMailboxHash
    Get-PSSession | Remove-PSSession

    $CompareObject = Invoke-CompareGuid -RMHash $RMHash -CloudHash $CloudHash

    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    $SourceFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Compare_{0}_{1}.csv' -f $InitialDomain, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))

    if (-not ($null = Test-Path $SourcePath)) {
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item $PoshPath @ItemSplat
        $null = New-Item $SourcePath @ItemSplat
    }

    $CompareObject | Out-GridView -Title "Results of Guid Comparison to Tenant: $InitialDomain"
    $CompareObject | Export-Csv $SourceFile -NoTypeInformation

    $AddGuidListTrimmed = $CompareObject | Where-Object { -not $_.ExchangeGuidMatch -or -not $_.ArchiveGuidMatch } | Sort-Object DisplayName, OrganizationalUnit
    $AddGuidListNumbered = Invoke-CompareGuid -Numbered $AddGuidListTrimmed
    $AddGuidList = $AddGuidListNumbered | Out-GridView -OutputMode Multiple -Title 'Please choose which Remote Mailbox to modify to match Exchange Online'
    if ($AddGuidList) {
        Connect-Exchange @PSBoundParameters -Server $Server

        $GuidResult = Set-ExchangeGuid -AddGuidList $AddGuidList -RMHash $RMHash

        $GuidResult | Out-GridView -Title "Results of Adding Guid to Tenant: $InitialDomain"
        $ResultFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Result_{0}_{1}.csv' -f $InitialDomain, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
        $GuidResult | Export-Csv $ResultFile -NoTypeInformation
    }
    else {
        Write-Host "All ExchangeGuid and ArchiveGuid already match" -ForegroundColor Yellow -BackgroundColor Black
        return
    }
}
