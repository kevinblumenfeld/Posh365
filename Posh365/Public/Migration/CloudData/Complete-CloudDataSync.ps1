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
    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    if (-not ($null = Test-Path $SourcePath)) {
        $null = New-Item $PoshPath -Type Directory -Force -ErrorAction SilentlyContinue
        $null = New-Item $SourcePath -Type Directory -Force -ErrorAction SilentlyContinue
    }
    if ($AlternateCSVFilePath) {
        $ResultFile = $AlternateCSVFilePath
    }
    else {
        $ResultFile = Join-Path -Path $SourcePath -ChildPath 'SyncCloudData_Results.csv'
    }
    $ResultObject = Import-Csv $ResultFile
    $Converted = Convert-CompleteCloudDataSync -ResultObject $ResultObject
    $ChoiceList = $Converted | Out-GridView -OutputMode Multiple -Title 'Choose which objects to modify at Target'
    if ($ChoiceList){
        $WriteResultFile = Join-Path -Path $SourcePath -ChildPath 'CompleteCloudData_Results.csv'
        $WriteResult = Invoke-CompleteCloudDataSync -ChoiceList $ChoiceList
        $WriteResult | Out-GridView -Title $WriteResultFile
        $WriteResult | Export-Csv $WriteResultFile -NoTypeInformation -Append
    }
}
