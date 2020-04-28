function Select-DisableMailboxEmailAddressPolicy {
    [CmdletBinding()]
    param (
        [Parameter()]
        $RemoteMailboxList
    )
    $Count = @($RemoteMailboxList).Count
    $i = 0
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
