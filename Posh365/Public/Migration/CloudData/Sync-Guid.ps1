function Sync-Guid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    if ($DeleteExchangeCreds) {
        Connect-Exchange -DeleteExchangeCreds:$true
        break
    }

    if (((Get-Module -Name PowerShellGet -ListAvailable).Version.Major | Sort-Object -Descending)[0] -lt 2 ) {
        try {
            Install-Module -Name PowerShellGet -Scope CurrentUser -Force -ErrorAction Stop -AllowClobber
            Write-Warning "Exchange Online v.2 module requires PowerShellGet v.2"
            Write-Warning "PowerShellGet v.2 was just installed"
            Write-Warning "Please restart this PowerShell console and rerun the same command"
        }
        catch {
            Write-Warning "Unable to install the latest version of PowerShellGet"
            Write-Warning "and thus unable to install the Exchange Online v.2 module"
        }
        $Script:RestartConsole = $true
        return
    }
    if (-not ($null = Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
        $EXOInstall = @{
            Name          = 'ExchangeOnlineManagement'
            Scope         = 'CurrentUser'
            AllowClobber  = $true
            AcceptLicense = $true
            Force         = $true
        }
        Install-Module @EXOInstall
    }

    Get-PSSession | Remove-PSSession
    Connect-ExchangeOnline
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName

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

    $CompareResult = Invoke-CompareGuid -OnPremExchangeServer $OnPremExchangeServer -DontViewEntireForest:$DontViewEntireForest
    $CompareResult | Out-GridView -Title "Results of Guid Comparison to Tenant: $InitialDomain"
    $CompareResult | Export-Csv $SourceFile -NoTypeInformation

    $AddGuidList = $CompareResult | Where-Object { -not $_.MailboxGuidMatch }
    if ($AddGuidList) {
        $GuidResult = Set-ExchangeGuid -AddGuidList $AddGuidList -OnPremExchangeServer $OnPremExchangeServer -DontViewEntireForest:$DontViewEntireForest
        $GuidResult | Out-GridView -Title "Results of Adding Guid to Tenant: $InitialDomain"
        $ResultFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Result_{0}.csv' -f $InitialDomain)
        $GuidResult | Export-Csv $ResultFile -NoTypeInformation
    }
    else {
        Write-Host "No matching data was found to sync to $InitialDomain" -ForegroundColor Red
        continue
    }
}