function Get-UsersInOuNotInCloud {
    Param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter()]
        $BatchesExcelFile = 'Batches.xlsx',

        [Parameter()]
        $ADUserExcelFile = 'AllData.xlsx',

        [Parameter()]
        $ADUserWorksheet = 'ADUser'
    )
    Connect-SharePointPNP -Url $SharePointURL

    $BatchesTrimmedExcelFile = [regex]::matches($BatchesExcelFile, "[^\/]*$")[0].Value
    $BatchesExcelURL = "Shared Documents/{0}" -f ($BatchesExcelFile).TrimStart('/')
    $BatchesTempExcel = '{0}_{1}' -f [guid]::newguid().guid, $BatchesTrimmedExcelFile
    $BatchesTempExcelPath = Join-Path -Path $ENV:TEMP $BatchesTempExcel
    Get-PnPFile -Url $BatchesExcelURL -Path $Env:TEMP -Filename $BatchesTempExcel -AsFile -Force

    $ADUserTrimmedExcelFile = [regex]::matches($ADUserExcelFile, "[^\/]*$")[0].Value
    $ADUserExcelURL = "Shared Documents/{0}" -f ($ADUserExcelFile).TrimStart('/')
    $ADUserTempExcel = '{0}_{1}' -f [guid]::newguid().guid, $ADUserTrimmedExcelFile
    $ADUserTempExcelPath = Join-Path -Path $ENV:TEMP $ADUserTempExcel
    Get-PnPFile -Url $ADUserExcelURL -Path $Env:TEMP -Filename $ADUserTempExcel -AsFile -Force

    $BatchesExcelSplat = @{
        Path = $BatchesTempExcelPath
    }
    $BatchesHash = @{ }
    Import-Excel @BatchesExcelSplat | ForEach-Object {
        if ($_.UserPrincipalName -and $_.OrganizationalUnit) {
            $BatchesHash[$_.UserPrincipalName] = $_.OrganizationalUnit
        }
    }

    $ADUserExcelSplat = @{
        Path          = $ADUserTempExcelPath
        WorksheetName = $ADUserWorksheet
    }
    Import-Excel @ADUserExcelSplat | ForEach-Object {
        if (($_.OU -in $BatchesHash.Values) -and ($_.UserPrincipalName -notin $BatchesHash.Keys)) {
            [PSCustomObject]@{
                Name               = $_.Name
                DisplayName        = $_.DisplayName
                CanonicalName      = $_.CanonicalName
                Enabled            = $_.Enabled
                UserPrincipalName  = $_.UserPrincipalName
                PrimarySmtpAddress = ($_.PrimarySmtpAddress -split ':')[1]
                TenantAddress      = [regex]::matches(@(($_.ProxyAddresses).split('|')), "(?<=(smtp|SMTP):)[^@]+@[^.]+?\.onmicrosoft\.com")[0].Value
                OrganizationalUnit = $_.OU
                Description        = $_.Description
                SamAccountName     = $_.SamAccountName
            }
        }
    }
}
