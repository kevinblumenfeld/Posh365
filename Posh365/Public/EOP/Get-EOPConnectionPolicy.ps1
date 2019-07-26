function Get-EOPConnectionPolicy {
    [CmdletBinding()]
    param (
    )
    end {
        Get-HostedConnectionFilterPolicy | Select-Object @(
            'Name'
            'Identity'
            'EnableSafeList'
            'IsDefault'
            'IsValid'
            @{
                Name       = 'IPAllowList'
                Expression = { @($_.IPAllowList) -ne '' -join '|' }
            }
            @{
                Name       = 'IPBlockList'
                Expression = { @($_.IPBlockList) -ne '' -join '|' }
            }
            'AdminDisplayName'
            'DirectoryBasedEdgeBlockMode'
            'ObjectState'
            'OrganizationId'
            'WhenChanged'
            'WhenChangedUTC'
            'WhenCreated'
            'WhenCreatedUTC'
            'ExchangeObjectId'
            'Guid'
            'Id'
        )
    }
}

