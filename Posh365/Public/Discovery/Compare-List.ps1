function Compare-List {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $Csv1,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $Csv2  
    )
    $dataSet1 = @{}
    Import-Csv $Csv1 | ForEach-Object { 
        $dataSet1.Add($_.PrimarySmtpAddress, $_) 
    }

    $noSmtpFound = [System.Collections.Generic.HashSet[string]]::new()
    Import-Csv $Csv2 | ForEach-Object { 
        if (-not $dataSet1.Contains($_.PrimarySmtpAddress)) {
            [void]$noSmtpFound.Add($_.PrimarySmtpAddress)
        }
    }
    $noSmtpFound
}
# Compare-Csv -Csv1 C:\Scripts\test1.csv -Csv2 C:\Scripts\test2.csv