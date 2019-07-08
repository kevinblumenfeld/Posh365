Function Get-ADHashDisplayName {

    param (
        [parameter(ValueFromPipeline = $true)]
        $ADUserList
    )
    begin {
        $ADHashDisplayName = @{ }
    }
    process {
        foreach ($ADUser in $ADUserList) {
            $ADHashDisplayName[$ADUser.DisplayName] = @{
                UserPrincipalName          = $ADUser.UserPrincipalName
                PrimarySMTPAddress         = $ADUser.PrimarySMTPAddress
                msExchRecipientTypeDetails = $ADUser.msExchRecipientTypeDetails
                msExchRecipientDisplayType = $ADUser.msExchRecipientDisplayType
            }
        }
    }
    end {
        $ADHashDisplayName
    }
}
