function Import-PoshCsv {
    <#
    .SYNOPSIS
    Import a CSV and not worry if it is open or not

    .DESCRIPTION
    Import a CSV and not worry if it is open or not
    The data imported from the CSV will be from when it was last saved

    .PARAMETER Path
    The file path to the csv you wish to import
    example: c:\scripts\afile.csv

    .EXAMPLE
    Import-PoshCsv "c:\scripts\RawADUsers.csv" | Export-PoshExcel "c:\scripts\PrettyADUsers.xlsx"

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )
    end {
        try {
            Get-Content $Path -Raw -ErrorAction Stop | ConvertFrom-Csv
        }
        catch {
            Write-Warning "Error Importing Csv"
            Write-Warning $_.Exception.Message
        }
    }
}
