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
                $PreFlightHash.Add('MailboxExists', 'False')
                $PreFlightHash.Add('IsDirSynced', $MailUser.IsDirSynced)
                $PreFlightHash.Add('AccountDisabled', $MailUser.AccountDisabled)
                if ($MailUser.AccountDisabled -and $User.RecipientTypeDetails -eq 'UserMailbox') {
                    $Error.Add('AccountDisabledforUserMailbox')
                }
                if ($UserDomain -contains $RoutingAddress) {
                    $PreFlightHash.Add('RoutingAddressValid', 'True')
                }
                else {
                    $PreFlightHash.Add('RoutingAddressValid', 'False')
                    $Error.Add('NoRoutingAddress')
                }
                if ($MailUser.WindowsEmailAddress -eq $MailUser.UserPrincipalName) {
                    $PreFlightHash.Add('UpnMatchesPrimarySmtp', 'True')
                }
                else {
                    $PreFlightHash.Add('UpnMatchesPrimarySmtp', 'False')
                    $Error.Add('UpnDoesNotMatchPrimarySmtp')
                }
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
            [PSCustomObject]$PreFlightHash
        }
    }
}
