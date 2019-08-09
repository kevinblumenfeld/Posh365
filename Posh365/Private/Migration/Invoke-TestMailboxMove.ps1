function Invoke-TestMailboxMove {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList
    )
    end {
        $AcceptedDomains = (Get-AcceptedDomain).DomainName
        $RoutingAddress = $AcceptedDomains -match '.mail.onmicrosoft.com'
        foreach ($User in $UserList) {
            $Error = [System.Collections.Generic.List[string]]::New()
            $PreFlightHash = @{
                'DisplayName'       = $User.DisplayName
                'UserPrincipalName' = $User.UserPrincipalName
            }
            try {
                $MailUser = Get-MailUser -Identity $User.UserPrincipalName -ErrorAction Stop
                $BadEmail = [System.Collections.Generic.List[string]]::New()
                foreach ($Email in $MailUser.EmailAddresses) {
                    $UserDomain = [regex]::matches($Email, '(?<=@)(.*)').value
                    if ($UserDomain -notin $AcceptedDomains) {
                        $BadEmail.Add($Email)
                    }
                }
                if (-not $BadEmail) {
                    $PreFlightHash.Add('EmailAddressesValid', 'True')
                }
                else {
                    $Error.Add($BadEmail -join ',')
                    $PreFlightHash.Add('EmailAddressesValid', 'False')
                }
                if ($UserDomain -contains $RoutingAddress) {
                    $PreFlightHash.Add('RoutingAddressValid', 'True')
                }
                else {
                    $PreFlightHash.Add('RoutingAddressValid', 'False')
                }
                # Account Disabled
                # UpnMatchPrimarySmtp
                $PreFlightHash.Add('IsDirSynced', $MailUser.IsDirSynced)
                $PreFlightHash.Add('AccountDisabled', $MailUser.AccountDisabled)
                $PreFlightHash.Add('MailboxExists', 'False')
            }
            catch {
                if ($null = Get-Mailbox -Identity $User.UserPrincipalName -ErrorAction silentlycontinue) {
                    $PreFlightHash.Add('MailboxExists', 'True')
                    $Error.Add('NoMailUserFound')
                }
                else {
                    $PreFlightHash.Add('MailboxExists', 'False')
                    $Error.Add('NoMailUserOrMailboxFound')
                }
            }
        }
    }
}
