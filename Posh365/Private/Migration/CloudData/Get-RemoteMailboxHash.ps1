function Get-RemoteMailboxHash {
    [CmdletBinding()]
    param (
    )

    $OnPremList = Get-RemoteMailbox -ResultSize Unlimited
    $OnHash = @{ }
    foreach ($On in $OnPremList) {
        $OnHash[$On.UserPrincipalName] = @{
            'Identity'            = $On.Identity
            'DisplayName'         = $On.DisplayName
            'Name'                = $On.Name
            'SamAccountName'      = $On.SamAccountName
            'WindowsEmailAddress' = $On.WindowsEmailAddress
            'PrimarySmtpAddress'  = $On.PrimarySmtpAddress
            'OrganizationalUnit'  = $On.OnPremisesOrganizationalUnit
            'ExchangeGuid'        = ($On.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($On.ArchiveGuid).ToString()
        }
    }
}