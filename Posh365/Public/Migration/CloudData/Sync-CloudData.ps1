using namespace System.Management.Automation.Host
function Sync-CloudData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited'
    )
    $Yes = [ChoiceDescription]::new('&Yes', 'Connect: Yes')
    $No = [ChoiceDescription]::new('&No', 'Connect: No')
    $Title = 'Please make a selection'
    $Question = 'Connect to Exchange Online and AzureAD?'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $ConnectMenu = $host.ui.PromptForChoice($Title, $Question, $Options, 0)

    switch ($ConnectMenu) {
        0 {
            Get-PSSession | Remove-PSSession
            try { Disconnect-AzureAD -ErrorAction Stop } catch { }
            If (-not ($null = Get-Module -Name 'AzureAD', 'AzureADPreview' -ListAvailable)) {
                Install-Module -Name AzureAD -Scope CurrentUser -Force -AllowClobber
            }
            $Script:RestartConsole = $null
            Connect-CloudModuleImport -EXO2
            if ($RestartConsole) {
                return
            }
            Write-Host "`r`nEnter credentials for Source Tenant Exchange Online`r`n" -ForegroundColor Cyan
            Connect-ExchangeOnline
            $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
            Write-Host "`r`nConnected to Exchange Online Tenant: $InitialDomain`r`n" -ForegroundColor Green

            Write-Host "`r`nEnter credentials for Source Azure AD`r`n" -ForegroundColor Cyan
            $null = Connect-AzureAD
            $AzDomain = ((Get-AzureADDomain).where{ $_.IsInitial }).Name
            Write-Host "`r`nConnected to Azure AD Tenant: $AzDomain`r`n" -ForegroundColor Green
        }
        1 { }
    }

    if ($InitialDomain -ne $AzDomain) {
        Write-Host "Halting script: $InitialDomain does not match $AzDomain" -ForegroundColor Red
        continue
    }
    if ($InitialDomain) {
        $Yes = [ChoiceDescription]::new('&Yes', 'Source Domain: Yes')
        $No = [ChoiceDescription]::new('&No', 'Source Domain: No')
        $Title = 'Please make a selection'
        $Question = 'Is this the source tenant {0}?' -f $InitialDomain
        $Options = [ChoiceDescription[]]($Yes, $No)
        $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

        switch ($Menu) {
            0 { }
            1 { continue }
        }
    }
    else {
        Write-Host 'Halting script: Not connected to Exchange Online' -ForegroundColor Red
        continue
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
    Write-Host 'Writing to: ' -ForegroundColor Cyan -NoNewline
    Write-Host ('{0}{1}' -f $SourceFile, [Environment]::NewLine) -ForegroundColor Green

    $SourceData = Invoke-GetCloudData -ResultSize $ResultSize -InitialDomain $InitialDomain
    $SourceData | Export-Csv -Path $SourceFile -NoTypeInformation

    Write-Host ('Source objects written to file: {0} {1}' -f $SourceFile, [Environment]::NewLine) -ForegroundColor Green

    $Yes = [ChoiceDescription]::new('&Yes', 'Convert Cloud Data: Yes')
    $No = [ChoiceDescription]::new('&No', 'Convert Cloud Data: No')
    $Title = 'Please make a selection'
    $Question = 'Convert data? (We only create a CSV in this step)'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 0)

    switch ($Menu) {
        0 {
            Get-PSSession | Remove-PSSession
            try { Disconnect-AzureAD -ErrorAction Stop } catch { }

            Write-Host "`r`nEnter credentials for Target Tenant Exchange Online`r`n" -ForegroundColor Cyan
            Connect-ExchangeOnline
            $TargetInitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
            Write-Host "`r`nConnected to Exchange Online Tenant: $TargetInitialDomain`r`n" -ForegroundColor Green

            Write-Host "`r`nEnter credentials for Target Azure AD`r`n" -ForegroundColor Cyan
            $null = Connect-AzureAD
            $TargetAzDomain = ((Get-AzureADDomain).where{ $_.IsInitial }).Name
            Write-Host "`r`nConnected to Azure AD Tenant: $TargetAzDomain`r`n" -ForegroundColor Green


            if ($TargetInitialDomain -ne $TargetAzDomain) {
                Write-Host "Halting script: $TargetInitialDomain does not match $TargetAzDomain" -ForegroundColor Red
                continue
            }
            $TargetFile = Join-Path -Path $SourcePath -ChildPath ('{0}.csv' -f $TargetInitialDomain)

            Write-Host 'Connected to target: ' -ForegroundColor Cyan -NoNewline
            Write-Host ('{0}{1}' -f $TargetInitialDomain, [Environment]::NewLine) -ForegroundColor Green
            Write-Host 'Converted target file: ' -ForegroundColor Cyan -NoNewline
            Write-Host ('{0}{1}' -f $TargetFile, [Environment]::NewLine) -ForegroundColor Green

            $ConvertedData = Convert-CloudData -SourceData $SourceData
            $ConvertedData | Out-GridView -Title "Data converted for import into Target: $TargetInitialDomain"
            $ConvertedData | Export-Csv -Path $TargetFile -NoTypeInformation
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            continue
        }
    }

    $Yes = [ChoiceDescription]::new('&Yes', 'Import: Yes')
    $No = [ChoiceDescription]::new('&No', 'Import: No')
    $Question = 'Write converted data to Target Tenant?'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

    switch ($Menu) {
        0 {
            $FileStamp = 'Sync_Result_{0}_{1}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'), $TargetInitialDomain
            $ResultFile = Join-Path -Path $SourcePath -ChildPath $FileStamp

            $ResultObject = New-CloudData -SourceData $ConvertedData
            $ResultObject | Out-GridView -Title $FileStamp
            $ResultObject | Export-Csv $ResultFile -NoTypeInformation
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            continue
        }
    }
}
