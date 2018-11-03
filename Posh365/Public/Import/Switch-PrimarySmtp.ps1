function Switch-PrimarySmtp {
    
    <#
    .SYNOPSIS
    Converts an email address to the primary smtp address when it matches a specified search criteria. Run in EMS.

    .DESCRIPTION
    Converts an email address to the primary smtp address when it matches a specified search criteria. Run from Exchange Management Shell.
    Based on a list of users specified at runtime, this script is designed to find one email per mailbox that matches a search
    criteria (like contoso.com) and convert it to the primary smtp address.
    The existing primary smtp address will automatically become a secondary stmp address.

    .PARAMETER ImportList
    This list should be a single column of one of these attributes

    * GUID
    * Distinguished name (DN)
    * Domain\Account
    * User principal name (UPN)
    * LegacyExchangeDN
    * SmtpAddress
    * Alias

    .PARAMETER LogFilePath
    The location of the log file

    .PARAMETER ConvertToPrimaryWhenAddressContains
    This is the search criteria to find the email address. The address found will be converted to primary email address

    .PARAMETER DisableEmailAddressPolicy
    Prior to switching primary email address, disables the mailbox's Email Address Policy

    .PARAMETER MailboxType
    Choose to alter either mailboxes or remote mailboxes

    .EXAMPLE
    Switch-PrimarySmtp -ImportList "C:\scripts\allusers.csv" -LogFilePath "C:\scripts" -ConvertToPrimaryWhenAddressContains "contoso.com" -MailboxType RemoteMailbox

    .EXAMPLE
    Switch-PrimarySmtp -ImportList "C:\listofusers.csv" -LogFilePath "C:\scripts" -DisableEmailAddressPolicy -ConvertToPrimaryWhenAddressContains "microsoft.com" -MailboxType RemoteMailbox -DisableEmailAddressPolicy

    .NOTES
    General notes
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(Mandatory = $true)]
        [string] $ImportList,

        [Parameter(Mandatory = $true)]
        [string] $LogFilePath,

        [Parameter(Mandatory = $true)]
        [String] $ConvertToPrimaryWhenAddressContains,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Mailbox", "RemoteMailbox")]
        [String] $MailboxType,

        [Parameter()]
        [Switch] $DisableEmailAddressPolicy

    )

    $User = Get-Content $ImportList 

    $headerstring = ("Result" + "," + "DisplayName" + "," + "UserPrincipalName" + "," + "CurrentPrimary" + "," + "NewPrimary" + "," + "Message")

    $Log = Join-Path $LogFilePath "Log.csv"

    Out-File -FilePath $Log -InputObject $headerstring -Encoding UTF8 -Append

    $Props = @(
        'DisplayName', 'UserprincipalName'
    )

    $Calc = @(
        @{n = "CurrentPrimary" ; e = {( $_.emailaddresses | Where-Object {$_ -cmatch "SMTP:"})}},
        @{n = "MakePrimary" ; e = {( $_.emailaddresses | Where-Object {$_ -match "$ConvertToPrimaryWhenAddressContains"}) -join ";" }}
    )

    $User | ForEach-Object {

        $CurUser = $_

        try {

            $Mailbox = & "Get-$MailboxType" -identity $_ -ErrorAction Stop |
                Where {$_.EmailAddresses -match "$ConvertToPrimaryWhenAddressContains"}

        }
        
        catch {

            $WhyFailed = $_.Exception.Message
            'GET_FAILED' + "," + $DisplayName + "," + $UserPrincipalName + "," + $CurrentPrimary + "," + $NewPrimary + "," + $WhyFailed |
                Out-file $Log -Encoding UTF8 -Append

            Write-Warning "$CurUser `t $WhyFailed"
            continue

        }

        $Convert = $Mailbox | Select ($Props + $Calc)

        ForEach ($CurConvert in $Convert) {

            $DisplayName = $CurConvert | Select -ExpandProperty DisplayName
            $UserPrincipalName = $CurConvert | Select -ExpandProperty UserPrincipalName

            $CurrentPrimaryRaw = $CurConvert | Select -ExpandProperty CurrentPrimary
            $CurrentPrimary = $CurrentPrimaryRaw -replace ('smtp:', '')

            $NewPrimaryRaw = $CurConvert | Select -ExpandProperty MakePrimary
            $NewPrimary = $NewPrimaryRaw -replace ('smtp:', '')
            $NewPrimaryCount = ($NewPrimaryRaw -split ';').count

            Write-Host "Processing: `t $DisplayName $NewPrimary"

            if ($NewPrimaryCount -gt "1") {

                Write-Warning "$UserPrincipalName `t Skipped. Search criteria matches too many of user's email addresses"
                continue

            }

            try {
                if ($DisableEmailAddressPolicy) {

                    & "Set-$MailboxType" -identity $UserPrincipalName -EmailAddressPolicyEnabled:$false -ErrorAction Stop

                }

                & "Set-$MailboxType" -identity $UserPrincipalName -PrimarySmtpAddress $NewPrimary -ErrorAction Stop
                
                'SUCCESS' + "," + $DisplayName + "," + $UserPrincipalName + "," + $CurrentPrimary + "," + $NewPrimary + "," + "Success" | 
                    Out-file $Log -Encoding UTF8 -Append

            }
            catch {

                $WhyFailed = $_.Exception.Message

                'SET_FAILED' + "," + $DisplayName + "," + $UserPrincipalName + "," + $CurrentPrimary + "," + $NewPrimary + "," + $WhyFailed |
                    Out-file $Log -Encoding UTF8 -Append
                
                Write-Warning "$UserPrincipalName `t $WhyFailed"

            }
        }
    }    
}