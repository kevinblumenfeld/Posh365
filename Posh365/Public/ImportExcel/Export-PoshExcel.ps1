function Export-PoshExcel {
    <#
    .SYNOPSIS
    Create an excel from a csv, directory of csv's, or recursively through a directory and subdirectories (csv's)
    Each tab will be named the name of the csv
    This wraps Doug Finks Export-Excel

    .DESCRIPTION
    Create an excel from a csv, directory of csv's, or recursively through a directory and subdirectories (csv's)
    Each tab will be named the name of the csv
    This wraps Doug Finks Export-Excel

    .PARAMETER InputDirectory
    The directory that contains the csv's

    .PARAMETER InputFile
    The csv if only using one csv and not directory
    Cannot be used with InputDirectory parameter

    .PARAMETER OutputDirectory
    The directory where the Excel file will be created

    .PARAMETER ExcelFilename
    The name of the Excel file you would like to create

    .PARAMETER Recurse
    Use this switch to create the excel from all csv's in a directory and also its subdirectories and so on.
    "Recursive"

    .PARAMETER Color
    Options are Grey, Blue, Orange, LtGrey, Gold, LtBlue, or Green

    .EXAMPLE
    Export-PoshExcel -InputDirectory C:\Users\Kevin\Desktop\temp -OutputDirectory C:\Scripts\ -ExcelFilename Test.xlsx -Recurse -Color Blue

    .EXAMPLE
    Export-PoshExcel -InputFile C:\Users\Kevin\Desktop\test.csv -OutputDirectory C:\Scripts\ -ExcelFilename Test.xlsx -Color Blue

    .NOTES
    The Excel file, by default, will have these features
     - Freeze Top Row
     - Freeze First Column
     - AutoSize each column
     - The top row will be bold
     - If the sheet is already there it will clear it before writing to it
     - If the sheet is not already there but the excel file is, it will add the sheet

    #>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, ParameterSetName = 'DirectoryInput')]
        [ValidateScript( { Test-Path -PathType Container -Path $_ })]
        [string]
        $InputDirectory,

        [Parameter(Mandatory, ParameterSetName = 'FileInput')]
        [ValidateScript( { Test-Path -PathType Leaf -Path $_ })]
        [string]
        $InputFile,

        [Parameter(Mandatory, ParameterSetName = 'DirectoryInput')]
        [Parameter(Mandatory, ParameterSetName = 'FileInput')]
        [ValidateScript( { Test-Path -PathType Container -Path $_ })]
        [string]
        $OutputDirectory,

        [Parameter(Mandatory, ParameterSetName = 'DirectoryInput')]
        [Parameter(Mandatory, ParameterSetName = 'FileInput')]
        [ValidateNotNull()]
        [string]
        $ExcelFilename,

        [Parameter(Mandatory, ParameterSetName = 'DirectoryInput')]
        [switch]
        $Recurse,

        [Parameter(ParameterSetName = 'DirectoryInput')]
        [Parameter(ParameterSetName = 'FileInput')]
        [ValidateSet('Grey', 'Blue', 'Orange', 'LtGrey', 'Gold', 'LtBlue', 'Green')]
        [string]
        $Color = 'Blue'
    )
    end {
        $ColorHash = @{
            Grey   = 'Medium1'
            Blue   = 'Medium2'
            Orange = 'Medium3'
            LtGrey = 'Medium4'
            Gold   = 'Medium5'
            LtBlue = 'Medium6'
            Green  = 'Medium7'
        }
        $EA = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"
        $ExcelSplat = @{
            Path                    = (Join-Path $OutputDirectory $ExcelFilename)
            TableStyle              = $ColorHash[$Color]
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $false
            ClearSheet              = $true
            ErrorAction             = 'SilentlyContinue'
        }
        if ($InputFile) {
            Get-Item $InputFile | ForEach-Object {
                Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName $_.basename
            }
        }
        else {
            $GciSplat = @{
                Path    = $InputDirectory
                Filter  = '*.csv'
                Recurse = $Recurse
            }
            Get-ChildItem @GciSplat | Sort-Object BaseName -Descending | ForEach-Object {
                Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName $_.basename
            }
        }
        $ErrorActionPreference = $EA
    }
}
