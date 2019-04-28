function Get-ExchangeSendConnector {
    <#
    .SYNOPSIS
    Export on-premises Send Connectors

    .DESCRIPTION
    Export on-premises Send Connectors

    .PARAMETER ViewEntireForest
    Include entire forest when querying Exchange

    .EXAMPLE
    Get-ExchangeSendConnector | Export-Csv c:\scripts\RecCons.csv -notypeinformation -encoding UTF8

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
        Get-SendConnector | Select-Object @(
            'Name'
            'ConnectorType'
            'DNSRoutingEnabled'
            'TlsDomain'
            'TlsAuthLevel'
            @{
                Name       = 'SmartHosts'
                Expression = { [string]::join("|", [String[]]$_.SmartHosts -ne '') }
            }
            @{
                Name       = 'AddressSpaces'
                Expression = { [string]::join("|", [String[]]$_.AddressSpaces -ne '') }
            }
            @{
                Name       = 'ConnectedDomains'
                Expression = { [string]::join("|", [String[]]$_.ConnectedDomains -ne '') }
            }
            @{
                Name       = 'SourceTransportServers'
                Expression = { [string]::join("|", [String[]]$_.SourceTransportServers -ne '') }
            }
            'Port'
            'TlsCertificateName'
            'ErrorPolicies'
            'ConnectionInactivityTimeOut'
            'ForceHELO'
            'FrontendProxyEnabled'
            'IgnoreSTARTTLS'
            'CloudServicesMailEnabled'
            'Fqdn'
            'RequireTLS'
            'RequireOorg'
            'Enabled'
            'ProtocolLoggingLevel'
            'SmartHostAuthMechanism'
            'AuthenticationCredential'
            'UseExternalDNSServersEnabled'
            'DomainSecureEnabled'
            'SourceIPAddress'
            'SmtpMaxMessagesPerConnection'
            'SmartHostsString'
            'IsScopedConnector'
            'IsSmtpConnector'
            'Comment'
            'SourceRoutingGroup'
            'WhenChanged'
            'WhenCreated'
            'Id'
            'IsValid'
        )
    }
    Process {

    }
    End {

    }
}