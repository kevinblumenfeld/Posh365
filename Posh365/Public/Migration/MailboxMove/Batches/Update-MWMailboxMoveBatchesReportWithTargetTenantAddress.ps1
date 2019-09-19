function Update-MWMailboxMoveBatchesReportWithTargetTenantAddress {
    <#
    .SYNOPSIS
    Updates Batches.xlsx with Target Tenant Address (onmicrosoft address)
    Connect to AzureAD in Target Tenant.

    .DESCRIPTION
    Updates Batches.xlsx with Target Tenant Address
    You provide the SharePoint path to the current excel (that you want updated with the Target Tenant addresses) and this will output a fresh Batches.xlsx

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"

    .PARAMETER ReportPath
    Output path where a new and updated Batches.xlsx will be output

    .EXAMPLE
    This uses batches.xlsx stored in the teams "General" folder.
    Update-MWMailboxMoveBatchesReport -SharePointURL 'https://fabrikam.sharepoint.com/sites/365migration' -ExcelFile 'General\batches.xlsx' -ReportPath C:\Scripts

    .EXAMPLE
    This uses batches.xlsx stored in the root of the SharePoint documents (sometimes called Shared Documents) folder.
    Update-MWMailboxMoveBatchesReport -SharePointURL 'https://fabrikam.sharepoint.com/sites/365migration' -ExcelFile 'batches.xlsx' -ReportPath C:\Scripts

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
        [string]
        $ReportPath
    )
    end {
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
        $SharePointSplat = @{
            SharePointURL = $SharePointURL
            ExcelFile     = $ExcelFile
        }

        $AzureSIDHash = @{ }
        (Get-AzureADUser -All:$true).where( { $_.OnPremisesSecurityIdentifier }).foreach{
            $SID = $_.OnPremisesSecurityIdentifier
            $TargetTenantAddress = [regex]::matches(@(($_.ProxyAddresses) -split '\|'), "(?<=(smtp|SMTP):)[^@]+@[^.]+?\.onmicrosoft\.com")[0].Value
            $TargetPrimary = ($_.ProxyAddresses -cmatch 'SMTP:' -split ':')[1]
            if ($SID -and ($TargetTenantAddress -or $TargetPrimary)) {
                $AzureSIDHash.Add($SID, @{
                        TargetTenantAddress = $TargetTenantAddress
                        TargetPrimary       = $TargetPrimary
                    })
            }
        }
        $Future = Import-SharePointExcel @SharePointSplat | Select-Object @(
            'DisplayName'
            'Migrate'
            'ArchiveOnly'
            'DeploymentPro'
            'DeploymentProMethod'
            'LicenseGroup'
            'DirSyncEnabled'
            'TargetMailboxInUse'
            'RecipientTypeDetails'
            'TotalGB'
            'ArchiveGB'
            'OrganizationalUnit(CN)'
            'SourcePrimary'
            'SourceTenantAddress'
            @{
                Name       = 'TargetTenantAddress'
                Expression = { if ($_.TargetMailboxInUse -ne $True) { $AzureSIDHash.$($_.OnPremisesSecurityIdentifier).TargetTenantAddress } else { $_.TargetTenantAddress } }
            }
            @{
                Name       = 'TargetPrimary'
                Expression = { if ($_.TargetMailboxInUse -ne $True) { $AzureSIDHash.$($_.OnPremisesSecurityIdentifier).TargetPrimary } else { $_.TargetPrimary } }
            }
            'FirstName'
            'LastName'
            'UserPrincipalName'
            'OnPremisesSecurityIdentifier'
            'DistinguishedName'
            'MailboxGB'
            'DeletedGB'
            'ArchiveStatus'
            'Notes'
            'BitTitanLicense'
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
