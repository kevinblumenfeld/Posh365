function Compare-Csv {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateScript( {Test-Path $_})]
        [System.IO.FileInfo]
        $ReferenceCsv,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateScript( {Test-Path $_})]
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
                $ResultSet = [Ordered]@{}
                foreach ($Property in $_.PSObject.Properties) {
                    $ResultSet.Add($Property.Name + 'Reference', $ReferenceSet[$Identifier].$($Property.Name))
                    $ResultSet.Add($Property.Name + 'Difference', $Property.Value)
                    $ResultSet.Add("IsNullOrEmpty", [String]::IsNullOrEmpty($Property.Value))

                    if ($ReferenceSet[$Identifier].$($Property.Name) -eq $Property.Value) {
                        $ResultSet.Add($Property.Name + 'Result', 'No_Match')
                    }
                    else {
                        $ResultSet.Add($Property.Name + 'Result', 'Match')
                    }

                }

                [PSCustomObject]$ResultSet
            }
        }
    }
}