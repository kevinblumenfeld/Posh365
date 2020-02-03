Function Get-LegacyDNHash {
    param (
        [Parameter(Mandatory)]
        $ADUserList
    )
    end {
        $LegacyDNHash = @{ }
        $ADUserList = $ADUserList.where( { $_.LegacyExchangeDNHash })
        foreach ($ADUser in $ADUserList) {
            $LegacyDNHash[$ADUser.LegacyExchangeDN] = @{
                DisplayName       = $ADUser.DisplayName
                UserPrincipalName = $ADUser.UserPrincipalName
            }
        }
        $LegacyDNHash
    }
}
