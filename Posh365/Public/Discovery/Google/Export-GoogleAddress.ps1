function Export-GoogleAddress {
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
    Export-Alias -AliasCsv .\Aliases.csv -DontImportCsv .\Primaries.csv | Export-Csv .\ToImport.csv -NoTypeInformation -Encoding UTF8

    .EXAMPLE
    Export-Alias -AliasCsv c:\scripts\Aliases.csv -DontImportCsv c:\scripts\Primaries.csv | Export-Csv c:\scripts\ToImport.csv -NoTypeInformation -Encoding UTF8

    .NOTES
    General notes
    #>

    param (

        [Parameter(Mandatory)]
        [string] $SharedCsv

    )

    $CsvList = Import-Csv $SharedCsv
    $PropList = ($CsvList | Select-Object -first 1).psobject.properties.name.where{
        $_ -match 'name.' -or $_ -match 'primaryEmail'
    }
    foreach ($Csv in $CsvList) {
        $PropArray = [System.Collections.Generic.List[string]]::new()
        foreach ($Prop in $PropList) {
            $PropArray.Add($Prop)
        }
        $Csv | Select $PropArray
    }
}
