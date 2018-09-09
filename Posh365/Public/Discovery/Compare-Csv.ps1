function Compare-Csv {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]
        $ReferenceCsv,
    
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]
        $DifferenceCsv
    )
    begin {
        $ReferenceSet = @{}
        
        Import-Csv -Path $ReferenceCsv | ForEach-Object { 
            $ReferenceSet.Add($_.PrimarySmtpAddress, $_) 
        }
    }
    process {
        Import-Csv -Path $DifferenceCsv | ForEach-Object { 
            $Identifier = $_.PrimarySmtpAddress
            
            if ($ReferenceSet.Contains($Identifier)) {
                $ResultSet = @{}
                
                foreach ($Property in $_.PSObject.Properties) {
                    if ($ReferenceSet[$Identifier].$($Property.Name) -eq $Property.Value) {
                        $ResultSet.Add($Property.Name, $Property.Value)
                    }
                    else {
                        $ResultSet.Add($Property.Name, 'NoMatch')
                    }
                }
                
                [PSCustomObject]$ResultSet
            }
        }
    }
}