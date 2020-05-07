function Select-DisableMailboxEmailAddressPolicy {
    [CmdletBinding()]
    param (
        [Parameter()]
        $RemoteMailboxList,

        [Parameter()]
        [Hashtable]
        $BadPolicyHash
    )
    $Count = @($RemoteMailboxList).Count
    $i = 0
    if ($BadPolicyHash) {
        foreach ($RemoteMailbox in $RemoteMailboxList) {
            if ($RemoteMailbox.EmailAddressPolicyEnabled -or $BadPolicyHash.ContainsKey($RemoteMailbox.Guid.ToString())) {
                $i++
                [PSCustomObject]@{
                    Num                       = '[{0} of {1}]' -f $i, $Count
                    DisplayName               = $RemoteMailbox.DisplayName
                    EmailAddressPolicyEnabled = $RemoteMailbox.EmailAddressPolicyEnabled
                    msExchPoliciesIncluded    = if ($In = $BadPolicyHash[$RemoteMailbox.Guid.ToString()]['msExchPoliciesIncluded']) {$In} else {''}
                    msExchPoliciesExcluded    = if ($Ex = $BadPolicyHash[$RemoteMailbox.Guid.ToString()]['msExchPoliciesExcluded']) {$Ex} else {''}
                    OrganizationalUnit        = $RemoteMailbox.OnPremisesOrganizationalUnit
                    Alias                     = $RemoteMailbox.Alias
                    PrimarySmtpAddress        = $RemoteMailbox.PrimarySmtpAddress
                    EmailCount                = $RemoteMailbox.EmailAddresses.Count
                    AllEmailAddresses         = @($RemoteMailbox.EmailAddresses) -ne '' -join '|'
                    EmailAddresses            = @($RemoteMailbox.EmailAddresses) -match 'smtp:' -join '|'
                    EmailAddressesNotSmtp     = @($RemoteMailbox.EmailAddresses) -notmatch 'smtp:' -join '|'
                    UserPrincipalName         = $BadPolicyHash[$RemoteMailbox.Guid.ToString()]['UserPrincipalName']
                    Guid                      = $RemoteMailbox.Guid
                }
            }
        }
    }
    else {
        foreach ($RemoteMailbox in $RemoteMailboxList) {
            $i++
            [PSCustomObject]@{
                Num                       = '[{0} of {1}]' -f $i, $Count
                DisplayName               = $RemoteMailbox.DisplayName
                EmailAddressPolicyEnabled = $RemoteMailbox.EmailAddressPolicyEnabled
                OrganizationalUnit        = $RemoteMailbox.OnPremisesOrganizationalUnit
                Alias                     = $RemoteMailbox.Alias
                PrimarySmtpAddress        = $RemoteMailbox.PrimarySmtpAddress
                EmailCount                = $RemoteMailbox.EmailAddresses.Count
                EmailAddresses            = @($RemoteMailbox.EmailAddresses) -match 'smtp:' -join '|'
                EmailAddressesNotSmtp     = @($RemoteMailbox.EmailAddresses) -notmatch 'smtp:' -join '|'
                Guid                      = $RemoteMailbox.Guid.ToString()
            }
        }
    }
}
