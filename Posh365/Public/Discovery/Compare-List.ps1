function Compare-List {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]
        $ReferenceCsv,
    
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]
        $DifferenceCsv,
        
        [Parameter()]
        [string] $FindInColumn = "UserPrincipalName"
    )

    $dataSet1 = @{}
    Import-Csv $ReferenceCsv | ForEach-Object { 
        $dataSet1.Add($_.$FindInColumn, $_) 
    }

    $notFound = [System.Collections.Generic.HashSet[string]]::new()
    Import-Csv $DifferenceCsv | ForEach-Object { 
        if (-not $dataSet1.Contains($_.$FindInColumn)) {
            [void]$notFound.Add($_.$FindInColumn)
        }
    }
    $notFound
}
# This needs to use to hashsets instead and you are doing nothing with the values of hashtable