function Update-MWMailboxMoveBatchesReportWithTargetTenantAddress {
    <#
    .SYNOPSIS
    Updates Batches.xlsx with Target Tenant Address

    .DESCRIPTION
    Updates Batches.xlsx with Target Tenant Address

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"

    .PARAMETER NewCsvFile
    Path to csv of mailboxes.  In discovery it is typically EXO_Mailboxes.csv

    .PARAMETER Tenant
    This is the tenant domain - where you are migrating to.
    Example if tenant is contoso.mail.onmicrosoft.com use: Contoso

    .EXAMPLE
    This uses batches.xlsx stored in the teams "General" folder.
    Update-MWMailboxMoveBatchesReport -SharePointURL 'https://fabrikam.sharepoint.com/sites/365migration' -ExcelFile 'General\batches.xlsx' -NewCsvFile "C:\Scripts\Batches.csv" -Tenant contoso -ReportPath C:\Scripts

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
        [string]
        $ReportPath
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
        $SharePointSplat = @{
            SharePointURL = $SharePointURL
            ExcelFile     = $ExcelFile
            Tenant        = $Tenant
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
            'DeploymentPro'
            'DirSyncEnabled'
            'CustomTargetAddress'
            'RecipientTypeDetails'
            'ArchiveStatus'
            'OrganizationalUnit(CN)'
            'SourcePrimary'
            'SourceTenantAddress'
            @{
                Name       = 'TargetTenantAddress'
                Expression = { if ($_.CustomTargetAddress -ne $True) { $AzureSIDHash.$($_.OnPremisesSecurityIdentifier).TargetTenantAddress } else { $_.TargetTenantAddress } }
            }
            @{
                Name       = 'TargetPrimary'
                Expression = { if ($_.CustomTargetAddress -ne $True) { $AzureSIDHash.$($_.OnPremisesSecurityIdentifier).TargetPrimary } else { $_.TargetPrimary } }
            }
            'FirstName'
            'LastName'
            'UserPrincipalName'
            'OnPremisesSecurityIdentifier'
            'DistinguishedName'
            'MailboxGB'
            'ArchiveGB'
            'DeletedGB'
            'TotalGB'
            'Notes'
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
