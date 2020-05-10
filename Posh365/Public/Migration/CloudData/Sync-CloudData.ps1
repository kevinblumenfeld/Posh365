using namespace System.Management.Automation.Host
function Sync-CloudData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited',

        [parameter()]
        [switch]
        $SkipSourceLogon
    )
    #Region Paths
    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    if (-not ($null = Test-Path $SourcePath)) {
        $null = New-Item $PoshPath -Type Directory -Force -ErrorAction SilentlyContinue
        $null = New-Item $SourcePath -Type Directory -Force -ErrorAction SilentlyContinue
    }
    #EndRegion Paths
    #Region Choose Recipient
    while (-not $TypeGrid) {
        $TypeGrid = foreach ($Item in 'Mailboxes', 'MailUsers', 'AzureADUsers') {
            [PSCustomObject]@{
                RecipientType = $Item
            }
        }
        $TypeObject = $TypeGrid | Out-GridView -OutputMode Single -Title "Choose Recipient Type"
        $Type = $TypeObject.RecipientType
    }
    #EndRegion Choose Recipient
    #Region SOURCE Connect to Service ($InitialDomain) returned
    if (-not $SkipSourceLogin) {
        while (-not $InitialDomain) {
            $InitialDomain = Select-CloudDataConnection -Type $Type -TenantLocation Source
        }
    }
    #EndRegion SOURCE Connect to Service
    #Region Invoke-GetCloudData ($SourceData) returned
    $SourceCsvFile = Join-Path -Path $SourcePath -ChildPath ('SOURCE_SYNC_{0}_{1}.csv' -f $Type, $InitialDomain)
    $SourceData = Invoke-GetCloudData -ResultSize $ResultSize -InitialDomain $InitialDomain -Type $Type
    $SourceDataChoice = $SourceData | Out-GridView -Title "Choose objects to convert - no changes are made to any tenant on this step" -OutputMode Multiple
    $SourceDataChoice | Export-Csv -Path $SourceCsvFile -NoTypeInformation
    Write-Host "Source $Type objects chosen written to file: $SourceCsvFile`r`n" -ForegroundColor Green
    #EndRegion Invoke-GetCloudData
    #Region Ask if ready to convert
    $Yes = [ChoiceDescription]::new('&Yes', 'Convert Cloud Data: Yes')
    $No = [ChoiceDescription]::new('&No', 'Convert Cloud Data: No')
    $Title = 'Please make a selection'
    $Question = 'Convert data? (We only create a CSV in this step)'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 0)
    #EndRegion Ask if ready to convert
    switch ($Menu) {
        0 {
            #Region TARGET Connect to Service ($InitialDomain) returned
            $SourceInitialDomain = $InitialDomain ; $InitialDomain = $null
            $InitialDomain = Select-CloudDataConnection -Type $Type -TenantLocation Target
            while ($SourceInitialDomain -eq $InitialDomain -or -not $InitialDomain) {
                Write-Host "`r`nSource Tenant cannot be the same as the Target Tenant. Please connect to Target Tenant now.`r`n" -ForegroundColor White -BackgroundColor DarkMagenta
                $InitialDomain = Select-CloudDataConnection -Type $Type -TenantLocation Target
            }
            #EndRegion TARGET Connect to Service
            #Region TARGET Convert Source Data ($ConvertedData) returned
            $TargetCsvFile = Join-Path -Path $SourcePath -ChildPath ('SOURCE_SYNC_CONVERTED_TO_TARGET_{0}_{1}.csv' -f $Type, $InitialDomain)
            $ConvertedData = Convert-CloudData -SourceData $SourceDataChoice -Type $Type
            $ConvertedData | Out-GridView -Title "Data converted for import into Target: $TargetInitialDomain"
            $ConvertedData | Export-Csv -Path $TargetCsvFile -NoTypeInformation
            #EndRegion TARGET Convert Source Data ($ConvertedData) returned
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            return
        }
    }
    #Region Y/N Write Converted Data to Target Tenant
    $Yes = [ChoiceDescription]::new('&Yes', 'Import: Yes')
    $No = [ChoiceDescription]::new('&No', 'Import: No')
    $Question = 'Write converted data to Target Tenant?'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)
    #EndRegion Y/N Write Converted Data to Target Tenant
    switch ($Menu) {
        0 {
            $FileStamp = 'Sync_Result_{0}_{1}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'), $TargetInitialDomain
            $ResultFile = Join-Path -Path $SourcePath -ChildPath $FileStamp

            New-CloudData -SourceData $ConvertedData -Type $Type | Export-Csv $ResultFile -NoTypeInformation
            $ResultObject = Import-Csv $ResultFile
            $ResultObject | Out-GridView -Title $FileStamp
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            return
        }
    }
}
