function Select-SetmsExchVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        $RemoteMailboxList,

        [Parameter()]
        $UserHash
    )
    $Count = $RemoteMailboxList.Count
    $i = 0
    foreach ($RemoteMailbox in $RemoteMailboxList) {
        $i++
        [PSCustomObject]@{
            Count                        = '[{0} of {1}]' -f $i, $Count
            msExchVersion                = $UserHash[$RemoteMailbox.Guid.ToString()]
            DisplayName                  = $RemoteMailbox.DisplayName
            EmailAddressPolicyEnabled    = $RemoteMailbox.EmailAddressPolicyEnabled
            OnPremisesOrganizationalUnit = $RemoteMailbox.OnPremisesOrganizationalUnit
            Alias                        = $RemoteMailbox.Alias
            PrimarySmtpAddress           = $RemoteMailbox.PrimarySmtpAddress
            EmailCount                   = $RemoteMailbox.EmailAddresses.Count
            EmailAddresses               = @($RemoteMailbox.EmailAddresses) -match 'smtp:' -join '|'
            EmailAddressesNotSmtp        = @($RemoteMailbox.EmailAddresses) -notmatch 'smtp:' -join '|'
            Guid                         = $RemoteMailbox.Guid.ToString()
        }
    }
}
