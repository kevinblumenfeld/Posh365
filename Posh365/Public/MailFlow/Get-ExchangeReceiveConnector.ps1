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
                Name       = 'RemoteIPRanges'
                Expression = { [string]::join("|", [String[]]$_.RemoteIPRanges -ne '') }
            }
            @{
                Name       = 'Bindings'
                Expression = { [string]::join("|", [String[]]$_.Bindings -ne '') }
            }
            'PermissionGroups'
            'AuthMechanism'
        )
    }
    Process {

    }
    End {

    }
}