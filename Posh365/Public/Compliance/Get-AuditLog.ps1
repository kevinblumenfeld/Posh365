function Get-AuditLog {

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $Path,
        [Parameter(Mandatory = $true)]
        [string] $FileName,
        [Parameter(Mandatory = $true)]
        [string] $TimeFrameInMinutes

    )
    Begin {
        Connect-Cloud -Tenant Office365AuditLogs -ExchangeOnline
    }
    Process {
        # Create Path if it does not already exist       
        New-Item -Path $Path -Type Directory -ErrorAction SilentlyContinue -Force
        
        # Rename to .old last picked up .json file & delete the last .old file
        Get-ChildItem -Path $path -Filter *.old | Remove-Item -Force
        Get-ChildItem -Path $path *.json | Rename-Item -NewName { $_.Name -replace '\.json$', '.old'}

        # Define dates for search. MSFT claims Windows short date format on the machine running the script should be used, but test proved "MM/dd/yyyy" must be used
        $StartDate = (get-date).AddMinutes( - $TimeFrameInMinutes).ToString("MM/dd/yyyy HH:mm")
        $EndDate = (get-date).ToString("MM/dd/yyyy HH:mm")

        # Define file name and path for csv export
        $OutputFile = $Path.ToString().TrimEnd('\') + "\" + $FileName + ".json"
        # Set variable value to trigger loop below (can be anything)
        $ConvertedOutput = [System.Collections.Generic.List[PSObject]]::New()
        # Loop will run until $AuditOutput returns null which equals that no more event objects exists from the specified date/time
        Do {
            # Search the defined date(s), SessionId + SessionCommand in combination with the loop will return and append 100 object per iteration until all objects are returned (minimum limit is 50k objects)
            $AuditOutput = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -SessionId "1" -SessionCommand ReturnLargeSet
            Foreach ($AuditData in $AuditOutput.AuditData) { 
                $ConvertedOutput.Add($AuditData)
            }
        } while ($AuditOutput)
    }
    End {
        $ConvertedOutput | Out-File $OutputFile
    }
}