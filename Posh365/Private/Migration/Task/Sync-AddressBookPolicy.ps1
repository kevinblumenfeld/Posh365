function Sync-AddressBookPolicy {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $UserList
    )
    process {
        foreach ($User in $UserList) {
            Set-Mailbox -Identity $User.UserPrincipalName -AddressBookPolicy $User.AddressBookPolicy
        }
    }
}
