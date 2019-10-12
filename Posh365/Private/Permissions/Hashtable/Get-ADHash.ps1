Function Get-ADHash {
    param (
        [parameter(ValueFromPipeline = $true)]
        $ADUserList
    )
    begin {
        $ADHash = @{ }
    }
    process {
        foreach ($ADUser in $ADUserList) {
            $ADHash[$ADUser.logon] = @{
                DisplayName                = $ADUser.DisplayName
                UserPrincipalName          = $ADUser.UserPrincipalName
                PrimarySMTPAddress         = $ADUser.PrimarySMTPAddress
                msExchRecipientTypeDetails = $ADUser.msExchRecipientTypeDetails
                msExchRecipientDisplayType = $ADUser.msExchRecipientDisplayType
                Objectguid                 = $ADUser.Objectguid
                objectClass                = $ADUser.objectClass
            }
        }
    }
    end {
        $ADHash
    }
}
