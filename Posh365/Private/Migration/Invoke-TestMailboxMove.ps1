function Invoke-TestMailboxMove {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter()]
        [switch]
        $SkipUpnMatchSmtpTest
    )
    end {
        $Protocol = @('smtp')
        $AcceptedDomains = (Get-AcceptedDomain).DomainName
        $RoutingAddress = $AcceptedDomains -like '*.mail.onmicrosoft.*'
        foreach ($User in $UserList) {
            $TestError = [System.Collections.Generic.List[string]]::New()
            $PreFlightHash = @{
                'BatchName'          = $User.BatchName
                'DisplayName'        = $User.DisplayName
                'UserPrincipalName'  = $User.UserPrincipalName
                'OrganizationalUnit' = $User.OrganizationalUnit
            }
            $ErrorValue = [System.Collections.Generic.List[string]]::New()
            try {
                $MailUser = Get-MailUser -Identity $User.PrimarySmtpAddress -ErrorAction Stop
                $PreFlightHash.Add('MailboxType', $User.RecipientTypeDetails)
                $BadEmail = [System.Collections.Generic.List[string]]::New()
                foreach ($Email in $MailUser.EmailAddresses) {
                    $UserDomain = [regex]::matches($Email, '(?<=@)(.*)').value
                    if ($UserDomain -notin $AcceptedDomains -and $UserDomain.length -gt 0 -and ($Email.split(':')[0] -in $Protocol)) {
                        $BadEmail.Add($Email)
                    }
                }
                if (-not $BadEmail) {
                    $PreFlightHash.Add('EmailAddressesValid', $true)
                }
                else {
                    $TestError.Add('InvalidEmail')
                    $ErrorValue.Add($BadEmail -join ',')
                    $PreFlightHash.Add('EmailAddressesValid', $false)
                }
                $PreFlightHash.Add('MailboxExists', $false)
                $PreFlightHash.Add('IsDirSynced', $MailUser.IsDirSynced)
                $PreFlightHash.Add('AccountDisabled', $MailUser.AccountDisabled)
                if ($MailUser.AccountDisabled -and $User.RecipientTypeDetails -eq 'UserMailbox') {
                    $TestError.Add('AccountDisabledforUserMailbox')
                }
                if ($MailUser.EmailAddresses -match $RoutingAddress) {
                    $PreFlightHash.Add('RoutingAddressValid', $true)
                }
                else {
                    $PreFlightHash.Add('RoutingAddressValid', $false)
                    $TestError.Add('NoRoutingAddress')
                }
                if ($MailUser.WindowsEmailAddress -eq $MailUser.UserPrincipalName -or $SkipUpnMatchSmtpTest) {
                    $PreFlightHash.Add('UpnMatchesPrimarySmtp', $true)
                }
                else {
                    $PreFlightHash.Add('UpnMatchesPrimarySmtp', $false)
                    $TestError.Add('UpnDoesNotMatchPrimarySmtp')
                    $ErrorValue.Add(('{0}/{1}' -f $MailUser.WindowsEmailAddress, $MailUser.UserPrincipalName))
                }
            }
            catch {
                if ($Mailbox = Get-Mailbox -Identity $User.PrimarySmtpAddress -ErrorAction silentlycontinue) {
                    $PreFlightHash.Add('MailboxType', $Mailbox.RecipientTypeDetails)
                    $PreFlightHash.Add('AccountDisabled', $Mailbox.AccountDisabled)
                    $PreFlightHash.Add('IsDirSynced', $Mailbox.IsDirSynced)
                    $BadEmail = [System.Collections.Generic.List[string]]::New()
                    foreach ($Email in $Mailbox.EmailAddresses) {
                        $UserDomain = [regex]::matches($Email, '(?<=@)(.*)').value
                        if ($UserDomain -notin $AcceptedDomains -and $UserDomain.length -gt 0 -and ($Email.split(':')[0] -in $Protocol)) {
                            $BadEmail.Add($Email)
                        }
                    }
                    if (-not $BadEmail) {
                        $PreFlightHash.Add('EmailAddressesValid', $true)
                    }
                    else {
                        $TestError.Add('InvalidEmail')
                        $ErrorValue.Add($BadEmail -join ',')
                        $PreFlightHash.Add('EmailAddressesValid', $false)
                    }
                    if ($Mailbox.emailaddresses -match $RoutingAddress) {
                        $PreFlightHash.Add('RoutingAddressValid', $true)
                    }
                    else {
                        $PreFlightHash.Add('RoutingAddressValid', $false)
                    }
                    $PreFlightHash.Add('UpnMatchesPrimarySmtp', $mailbox.PrimarySmtpAddress -eq $mailbox.UserPrincipalName)
                    $PreFlightHash.Add('MailboxExists', $true)
                    $TestError.Add('MailboxFound')
                    $ErrorValue.Add('MailboxCreated:{0}' -f $Mailbox.WhenCreated)
                }
                else {
                    $PreFlightHash.Add('MailboxType', $false)
                    $PreFlightHash.Add('IsDirSynced', $false)
                    $PreFlightHash.Add('EmailAddressesValid', $false)
                    $PreFlightHash.Add('RoutingAddressValid', $false)
                    $PreFlightHash.Add('UpnMatchesPrimarySmtp', $false)
                    $PreFlightHash.Add('MailboxExists', $false)
                    $TestError.Add('NoMailUserOrMailboxFound')
                }
            }
            if ($TestError) {
                $PreFlightHash.Add('Result', 'FAIL')
            }
            else {
                $PreFlightHash.Add('Result', 'PASS')
            }
            if ($ErrorValue) {
                $PreFlightHash.Add('ErrorValue', $ErrorValue -join '|')
            }
            else {
                $PreFlightHash.Add('ErrorValue', $_.Exception.Message)
            }
            $PreFlightHash.Add('ErrorType', $TestError -join '|')
            [PSCustomObject]$PreFlightHash
        }
    }
}
