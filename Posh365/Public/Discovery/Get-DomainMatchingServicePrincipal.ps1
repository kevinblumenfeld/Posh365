function Get-DomainMatchingServicePrincipal {
    [CmdletBinding()]
    param (

    )
    end {
        $DomainList = (Get-MsolDomain).name.foreach{ [regex]::Escape($_) } -join '|'
        $SPNList = Get-MsolServicePrincipal -All

        $SPNList.Where{ $_.ServicePrincipalNames -match $DomainList } | Select-Object @(
            @{
                Name       = 'DisplayName'
                Expression = { $_.DisplayName }
            }
            @{
                Name       = "AccountEnabled"
                Expression = { $_.AccountEnabled }
            }
            @{
                Name       = "ServicePrincipalName"
                Expression = { ($_.ServicePrincipalNames).Where{ $_ -match $DomainList } }
            }
        )
    }
}
