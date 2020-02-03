Function Get-ProxyHash {
    param (
        [Parameter(Mandatory)]
        $ADUserList
    )
    end {
        $ProxyHash = @{ }
        $ADUserList = $ADUserList.where( { $_.ProxyAddresses })
        foreach ($ADUser in $ADUserList) {
            foreach ($Proxy in $ADUser.ProxyAddresses) {
                $ProxyHash[$Proxy] = @{
                    DisplayName       = $ADUser.DisplayName
                    UserPrincipalName = $ADUser.UserPrincipalName
                }
            }
        }
        $ProxyHash
    }
}
