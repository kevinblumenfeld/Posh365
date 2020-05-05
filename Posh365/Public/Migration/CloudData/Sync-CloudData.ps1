using namespace System.Management.Automation.Host
function Sync-CloudData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited'
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
    while (-not $TypeChoice) {
        $Type = foreach ($Item in 'Mailboxes', 'MailUsers', 'AzureADUsers') {
            [PSCustomObject]@{
                RecipientType = $Item
            }
        }
        $TypeObject = $Type | Out-GridView -OutputMode Single -Title "Choose Recipient Type"
        $TypeChoice = $TypeObject.RecipientType
    }
    #EndRegion Choose Recipient
    #Region SOURCE Connect to Service ($InitialDomain) returned
    $InitialDomain = Select-CloudDataConnection -Type $TypeChoice -TenantLocation Source

    #EndRegion SOURCE Connect to Service
    #Region Invoke-GetCloudData ($SourceData) returned
    $CsvFile = Join-Path -Path $SourcePath -ChildPath ('SOURCE_SYNC_{0}_{1}.csv' -f $TypeChoice, $InitialDomain)
    $SourceData = Invoke-GetCloudData -ResultSize $ResultSize -InitialDomain $InitialDomain -Type $TypeChoice
    $SourceData | Export-Csv -Path $CsvFile -NoTypeInformation
    Write-Host "Source $TypeChoice objects written to file: $CsvFile`r`n" -ForegroundColor Green
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
            $SourceIntialDomain = $InitialDomain ; $InitialDomain = $null
            $InitialDomain = Select-CloudDataConnection -Type $TypeChoice -TenantLocation Target
            while ($SourceIntialDomain -eq $InitialDomain) {
                Write-Warning 'Source Tenant cannot be the same as the Target Tenant. Please connect to Target Tenant now.'
                $InitialDomain = Select-CloudDataConnection -Type $TypeChoice -TenantLocation Target
            }

            #EndRegion TARGET Connect to Service
            #Region TARGET Convert Source Data ($ConvertedData) returned
            $ConvertedData = Convert-CloudData -SourceData $SourceData
            $ConvertedData | Out-GridView -Title "Data converted for import into Target: $TargetInitialDomain"
            $ConvertedData | Export-Csv -Path $TargetFile -NoTypeInformation
            #EndRegion TARGET Convert Source Data ($ConvertedData) returned
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            return
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

            New-CloudData -SourceData $ConvertedData | Export-Csv $ResultFile -NoTypeInformation
            $ResultObject = Import-Csv $ResultFile
            $ResultObject | Out-GridView -Title $FileStamp
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            return
        }
    }
}
