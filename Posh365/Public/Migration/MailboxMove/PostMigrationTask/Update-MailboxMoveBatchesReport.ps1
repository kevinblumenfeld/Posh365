function Update-MailboxMoveBatchesReport {
    <#
    .SYNOPSIS
    Updates Batches.xlsx by pulling batch names from existing and pairing it with a new batches.csv
    Creates a new Batches.xlsx

    .DESCRIPTION
    Updates Batches.xlsx by pulling batch names from existing and pairing it with a new batches.csv
    Creates a new Batches.xlsx

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER NewCsvFile
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName
    This would be a new Csv of existing mailboxes from source environment

    .PARAMETER Tenant
    This is the tenant domain - where you are migrating to.
    Example if tenant is contoso.mail.onmicrosoft.com use contoso

    .EXAMPLE
    Update-MailboxMoveBatchesReport -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx' -Tenant Contoso

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewCsvFile
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }

        $SharePointSplat = @{
            SharePointURL = $SharePointURL
            ExcelFile     = $ExcelFile
            Tenant        = $Tenant

        }
        $CurrentHash = @{ }
        $CurrentList = (Import-SharePointExcel @SharePointSplat).where{ $_.BatchName }
        foreach ($Current in $CurrentList) {
            $CurrentHash.Add($Current.UserPrincipalName, $Current.BatchName)
        }
    }
}
