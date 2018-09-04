function Compare-Csv {
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

    Import-Csv $Csv2 | ForEach-Object { 
        if ($dataSet1.Contains($_.PrimarySmtpAddress)) {
            $results = [PSCustomObject]@{}
            foreach ($property in $_.PSObject.Properties) {
                if ($dataSet1[$_.PrimarySmtpAddress].$($property.Name) -eq $property.Value) {
                    $results | Add-Member -Name $property.Name -Type NoteProperty -Value $property.Value
                }
                else {
                    $results | Add-Member -Name $property.Name -Type NoteProperty -Value 'NoMatch'
                }
            }
            $results
        }
    }
}