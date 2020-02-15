function Get-ExchangeReceiveConnector {
    <#
    .SYNOPSIS
    Export on-premises Receive Connectors

    .DESCRIPTION
    Export on-premises Receive Connectors

    .PARAMETER ViewEntireForest
    Include entire forest when querying Exchange

    .EXAMPLE
    Get-ExchangeReceiveConnector | Export-Csv c:\scripts\RecCons.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $ViewEntireForest
    )
    Begin {
        if ($ViewEntireForest) {
            Set-ADServerSettings -ViewEntireForest:$True
        }
        Get-ReceiveConnector | Select-Object @(
            'Identity'
            'Server'
            'Enabled'
            @{
                Name       = 'Port'
                Expression = { [regex]::Matches($_.Bindings, "[^:]*$").value[0] }
            }
            @{
                Name       = 'RemoteIPRanges'
                Expression = { @($_.RemoteIPRanges) -ne '' -join '|' }
            }
            'TlsCertificateName'
            'RequireTLS'
            'TlsDomainCapabilities'
            'PermissionGroups'
            'AuthMechanism'
            'MaxMessageSize'
            'Guid'
            @{
                Name       = 'Bindings'
                Expression = { @($_.Bindings) -ne '' -join '|' }
            }
        )
    }
    Process {

    }
    End {

    }
}
