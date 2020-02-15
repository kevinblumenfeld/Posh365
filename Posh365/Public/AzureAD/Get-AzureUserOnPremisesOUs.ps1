function Get-AzureUserOnPremisesOUs {
    [CmdletBinding()]
    param (
    )
    end {
        $AllUsers = Get-AzureADUser -All:$true
        $AllUsers | Select-Object @(
            @{
                Name       = 'Type'
                Expression = { 'User' }
            }
            @{
                Name       = 'OU'
                Expression = { Convert-DistinguishedToCanonical -DistinguishedName ($_.extensionproperty.onPremisesDistinguishedName -replace '^.+?,(?=(OU|CN)=)') }
            }
        ) | Where-Object { $_.OU } | Group-Object Type, OU | Select-Object @(
            'Count'
            @{
                Name       = 'OU'
                Expression = { (($_.Name).split(','))[1].trim() }
            }
            @{
                Name       = 'Type'
                Expression = { (($_.Name).split(','))[0].trim() }
            }
        )
    }
}
