function Get-InboundConnectorReport {
    [CmdletBinding()]
    param (

    )
    end {
        Get-InboundConnector | Select-Object @(
            'Name'
            'Enabled'
            'RequireTls'
            @{
                Name       = 'AssociatedAcceptedDomains'
                Expression = { @($_.AssociatedAcceptedDomains) -ne '' -join '|' }
            }
            @{
                Name       = 'DetectSenderIPBySkippingTheseIPs'
                Expression = { @($_.DetectSenderIPBySkippingTheseIPs) -ne '' -join '|' }
            }
            @{
                Name       = 'DetectSenderIPBySkippingTheseProviders'
                Expression = { @($_.DetectSenderIPBySkippingTheseProviders) -ne '' -join '|' }
            }
            @{
                Name       = 'DetectSenderIPRecipientList'
                Expression = { @($_.DetectSenderIPRecipientList) -ne '' -join '|' }
            }
            @{
                Name       = 'EFSkipIPs'
                Expression = { @($_.EFSkipIPs) -ne '' -join '|' }
            }
            @{
                Name       = 'EFSkipMailGateway'
                Expression = { @($_.EFSkipMailGateway) -ne '' -join '|' }
            }
            @{
                Name       = 'EFUsers'
                Expression = { @($_.EFUsers) -ne '' -join '|' }
            }
            @{
                Name       = 'ScanAndDropRecipients'
                Expression = { @($_.ScanAndDropRecipients) -ne '' -join '|' }
            }
            @{
                Name       = 'SenderDomains'
                Expression = { @($_.SenderDomains) -ne '' -join '|' }
            }
            @{
                Name       = 'SenderIPAddresses'
                Expression = { @($_.SenderIPAddresses) -ne '' -join '|' }
            }
            'CloudServicesMailEnabled'
            'Comment'
            'ConnectorSource'
            'ConnectorType'
            'RestrictDomainsToCertificate'
            'RestrictDomainsToIPAddresses'
            'TlsSenderCertificateName'
            'TreatMessagesAsInternal'
            'WhenChangedUTC'
            'WhenCreatedUTC'
            'Identity'
            'IsValid'
            'DetectSenderIPBySkippingLastIP'
            'EFSkipLastIP'
            'EFTestMode'
        )
    }
}
