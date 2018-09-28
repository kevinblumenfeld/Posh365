function Get-ExchangeReceiveConnector { 
    <#
    .SYNOPSIS
    Export on-premises Receive Connectors
    
    .DESCRIPTION
    Export on-premises Receive Connectors
    
    .PARAMETER DetailedReport
    Provides a semi-detailed report of on-premises Exchange Receive Connectors

    .PARAMETER ViewEntireForest
    Include entire forest when querying Exchange
    
    .EXAMPLE
    Get-ExchangeReceiveConnector | Export-Csv c:\scripts\RecCons.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,
        [Parameter(Mandatory = $false)]
        [switch] $ViewEntireForest
    )
    Begin {
        if ($ViewEntireForest) {
            Set-ADServerSettings -ViewEntireForest:$True
        }
        if ($DetailedReport) {
            $Selectproperties = @(
                'Identity', 'Server', 'Enabled'
            )
            
            $CalculatedProps = @(
                @{n = "RemoteIPRanges" ; e = {( $_.RemoteIPRanges | Where-Object {$_ -ne $null}) -join ";"}},
                @{n = "Bindings" ; e = {($_.Bindings | Where-Object {$_ -ne $null}) -join ";" }}
            )
            $Selectproperties2 = @(
                'PermissionGroups', 'AuthMechanism'
            ) 
        }
        else {
            $Selectproperties = @(
                'Identity', 'Server'
            )
            
            $CalculatedProps = @(
                @{n = "RemoteIPRanges" ; e = {( $_.RemoteIPRanges | Where-Object {$_ -ne $null}) -join ";"}}
            )
            $Selectproperties2 = @(
                'PermissionGroups', 'AuthMechanism'
            ) 
        }
    }
    Process {
        Get-ReceiveConnector | Select-Object ($Selectproperties + $CalculatedProps + $Selectproperties2)
    }
    End {
        
    }
}