using namespace System.Management.Automation.Host
function New-CloudData {

    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $FilePath,

        [Parameter()]
        $TypeChoice,

        [Parameter()]
        $SourceData
    )

    while (-not $InitialDomain) {
        $InitialDomain = Select-CloudDataConnection -Type $TypeChoice -TenantLocation Target
    }
    if (-not $SourceData) {
        $SourceData = Import-Csv -Path $FilePath
    }
    Invoke-NewCloudData -ConvertedData $SourceData
}
