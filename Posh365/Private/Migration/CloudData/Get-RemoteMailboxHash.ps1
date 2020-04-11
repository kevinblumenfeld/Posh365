function Get-RemoteMailboxHash {
    [CmdletBinding()]
    param (
    )

    $RemoteSelect = @(
        'UserPrincipalName', 'Identity', 'DisplayName'
        'Name', 'SamAccountName', 'WindowsEmailAddress'
        'PrimarySmtpAddress', 'OnPremisesOrganizationalUnit'
        'ExchangeGuid', 'ArchiveGuid'
    )

    $OnPremList = Get-RemoteMailbox -ResultSize Unlimited | Select-Object $RemoteSelect
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
    $OnHash
}