using namespace System.Management.Automation.Host
function Complete-CloudDataSync {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited',

        [Parameter()]
        [ValidateScript( { Test-Path $_ } )]
        $AlternateCSVFilePath
    )
    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -Type Directory -Force -ErrorAction SilentlyContinue
    }
    if ($AlternateCSVFilePath) {
        $ResultFile = $AlternateCSVFilePath
    }
    else {
        $ResultFile = Join-Path -Path $PoshPath -ChildPath 'SyncCloudData_Results.csv'
    }
    $ResultObject = Import-Csv $ResultFile
    $Converted = Convert-CompleteCloudDataSync -ResultObject $ResultObject
    $ChoiceList = $Converted | Out-GridView -OutputMode Multiple -Title 'Choose which objects to modify at Target'
    if ($ChoiceList){
        $ChoiceList | Export-Csv (Join-Path -Path $PoshPath -ChildPath 'ConvertCloudData_Converted.csv') -NoTypeInformation
        $ChoiceList2 = Import-Csv (Join-Path -Path $PoshPath -ChildPath 'ConvertCloudData_Converted.csv')
        $WriteResult = Invoke-CompleteCloudDataSync -ChoiceList $ChoiceList2
        $WriteResultFile = Join-Path -Path $PoshPath -ChildPath 'CompleteCloudData_Results.csv'
        $WriteResult | Out-GridView -Title $WriteResultFile
        $WriteResult | Export-Csv $WriteResultFile -NoTypeInformation -Append
    }
}
