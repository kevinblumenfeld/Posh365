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

    .PARAMETER ObjectInput
    This is used to pipe to an Excel file any object the same way you would traditionally pipe to Export-Csv

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
    Export-PoshExcel -InputDirectory C:\Users\Kevin\Desktop\temp -OutputDirectory C:\Scripts\ -ExcelFilename Test.xlsx -Recurse

    .EXAMPLE
    Get-Process | Export-PoshExcel -OutputDirectory C:\Scripts\ -ExcelFilename Process.xlsx -Color Green

    .EXAMPLE
    Import-Csv c:\scripts\allusers.csv | Export-PoshExcel -OutputDirectory C:\Scripts\ -ExcelFilename Process.xlsx -Color Green

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

        [Parameter(Position = 0, Mandatory, ParameterSetName = 'DirectoryInput')]
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'ObjectInput')]
        [string]
        $Path,

        [Parameter(Position = 1, Mandatory, ParameterSetName = 'DirectoryInput')]
        [ValidateScript( { Test-Path -PathType Container -Path $_ })]
        [string]
        $InputDirectory,

        [Parameter(ParameterSetName = 'DirectoryInput')]
        [switch]
        $Recurse,

        [Parameter(ParameterSetName = 'DirectoryInput')]
        [Parameter(ParameterSetName = 'ObjectInput')]
        [ValidateSet('Grey', 'Blue', 'Orange', 'LtGrey', 'Gold', 'LtBlue', 'Green')]
        [string]
        $Color = 'Blue',

        [Parameter(ParameterSetName = 'ObjectInput')]
        [string]
        $WorkSheetName,

        [Parameter(Mandatory, ParameterSetName = 'ObjectInput', ValueFromPipeline)]
        [Object[]]
        $ObjectInput

    )
    begin {
        $PipelineObject = [System.Collections.Generic.List[PSObject]]::New()
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
            Path                    = $Path
            TableStyle              = $ColorHash[$Color]
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $false

            ErrorAction             = 'SilentlyContinue'
        }
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ObjectInput' {
                foreach ($Object in $ObjectInput) {
                    $PipelineObject.Add($Object)
                }
            }
            'DirectoryInput' {
                $GciSplat = @{
                    Path    = $InputDirectory
                    Filter  = '*.csv'
                    Recurse = $Recurse
                }
                Get-ChildItem @GciSplat | Sort-Object BaseName -Descending | ForEach-Object {
                    Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName $_.basename
                }
            }
        }
    }
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'ObjectInput' {
                if ($WorkSheetName) {
                    $ExcelSplat.Add('WorksheetName', $WorkSheetName)
                }
                $PipelineObject | Export-Excel @ExcelSplat
            }
        }
        $ErrorActionPreference = $EA
    }
}
