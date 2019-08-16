function Get-OnlineServicePrincipal {
    [CmdletBinding()]
    param (

    )
    end {
        $DomainList = (Get-MsolDomain).name
        $SPNList = Get-MsolServicePrincipal -All
        foreach ($SPN in $SPNList) {
            foreach ($Domain in $DomainList) {
                foreach ($Name in $SPN.serviceprincipalnames) {
                    if ($Name -match $Domain) {
                        [PSCustomObject]@{
                            DisplayName          = $SPN.DisplayName
                            AccountEnabled       = $SPN.AccountEnabled
                            ServicePrincipalName = $Name
                        }
                    }
                }
            }
        }
    }
}
