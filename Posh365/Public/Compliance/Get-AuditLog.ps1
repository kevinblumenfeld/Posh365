function Get-AuditLog {
    <#
    .SYNOPSIS
        Collects all data from Office 365 Unified Audit Log a specified number of minutes in the past till now

    .DESCRIPTION
        Collects all data from Office 365 Unified Audit Log a specified number of minutes in the past till now

    .PARAMETER Tenant
        Tenant name used to store credentials

    .PARAMETER Path
        Specific path where the file will be saved

    .PARAMETER FileName
        Name of the file to be saved

    .PARAMETER TimeFrameInMinutes
        Data collection specified in number of minutes

    .PARAMETER CSVOutput
        Default output is JSON.  This switch will provide CSV output instead
    
    .PARAMETER DontRenameAndDelete
        Default behavior is to 
        1. delete any existing .old files
        2. rename the existing .json (or .csv) file(s) to .old
        3. create new json (or .csv)
        This switch parameter, prevents steps 1 & 2 from occurring

    .PARAMETER AppendTimeStampToFileName
        This appends the year,month,day & time to the file name

    .EXAMPLE
        Get-AuditLog -Tenant Contoso -Path C:\scripts\ -FileName 365Log -TimeFrameInMinutes 800
    
    .EXAMPLE
        Get-AuditLog -Tenant Contoso -Path C:\scripts\ -FileName 365Log -TimeFrameInMinutes 500 -CSVOutput -AppendTimeStampToFileName
    
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string] $Tenant,
        
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $Path,

        [Parameter(Mandatory = $true)]
        [string] $FileName,

        [Parameter(Mandatory = $true)]
        [string] $TimeFrameInMinutes,
        
        [Parameter()]
        [switch] $CSVOutput,
        
        [Parameter()]
        [switch] $DontRenameAndDelete,

        [Parameter()]
        [switch] $AppendTimeStampToFileName
    )
    Begin {
        try {
            $null = Get-MsolAccountSku -ErrorAction Stop
        }
        Catch {
            Connect-Cloud -Tenant $Tenant -ExchangeOnline
        }
    }
    Process {
        
        $null = New-Item -Path $Path -Type Directory -ErrorAction SilentlyContinue -Force
        
        if ((!$DontRenameAndDelete) -and (!$CSVOutput)) {
            Get-ChildItem -Path $path -Filter *.old | Remove-Item -Force
            Get-ChildItem -Path $path *.json | Rename-Item -NewName { $_.Name -replace '\.json$', '.old'}            
        }
        if ((!$DontRenameAndDelete) -and ($CSVOutput)) {
            Get-ChildItem -Path $path -Filter *.old | Remove-Item -Force
            Get-ChildItem -Path $path *.csv | Rename-Item -NewName { $_.Name -replace '\.csv$', '.old'}            
        }

        $StartDate = (get-date).AddMinutes( - $TimeFrameInMinutes).ToString("MM/dd/yyyy HH:mm")
        $EndDate = (get-date).ToString("MM/dd/yyyy HH:mm")
        $Appenddate = (get-date).ToString("_yyyy_MM_dd-HHmm")

        if ($CSVOutput) {
            if ($AppendTimeStampToFileName) {
                $OutputFile = $Path.ToString().TrimEnd('\') + "\" + $FileName + $Appenddate + ".csv"
            }
            else {
                $OutputFile = $Path.ToString().TrimEnd('\') + "\" + $FileName + ".csv"
            }
        }
        else {
            if ($AppendTimeStampToFileName) {
                $OutputFile = $Path.ToString().TrimEnd('\') + "\" + $FileName + $Appenddate + ".json"
            }
            else {
                $OutputFile = $Path.ToString().TrimEnd('\') + "\" + $FileName + ".json"
            }
        }
        if (!$CSVOutput) {
            $ConvertedOutput = [System.Collections.Generic.List[PSObject]]::New()
            Do {
                $AuditOutput = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -SessionId "1" -SessionCommand ReturnLargeSet
                Foreach ($AuditData in $AuditOutput.AuditData) { 
                    $ConvertedOutput.Add($AuditData)
                }
            } while ($AuditOutput)
        }
        else {
            Do {
                $AuditOutput = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -SessionId "1" -SessionCommand ReturnLargeSet
                $ConvertedOutput = $AuditOutput | Select-Object -ExpandProperty AuditData | ConvertFrom-Json
                $ConvertedOutput | Select-Object CreationTime, UserId, Operation, Workload, ObjectID, SiteUrl, SourceFileName, ClientIP, UserAgent |
                    Export-Csv $OutputFile -NoTypeInformation -Append
            } while ($AuditOutput)
        }
    }
    End {
        if (!$CSVOutput) {
            $ConvertedOutput | Out-File $OutputFile
        }
    }
}