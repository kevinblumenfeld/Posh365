function Update-MWMailboxMoveBatchesReport {
    <#
    .SYNOPSIS
    Updates Batches.xlsx with most recent data

    .DESCRIPTION
    Updates Batches.xlsx with most recent data
    When you re-run "Get-365Info -ExchangeOnline -CreateMSPCompleteBulkFile" to get latest mailbox report you will be given batches.csv. Ignore the xslx file you also get.
    use the -NewCsvFile to identify the batches.csv
    the -ReportPath parameter is where this function will provide the up to date Batches.xlsx file you can then upload to SharePoint (replacing the existing file)

    This function retains all the data that has been entered by you or the customer while giving you all new mailboxes and removing any mailboxes no longer found in the source tenant.

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"

    .PARAMETER NewCsvFile
    Use a new batches.csv file

    .EXAMPLE
    This uses batches.xlsx stored in the teams "General" folder.
    Update-MWMailboxMoveBatchesReport -SharePointURL 'https://fabrikam.sharepoint.com/sites/365migration' -ExcelFile 'General\batches.xlsx' -NewCsvFile "C:\Scripts\Batches.csv" -ReportPath C:\Scripts

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
        $NewCsvFile,

        [Parameter(Mandatory)]
        [string]
        $ReportPath
    )
    end {
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
        $SharePointSplat = @{
            SharePointURL = $SharePointURL
            ExcelFile     = $ExcelFile
        }
        $CurrentHash = @{ }
        $CurrentList = Import-SharePointExcel @SharePointSplat
        foreach ($Current in $CurrentList) {
            $CurrentHash.Add($Current.UserPrincipalName, @{
                    'Migrate'             = $Current.Migrate
                    'ArchiveOnly'         = $Current.ArchiveOnly
                    'DeploymentPro'       = $Current.DeploymentPro
                    'LicenseGroup'        = $Current.LicenseGroup
                    'DeploymentProMethod' = $Current.DeploymentProMethod
                    'Notes'               = $Current.Notes
                    'TargetMailboxInUse'  = $Current.TargetMailboxInUse
                    'BitTitanLicense'     = $Current.BitTitanLicense
                }
            )
        }

        $Future = Import-Csv $NewCsvFile | Select-Object @(
            'DisplayName'
            @{
                Name       = 'Migrate'
                Expression = { $CurrentHash.$($_.UserPrincipalName).Migrate }
            }
            @{
                Name       = 'ArchiveOnly'
                Expression = { $CurrentHash.$($_.UserPrincipalName).ArchiveOnly }
            }
            @{
                Name       = 'DeploymentPro'
                Expression = { $CurrentHash.$($_.UserPrincipalName).DeploymentPro }
            }
            @{
                Name       = 'DeploymentProMethod'
                Expression = { $CurrentHash.$($_.UserPrincipalName).DeploymentProMethod }
            }
            @{
                Name       = 'LicenseGroup'
                Expression = { $CurrentHash.$($_.UserPrincipalName).LicenseGroup }
            }
            'DirSyncEnabled'
            @{
                Name       = 'TargetMailboxInUse'
                Expression = { $CurrentHash.$($_.UserPrincipalName).TargetMailboxInUse }
            }
            'RecipientTypeDetails'
            'TotalGB'
            'ArchiveGB'
            'OrganizationalUnit(CN)'
            'PrimarySmtpAddress'
            'SourceTenantAddress'
            'TargetTenantAddress'
            'TargetPrimary'
            'TargetUserPrincipalName'
            'FirstName'
            'LastName'
            'UserPrincipalName'
            'OnPremisesSecurityIdentifier'
            'DistinguishedName'
            'MailboxGB'
            'DeletedGB'
            'ArchiveStatus'
            @{
                Name       = 'Notes'
                Expression = { $CurrentHash.$($_.UserPrincipalName).Notes }
            }
            @{
                Name       = 'BitTitanLicense'
                Expression = { $CurrentHash.$($_.UserPrincipalName).BitTitanLicense }
            }
        )
        $ExcelSplat = @{
            Path                    = (Join-Path $ReportPath 'Batches.xlsx')
            TableStyle              = 'Medium2'
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $true
            ClearSheet              = $true
            WorksheetName           = 'Batches'
            ErrorAction             = 'SilentlyContinue'
        }
        $Future | Sort-Object @(
            @{
                Expression = "DisplayName"
                Descending = $false
            }
        ) | Export-Excel @ExcelSplat
    }
}
