using namespace System.Management.Automation.Host
function Sync-CloudData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited'
    )
    $Yes = [ChoiceDescription]::new('&Yes', 'Connect: Yes')
    $No = [ChoiceDescription]::new('&No', 'Connect: No')
    $Question = 'Connect to Exchange Online and AzureAD?' -f $InitialDomain
    $Options = [ChoiceDescription[]]($Yes, $No)
    $ConnectMenu = $host.ui.PromptForChoice($Title, $Question, $Options, 0)

    switch ($ConnectMenu) {
        0 {
            If (-not ($null = Get-Module -Name 'AzureAD', 'AzureADPreview' -ListAvailable)) {
                Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
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
            try { Disconnect-AzureAD -ErrorAction Stop } catch { }
            Connect-ExchangeOnline
            $null = Connect-AzureAD
        }
        1 { }
    }
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
    $AzADDomain = ((Get-AzureADDomain).where{ $_.IsInitial }).Name
    if ($InitialDomain -ne $AzADDomain) {
        Write-Host "Halting script: $InitialDomain does not match $AzADDomain" -ForegroundColor Red
        break
    }
    if ($InitialDomain) {
        $Yes = [ChoiceDescription]::new('&Yes', 'Source Domain: Yes')
        $No = [ChoiceDescription]::new('&No', 'Source Domain: No')
        $Question = 'Is this the source tenant {0}?' -f $InitialDomain
        $Options = [ChoiceDescription[]]($Yes, $No)
        $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

        switch ($Menu) {
            0 { }
            1 { break }
        }
    }
    else {
        Write-Host 'Not connected to Exchange Online' -ForegroundColor Red
        break
    }

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    $SourceFile = Join-Path -Path $SourcePath -ChildPath ('{0}.csv' -f $InitialDomain)

    if (-not ($null = Test-Path $SourcePath)) {
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item $PoshPath @ItemSplat
        $null = New-Item $SourcePath @ItemSplat
    }

    Write-Host ('{0}Connected to source: ' -f [Environment]::NewLine) -ForegroundColor Cyan -NoNewline
    Write-Host ('{0}{1}' -f $InitialDomain, [Environment]::NewLine) -ForegroundColor Green
    Write-Host 'Writing to: ' -ForegroundColor White -NoNewline
    Write-Host ('{0}{1}' -f $SourceFile, [Environment]::NewLine) -ForegroundColor Yellow

    $SourceData = Invoke-GetCloudData -ResultSize $ResultSize -InitialDomain $InitialDomain
    $SourceData | Export-Csv -Path $SourceFile -NoTypeInformation

    Write-Host ('Source objects converted for Target: {0} {1}' -f $SourceFile, [Environment]::NewLine) -ForegroundColor Green

    $Yes = [ChoiceDescription]::new('&Yes', 'Convert Cloud Data: Yes')
    $No = [ChoiceDescription]::new('&No', 'Convert Cloud Data: No')
    $Question = 'Convert data? (we only create a CSV in this step - we do not write to the tenent)'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 0)

    switch ($Menu) {
        0 {
            Write-Host ('Converting data...{0}' -f [Environment]::NewLine) -ForegroundColor Gray
            Disconnect-AzureAD
            Get-PSSession | Remove-PSSession
            Connect-ExchangeOnline
            $null = Connect-AzureAD
            $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
            $AzADDomain = ((Get-AzureADDomain).where{ $_.IsInitial }).Name
            if ($InitialDomain -ne $AzADDomain) {
                Write-Host "Halting script: $InitialDomain does not match $AzADDomain" -ForegroundColor Red
                break
            }
            $TargetInitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
            $TargetFile = Join-Path -Path $SourcePath -ChildPath ('{0}.csv' -f $TargetInitialDomain)

            Write-Host 'Connected to target: ' -ForegroundColor Cyan -NoNewline
            Write-Host ('{0}{1}' -f $TargetInitialDomain, [Environment]::NewLine) -ForegroundColor Green
            Write-Host 'Converted target file: ' -ForegroundColor Gray -NoNewline
            Write-Host ('{0}{1}' -f $TargetFile, [Environment]::NewLine) -ForegroundColor Yellow

            $ConvertedData = Convert-CloudData -SourceData $SourceData
            $ConvertedData | Out-GridView -Title "Data converted for import into Target: $TargetInitialDomain"
            $ConvertedData | Export-Csv -Path $TargetFile -NoTypeInformation
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            break
        }
    }

    $Yes = [ChoiceDescription]::new('&Yes', 'Import: Yes')
    $No = [ChoiceDescription]::new('&No', 'Import: No')
    $Question = 'Write converted data to Target Tenant?'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

    switch ($Menu) {
        0 {
            Write-Host 'Still connected to target: ' -ForegroundColor Cyan -NoNewline
            Write-Host ('{0}{1}' -f $TargetInitialDomain, [Environment]::NewLine) -ForegroundColor Green

            $FileStamp = 'Sync_Result_{0}_{1}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'), $InitialDomain
            $ResultFile = Join-Path -Path $SourcePath -ChildPath $FileStamp
            $ResultObject = New-CloudData -SourceData $ConvertedData
            $ResultObject | Out-GridView -Title $FileStamp
            $ResultObject | Export-Csv $ResultFile -NoTypeInformation
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            break
        }
    }
}
