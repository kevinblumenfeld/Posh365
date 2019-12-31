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
            'Enabled'
            @{
                Name       = 'SourceTransportServers'
                Expression = { @($_.SourceTransportServers) -ne '' -join '|' }
            }
            @{
                Name       = 'SmartHosts'
                Expression = { @($_.SmartHosts) -ne '' -join '|' }
            }
            @{
                Name       = 'AddressSpaces'
                Expression = { @($_.AddressSpaces) -ne '' -join '|' }
            }
            'MaxMessageSize'
            'DNSRoutingEnabled'
            'TlsDomain'
            'TlsAuthLevel'
            @{
                Name       = 'ConnectedDomains'
                Expression = { @($_.ConnectedDomains) -ne '' -join '|' }
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
            'Guid'
        )
    }
    Process {

    }
    End {

    }
}
