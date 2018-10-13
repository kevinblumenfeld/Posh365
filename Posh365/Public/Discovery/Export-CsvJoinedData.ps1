function Export-CsvJoinedData { 
    <#
.SYNOPSIS
Export specified column from a CSV and output one per line and join append it with text (usually a domain).  Filtering if desired.  Automatically a csv will be exported.

.DESCRIPTION
Export specified column from a CSV and output one per line.  Filtering if desired.  Automatically a csv will be exported.

.PARAMETER Row
Parameter description

.PARAMETER FilterColumn
Parameter description

.PARAMETER FilterWhereAttributeIs
Parameter description

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-CsvJoinedData

.NOTES

#>
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (

        [Parameter()]
        [string]$ReportPath,
        
        [Parameter(Mandatory = $true)]
        [string]$FileName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Alias", "mailNickname", "ProxyAddresses", "EmailAddresses", "EmailAddress", "AddressOrMember", "x500", "UserPrincipalName", "PrimarySmtpAddress", "MembersName", "Member", "Members", "MemberOf")]
        [String]$FindInColumn,

        [Parameter(Mandatory = $true)]
        [string]$AddSuffix,

        [Parameter()]
        [string]$FilterColumn,

        [Parameter()]
        [string]$FilterWhereAttributeIs,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row        

    )
    begin {
        if ($FilterColumn -and (! $FilterWhereAttributeIs)) {
            Write-Warning "Must use FilterWhereAttributeIs parameter when specifying FilterColumn parameter"
            break
        }
        if ($FilterWhereAttributeIs -and (! $FilterColumn)) {
            Write-Warning "Must use FilterColumn parameter when specifying FilterWhereAttributeIs parameter"
            break
        }

        if (-not $ReportPath) {
            $ReportPath = '.\'
            $theReport = $ReportPath | Join-Path -ChildPath $FileName
        }
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
        $theReport = $ReportPath | Join-Path -ChildPath $FileName
    }
    process {
        ForEach ($CurRow in $Row) {
            $found = $CurRow."$FindInColumn"
            if ((-not $Row."$FilterColumn" -eq $Row."$FilterWhereAttributeIs") -or [String]::IsNullOrWhiteSpace($found)) {
                Continue
            }
            # Add Error Handling for more than one SMTP:
            $Display = $CurRow.Displayname
            $RecipientTypeDetails = $CurRow.RecipientTypeDetails
            $PrimarySmtpAddress = $CurRow.PrimarySmtpAddress
            $objectGUID = $CurRow.objectGUID
            $OU = $CurRow.OU
            $UserPrincipalName = $CurRow.UserPrincipalName
            $msExchRecipientTypeDetails = $CurRow.msExchRecipientTypeDetails
            $mail = $CurRow.mail
            $Address = $found | ForEach-Object {
                '{0}{1}' -f $_, $AddSuffix
            }
            if ($Address) {
                foreach ($CurAddress in $Address) {
                    [PSCustomObject]@{
                        DisplayName                = $Display
                        OU                         = $OU
                        UserPrincipalName          = $UserPrincipalName
                        Found                      = $found
                        PrimarySmtpAddress         = $PrimarySmtpAddress
                        Joined                     = $CurAddress
                        RecipientTypeDetails       = $RecipientTypeDetails
                        msExchRecipientTypeDetails = $msExchRecipientTypeDetails
                        objectGUID                 = $objectGUID
                    } | Export-Csv $theReport -Append -NoTypeInformation -Encoding UTF8
                } 
            }
            else {
                [PSCustomObject]@{
                    DisplayName                = $Display
                    OU                         = $OU
                    UserPrincipalName          = $UserPrincipalName
                    Found                      = $found
                    PrimarySmtpAddress         = $PrimarySmtpAddress
                    Joined                     = $null
                    RecipientTypeDetails       = $RecipientTypeDetails
                    msExchRecipientTypeDetails = $msExchRecipientTypeDetails
                    objectGUID                 = $objectGUID
                } | Export-Csv $theReport -Append -NoTypeInformation -Encoding UTF8
            }
        }
    }
    end {

    }
}
