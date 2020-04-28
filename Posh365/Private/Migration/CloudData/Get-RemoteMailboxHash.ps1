function Get-RemoteMailboxHash {
    [CmdletBinding()]
    param (
        [Parameter()]
        $RemoteMailboxList,

        [Parameter()]
        [ValidateSet('Guid', 'UserPrincipalName')]
        $Key
    )

    $RMHash = @{ }
    if ($Key -eq 'Guid') {
        foreach ($RM in $RemoteMailboxList) {
            $RMHash[$RM.Guid.ToString()] = @{
                DisplayName               = $RM.DisplayName
                EmailAddressPolicyEnabled = $RM.EmailAddressPolicyEnabled
                OrganizationalUnit        = $RM.OnPremisesOrganizationalUnit
                Alias                     = $RM.Alias
                PrimarySmtpAddress        = $RM.PrimarySmtpAddress
                EmailCount                = $RM.EmailAddresses.Count
                AllEmailAddresses         = @($RM.EmailAddresses) -ne '' -join '|'
                EmailAddresses            = @($RM.EmailAddresses) -match 'smtp:' -join '|'
                EmailAddressesNotSmtp     = @($RM.EmailAddresses) -notmatch 'smtp:' -join '|'
            }
        }
    }
    if ($Key -eq 'UserPrincipalName') {
        foreach ($RM in $RemoteMailboxList) {
            $RMHash[$RM.UserPrincipalName] = @{
                Identity              = $RM.Identity
                DisplayName           = $RM.DisplayName
                Name                  = $RM.Name
                SamAccountName        = $RM.SamAccountName
                WindowsEmailAddress   = $RM.WindowsEmailAddress
                PrimarySmtpAddress    = $RM.PrimarySmtpAddress
                OrganizationalUnit    = $RM.OnPremisesOrganizationalUnit
                ExchangeGuid          = ($RM.ExchangeGuid).ToString()
                ArchiveGuid           = ($RM.ArchiveGuid).ToString()
                EmailCount            = $RM.EmailAddresses.Count
                AllEmailAddresses     = @($RM.EmailAddresses) -ne '' -join '|'
                EmailAddresses        = @($RM.EmailAddresses) -match 'smtp:' -join '|'
                EmailAddressesNotSmtp = @($RM.EmailAddresses) -notmatch 'smtp:' -join '|'
            }
        }
    }
    $RMHash
}