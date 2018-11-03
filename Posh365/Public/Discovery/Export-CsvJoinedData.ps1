function Export-CsvJoinedData { 
    <#
.SYNOPSIS
Export specified column from a CSV and output one per line and join append it with text (usually a domain).  Filtering if desired.  Automatically a csv will be exported.

.DESCRIPTION
Export specified column from a CSV and output one per line.  Filtering if desired.  Automatically a csv will be exported.

.PARAMETER Row
Parameter description

.PARAMETER Filter
Parameter description

.PARAMETER Exclude
Parameter description

.EXAMPLE
Import-Csv .\CSVofADUsers.csv | Export-CsvJoinedData

.EXAMPLE
Import-Csv .\AllMbxs.csv | Export-CsvJoinedData -ReportPath C:\scripts -FileName "test.csv" -FindInColumn Alias -AddSuffix '@contoso.mail.onmicrosoft.com' -AddPrefix "smtp:" -Filter "EmailAddressPolicyEnabled" -Exclude "FALSE" -ExcludeSystemMailboxes



SystemMailbox
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

        [Parameter()]
        [string]$AddPrefix,

        [Parameter()]
        [string]$AddSuffix,

        [Parameter()]
        [string]$Filter,

        [Parameter()]
        [string]$Exclude,

        [Parameter()]
        [switch]$ExcludeSystemMailboxes,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row        

    )
    begin {
        if (-not ($AddPrefix -or $AddSuffix)) {
            Write-Warning "Please choose either -AddPrefix and/or -AddSuffix to Join data to what is found in -FindInColumn"
            break
        }
        if ($Filter -and (! $Exclude)) {
            Write-Warning "Must use Exclude parameter when specifying Filter parameter"
            break
        }
        if ($Exclude -and (! $Filter)) {
            Write-Warning "Must use Filter parameter when specifying Exclude parameter"
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
            $UserPrincipalName = $CurRow.UserPrincipalName
            $CurFilter = $CurRow."$Filter"
            if ($CurFilter -eq $Exclude -or [String]::IsNullOrWhiteSpace($found)) {
                Continue
            }
            if ($ExcludeSystemMailboxes -and 
                (
                    $UserPrincipalName -like "HealthMailbox*" -or
                    $UserPrincipalName -like "SystemMailbox{*" -or 
                    $UserPrincipalName -like "Migration.8f3e7716*" -or
                    $UserPrincipalName -like "DiscoverySearchMailbox*" -or
                    $UserPrincipalName -like "FederatedEmail.4c1f4d8b*"
                )) {
                Continue
            }
            # Add Error Handling for more than one SMTP:
            $Display = $CurRow.Displayname
            $RecipientTypeDetails = $CurRow.RecipientTypeDetails
            $PrimarySmtpAddress = $CurRow.PrimarySmtpAddress
            $objectGUID = $CurRow.objectGUID
            $OU = $CurRow.OU
            $msExchRecipientTypeDetails = $CurRow.msExchRecipientTypeDetails
            $mail = $CurRow.mail
            if ($AddPrefix) {
                $Address = $found | ForEach-Object {
                    '{0}{1}' -f $AddPrefix, $_
                }
            }
            if ($AddSuffix) {
                $Address = $Address | ForEach-Object {
                    '{0}{1}' -f $_, $AddSuffix
                }
            }
            if ($Address) {
                foreach ($CurAddress in $Address) {
                    [PSCustomObject]@{
                        DisplayName                = $Display
                        UserPrincipalName          = $UserPrincipalName
                        Found                      = $found
                        Joined                     = $CurAddress
                        OU                         = $OU
                        PrimarySmtpAddress         = $PrimarySmtpAddress
                        RecipientTypeDetails       = $RecipientTypeDetails
                        msExchRecipientTypeDetails = $msExchRecipientTypeDetails
                        objectGUID                 = $objectGUID
                    } | Export-Csv $theReport -Append -NoTypeInformation -Encoding UTF8
                } 
            }
            else {
                [PSCustomObject]@{
                    DisplayName                = $Display
                    UserPrincipalName          = $UserPrincipalName
                    Found                      = $found
                    Joined                     = ""
                    OU                         = $OU
                    PrimarySmtpAddress         = $PrimarySmtpAddress
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
