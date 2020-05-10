using namespace System.Management.Automation.Host
function New-CloudData {

    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $FilePath,

        [Parameter(Mandatory)]
        [ValidateSet('Mailboxes', 'MailUsers', 'AzureADUsers')]
        $Type,

        [Parameter()]
        $SourceData
    )

    while (-not $InitialDomain) {
        $InitialDomain = Select-CloudDataConnection -Type $Type -TenantLocation Target
    }
    if (-not $SourceData) {
        $SourceData = Import-Csv -Path $FilePath
    }
    Invoke-NewCloudData -ConvertedData $SourceData -Type $Type
}
