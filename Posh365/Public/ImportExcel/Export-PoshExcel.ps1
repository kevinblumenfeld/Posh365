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

    .PARAMETER Path
    The full path and filename where the Excel file will be created.
    Use .xlsx extension

    .PARAMETER Recurse
    Use this switch to create the excel from all csv's in a directory and also its subdirectories and so on.
    "Recursive"

    .PARAMETER Color
    Options are Grey, Blue, Orange, LtGrey, Gold, LtBlue, or Green

    .EXAMPLE
    Export-PoshExcel -Path C:\Scripts\test.xlsx -InputDirectory C:\Scripts

    .EXAMPLE
    Same as above example, using positional parameters

    Export-PoshExcel C:\Scripts\test.xlsx C:\Scripts

    .EXAMPLE
    Same as above example, using -Recuse to import all CSVs in the directory c:\Scripts and also its subdirectories

    Export-PoshExcel C:\Scripts\test.xlsx C:\Scripts -Recurse

    .EXAMPLE
    Get-Process | Export-PoshExcel C:\Scripts\Process.xlsx -Color Green

    .EXAMPLE
    Import-Csv c:\scripts\allusers.csv | Export-PoshExcel C:\scripts\AllUsers.xlsx -Color Green

    .EXAMPLE
    Import-Csv c:\scripts\allusers.csv | Export-PoshExcel C:\scripts\AllUsers.xlsx -Color Orange -WorksheetName AllUsers

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
        $ExcelSplat = @{
            Path                    = $Path
            TableStyle              = $ColorHash[$Color]
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $false
            ClearSheet              = $true
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
                    Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName (-join $_.BaseName[0..29])
                }
            }
        }
    }
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'ObjectInput' {
                if ($WorkSheetName) {
                    $ExcelSplat.Add('WorksheetName', (-join $WorkSheetName[0..29]))
                }
                $PipelineObject | Export-Excel @ExcelSplat
            }
        }
    }
}
