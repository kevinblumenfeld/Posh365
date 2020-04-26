function Sync-Guid {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [switch]
        $DontViewEntireForest
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

    $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailboxSyncGuid.xml'
    Write-Host "Fetching Remote Mailboxes..." -ForegroundColor Cyan

    Get-RemoteMailbox -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
    $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OnPremisesOrganizationalUnit
    $RMHash = Get-RemoteMailboxHash -Key UserPrincipalName -RemoteMailboxList $RemoteMailboxList

    Get-PSSession | Remove-PSSession

    # Cloud ( Mailbox )
    Write-Host "`r`nEnter Exchange Online credentials`r`n" -ForegroundColor Cyan
    Connect-ExchangeOnline
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
    Write-Host "`r`nConnected to Exchange Online Tenant: $InitialDomain`r`n" -ForegroundColor Green
    $CloudHash = Get-CloudMailboxHash
    Get-PSSession | Remove-PSSession

    $CompareObject = Invoke-CompareGuid -RMHash $RMHash -CloudHash $CloudHash

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    $SourceFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Compare_{0}.csv' -f $InitialDomain)

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

    $AddGuidList = $CompareObject | Where-Object { -not $_.ExchangeGuidMatch -or -not $_.ArchiveGuidMatch }
    if ($AddGuidList) {
        Connect-Exchange @PSBoundParameters -PromptConfirm -Server $Server
        $GuidResult = Set-ExchangeGuid -AddGuidList $AddGuidList
        $GuidResult | Out-GridView -Title "Results of Adding Guid to Tenant: $InitialDomain"
        $ResultFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Result_{0}.csv' -f $InitialDomain)
        $GuidResult | Export-Csv $ResultFile -NoTypeInformation
    }
    else {
        Write-Host "All ExchangeGuid and ArchiveGuid already match" -ForegroundColor Yellow -BackgroundColor Black
        return
    }
}
