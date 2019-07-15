Function Get-ADHashCN {
    param (
        [parameter(ValueFromPipeline = $true)]
        $ADUserList
    )
    begin {
        $ADHashCN = @{ }
    }
    process {
        foreach ($ADUser in $ADUserList) {
            $ADHashCN[$ADUser.CanonicalName] = @{
                DisplayName                = $ADUser.DisplayName
                UserPrincipalName          = $ADUser.UserPrincipalName
                Logon                      = $ADUser.logon
                PrimarySMTPAddress         = $ADUser.PrimarySMTPAddress
                msExchRecipientTypeDetails = $ADUser.msExchRecipientTypeDetails
                msExchRecipientDisplayType = $ADUser.msExchRecipientDisplayType
            }
        }
    }
    end {
        $ADHashCN
    }
}
