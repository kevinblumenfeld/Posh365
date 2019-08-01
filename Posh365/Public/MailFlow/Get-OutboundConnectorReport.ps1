function Get-OutboundConnectorReport {
    [CmdletBinding()]
    param (

    )
    end {
        Get-OutboundConnector | Select-Object @(
            'Name'
            'Enabled'
            @{
                Name       = 'RecipientDomains'
                Expression = { @($_.RecipientDomains) -ne '' -join '|' }
            }
            @{
                Name       = 'SmartHosts'
                Expression = { @($_.SmartHosts) -ne '' -join '|' }
            }
            @{
                Name       = 'ValidationRecipients'
                Expression = { @($_.ValidationRecipients) -ne '' -join '|' }
            }
            'AllAcceptedDomains'
            'CloudServicesMailEnabled'
            'Comment'
            'ConnectorSource'
            'ConnectorType'
            'IsTransportRuleScoped'
            'LastValidationTimestamp'
            'RouteAllMessagesViaOnPremises'
            'TestMode'
            'TlsDomain'
            'TlsSettings'
            'UseMXRecord'
            'WhenChangedUTC'
            'WhenCreatedUTC'
            'IsValid'
            'IsValidated'
            'Id'
            'Identity'
        )
    }
}
