function Export-GoogleAlias {
    <#
    .SYNOPSIS
    Google's GAM tool exports aliases
    This transforms that data and exports it into an importable format in the Microsoft world

    .DESCRIPTION
    Google's GAM tool exports aliases
    This transforms that data and exports it into an importable format in the Microsoft world

    .PARAMETER AliasCsv
    Mandatory Parameter example -AliasCsv "c:\scripts\aliases.csv"

    .PARAMETER AliasCsvHeader
    Defaults to PrimaryEmail header but can be changed as needed
    Must match the header name of the key of the spreadsheet

    .PARAMETER DontImportCsv
    Optional Parameter
    A CSV that typically contains primary smtp addresses
    Since you are importing only aliases they should not match any entries on this list
    This will filter out any matches to this list

    .PARAMETER DontImportCsvHeader
    Optional Parameter
    Defaults to Mail header but can be changed as needed

    .EXAMPLE
    Export-GoogleAlias -AliasCsv .\Aliases.csv -DontImportCsv .\Primaries.csv | Export-Csv .\ToImport.csv -NoTypeInformation -Encoding UTF8

    .EXAMPLE
    Export-GoogleAlias -AliasCsv c:\scripts\Aliases.csv -DontImportCsv c:\scripts\Primaries.csv | Export-Csv c:\scripts\ToImport.csv -NoTypeInformation -Encoding UTF8

    .NOTES
    General notes
    #>

    param (

        [Parameter(Mandatory)]
        [string] $AliasCsv,

        [Parameter()]
        [string] $AliasCsvHeader = 'PrimaryEmail',

        [Parameter()]
        [string] $DontImportCsv,

        [Parameter()]
        [string] $DontImportCsvHeader = 'Mail',

        [Parameter()]
        [switch] $DontPrependsmtp

    )
    $Prop = @(
        'aliases.0', 'aliases.1', 'aliases.2', 'aliases.3', 'aliases.4', 'aliases.5', 'aliases.6'
        'aliases.7', 'aliases.8', 'aliases.9', 'aliases.10', 'aliases.11', 'aliases.12', 'aliases.13', 'aliases.14'
        'aliases.15', 'aliases.16', 'aliases.17', 'aliases.18', 'aliases.19', 'aliases.20', 'aliases.21', 'aliases.22'
        'aliases.23', 'aliases.24', 'aliases.25', 'aliases.26', 'aliases.27', 'aliases.28', 'aliases.29', 'emails.0.address'
        'emails.1.address', 'emails.10.address', 'emails.11.address', 'emails.12.address', 'emails.13.address'
        'emails.14.address', 'emails.15.address', 'emails.16.address', 'emails.17.address', 'emails.18.address'
        'emails.19.address', 'emails.2.address', 'emails.20.address', 'emails.21.address', 'emails.22.address'
        'emails.23.address', 'emails.24.address', 'emails.25.address', 'emails.26.address', 'emails.27.address'
        'emails.28.address', 'emails.29.address', 'emails.29.primary', 'emails.3.address', 'emails.30.address'
        'emails.4.address', 'emails.5.address', 'emails.6.address', 'emails.7.address', 'emails.8.address', 'emails.9.address'
    )

    $Alias = Import-Csv $AliasCsv
    if (-not $DontPrependsmtp) {
        if ($DontImportCsv) {
            $DontImport = (Import-Csv $DontImportCsv).$DontImportCsvHeader
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp -and -not ($DontImport -contains $CurAlias.$CurProp)) {
                        [PSCustomObject]@{
                            Mail  = $CurAlias.$AliasCsvHeader
                            Alias = 'smtp:{0}' -f $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
        else {
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp) {
                        [PSCustomObject]@{
                            Mail  = $CurAlias.$AliasCsvHeader
                            Alias = 'smtp:{0}' -f $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
    }
    else {
        if ($DontImportCsv) {
            $DontImport = (Import-Csv $DontImportCsv).$DontImportCsvHeader
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp -and -not ($DontImport -contains $CurAlias.$CurProp)) {
                        [PSCustomObject]@{
                            Mail  = $CurAlias.$AliasCsvHeader
                            Alias = $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
        else {
            foreach ($CurAlias in $Alias) {
                foreach ($CurProp in $Prop) {
                    if ($CurAlias.$CurProp) {
                        [PSCustomObject]@{
                            Mail  = $CurAlias.$AliasCsvHeader
                            Alias = $CurAlias.$CurProp
                        }
                    }
                }
            }
        }
    }
}
