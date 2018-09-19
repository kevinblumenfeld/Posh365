function Compare-Csv {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]
        $ReferenceCsv,
    
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]
        $DifferenceCsv,

        [Parameter(Mandatory = $true)]
        [String]$Key
    )
    begin {
        $ReferenceSet = @{}
        
        Import-Csv -Path $ReferenceCsv | ForEach-Object { 
            $ReferenceSet.Add($_.($key), $_) 
        }
    }
    process {
        Import-Csv -Path $DifferenceCsv | ForEach-Object { 
            $Identifier = $_.($Key)
            
            if ($ReferenceSet.Contains($Identifier)) {
                $ResultSet = @{}
                $Properties = [System.Collections.Generic.List[string]]::new()
                foreach ($Property in $_.PSObject.Properties) {
                    $Properties.Add($Property.Name + 'Reference')
                    $Properties.Add($Property.Name + 'Difference')
                    $Properties.Add($Property.Name + 'Result')
                    if ($ReferenceSet[$Identifier].$($Property.Name) -eq $Property.Value) {
                        $ResultSet.Add($Property.Name + 'Reference', $ReferenceSet[$Identifier].$($Property.Name))
                        $ResultSet.Add($Property.Name + 'Difference', $Property.Value)
                        $ResultSet.Add($Property.Name + 'Result', 'Match')
                    }
                    else {
                        $ResultSet.Add($Property.Name + 'Reference', $ReferenceSet[$Identifier].$($Property.Name))
                        $ResultSet.Add($Property.Name + 'Difference', $Property.Value)
                        $ResultSet.Add($Property.Name + 'Result', 'No_Match')
                    }
                }
                
                [PSCustomObject]$ResultSet | Select $Properties
            }
        }
    }
}