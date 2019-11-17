function Convert-MWMailboxMovePermissionAddresses {
    <#
    .SYNOPSIS
    Create new Permissions.xlsx file by converting source addresses to target tenant addresses

    .DESCRIPTION
    Create new Permissions.xlsx file by converting source addresses to target tenant addresses

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"

    .PARAMETER ExcelPermissionsFile
    Also found in the SharePoint document repository. This is the excel file with the source tenant addresses (that need to be converted to target tenant)

    .PARAMETER WorksheetName
    Choose from Mailbox or Folder

    .PARAMETER NewExcelFilePath
    Output a new excel file with the target tenant addresses

    .EXAMPLE
    Convert-MWMailboxMovePermissionAddresses -SharePointURL 'https://contoso.sharepoint.com/sites/fabrikam/' -NewExcelFilePath C:\Scripts\Permissions.xlsx -WorksheetName Mailbox -ExcelPermissionsFile Permissions.xlsx

    .NOTES
    General notes
    #>

    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile = 'Batches.xlsx',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelPermissionsFile = 'Permissions.xlsx',

        [Parameter(Mandatory)]
        [ValidateSet('Mailbox', 'Folder')]
        [string]
        $WorksheetName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewExcelFilePath
    )
    end {
        $SharePointSplat = @{
            SharePointURL = $SharePointURL
            ExcelFile     = $ExcelFile
            NoBatch       = $true
        }
        $BatchHash = @{ }
        foreach ($Item in Import-SharePointExcel @SharePointSplat) {
            if ( $Item.PrimarySmtpAddress -and $Item.TargetPrimary -and -not $BatchHash.ContainsKey($Item.PrimarySmtpAddress)) {
                $BatchHash.Add($Item.PrimarySmtpAddress, $Item.TargetPrimary)
            }
        }
        $SharePointMailboxPerm = @{
            SharePointURL = $SharePointURL
            ExcelFile     = $ExcelPermissionsFile
            NoBatch       = $true
            WorksheetName = $WorksheetName
        }
        $TempCsv = '{0}.csv' -f [guid]::newguid().guid
        $TempCsvPath = Join-Path -Path $ENV:TEMP $TempCsv
        switch ($WorksheetName) {
            Mailbox {
                Import-SharePointExcel @SharePointMailboxPerm | ForEach-Object {
                    if ($_.PrimarySmtpAddress -and $_.GrantedSMTP -and $BatchHash.ContainsKey($_.PrimarySmtpAddress) -and $BatchHash.ContainsKey($_.GrantedSMTP) ) {
                        [PSCustomObject]@{
                            Object               = $_.Object
                            PrimarySmtpAddress   = $BatchHash.($_.PrimarySmtpAddress)
                            Granted              = $_.Granted
                            GrantedSMTP          = $BatchHash.($_.GrantedSMTP)
                            RecipientTypeDetails = $_.RecipientTypeDetails
                            Permission           = $_.Permission
                        }
                    }
                } | Export-csv $TempCsvPath -NoTypeInformation -Encoding UTF8
            }
            Folder {
                Import-SharePointExcel @SharePointMailboxPerm | ForEach-Object {
                    if ($_.PrimarySmtpAddress -and $_.GrantedSMTP -and $BatchHash.ContainsKey($_.PrimarySmtpAddress) -and $BatchHash.ContainsKey($_.GrantedSMTP) ) {
                        [PSCustomObject]@{
                            Object             = $_.Object
                            UserPrincipalName  = $_.UserPrincipalName
                            PrimarySmtpAddress = $BatchHash.($_.PrimarySmtpAddress)
                            Folder             = $_.Folder
                            AccessRights       = $_.AccessRights
                            Granted            = $_.Granted
                            GrantedSMTP        = $BatchHash.($_.GrantedSMTP)
                            TypeDetails        = $_.TypeDetails
                        }
                    }
                } | Export-csv $TempCsvPath -NoTypeInformation -Encoding UTF8
            }
        }

        $ExcelSplat = @{
            Path                    = $NewExcelFilePath
            TableStyle              = 'Medium2'
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $true
            ClearSheet              = $true
            WorksheetName           = $WorksheetName
            ErrorAction             = 'SilentlyContinue'
        }
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
            Path        = Split-Path -Path $NewExcelFilePath
        }
        $null = New-Item @ItemSplat
        Import-Csv -Path $TempCsvPath | Export-Excel @ExcelSplat
    }
}
