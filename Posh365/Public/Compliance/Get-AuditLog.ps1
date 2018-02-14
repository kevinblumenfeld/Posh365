function Get-AuditLog {

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]] $userprincipalname,
            
        [Parameter(Mandatory = $false)]
        [switch] $Archive,
      
        [Parameter(Mandatory = $false)]
        [switch] $StartMFA
    )
    Begin {
        $resultarray = @()

    
    }
    Process {
        foreach ($CurUPN in $userprincipalname) {
            # Define dates for search. MSFT claims Windows short date format on the machine running the script should be used, but test proved "MM/dd/yyyy" must be used
            $StartDate = (get-date).AddMinutes(-15).ToString("MM/dd/yyyy HH:mm")
            $EndDate = (get-date).ToString("MM/dd/yyyy HH:mm")

            # Define file name and path for csv export
            $FileNameTimeStart = (get-date).AddMinutes(-15).ToString("_MM-dd-yyyy_HHmm")
            $FileNameTimeEnd = (get-date).ToString("___MM-dd-yyyy_HHmm")
            # [string]$FileAppend = (Get-Date -Format yyyyMMdd)
            $OutputFile = "[DEFINE OUTPUT FILE PATH]" + $FileAppend + ".csv"

            # Set variable value to trigger loop below (can be anything)
            $AuditOutput = 1

            # Loop will run until $AuditOutput returns null which equals that no more event objects exists from the specified date
            while ($AuditOutput) {

                # Search the defined date(s), SessionId + SessionCommand in combination with the loop will return and append 100 object per iteration until all objects are returned (minimum limit is 50k objects)
                $AuditOutput = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -SessionId "1" -SessionCommand ReturnLargeSet

                # Select and expand the nested object (AuditData) as it holds relevant reporting data. Convert output format from default JSON to enable export to csv
                $ConvertedOutput = $AuditOutput | Select-Object -ExpandProperty AuditData | ConvertFrom-Json

                # Export results exluding type information. Append rather than overwrite if the file exist in destination folder
                $ConvertedOutput | Select-Object CreationTime, UserId, Operation, Workload, ObjectID, SiteUrl, SourceFileName, ClientIP, UserAgent  | Export-Csv $OutputFile -NoTypeInformation -Append
            }

            # Close the sesssion to Exhange Online
            Remove-PSSession $O365Session
        }
    }
    End {
        $resultarray
    }
}