function Get-EOPOutboundSpamPolicy {
    [CmdletBinding()]
    param (
    )
    end {
        Get-HostedOutboundSpamFilterPolicy | Select-Object @(
            'Name'
            'Identity'
            'ConfigurationType'
            'ActionWhenThresholdReached'
            'IsDefault'
            'Enabled'
            'NotifyOutboundSpam'
            @{
                Name       = 'NotifyOutboundSpamRecipients'
                Expression = { @($_.NotifyOutboundSpamRecipients) -ne '' -join '|' }
            }
            'BccSuspiciousOutboundMail'
            @{
                Name       = 'BccSuspiciousOutboundAdditionalRecipients'
                Expression = { @($_.BccSuspiciousOutboundAdditionalRecipients) -ne '' -join '|' }
            }
            'RecipientLimitExternalPerHour'
            'RecipientLimitInternalPerHour'
            'RecipientLimitPerDay'
            'AdminDisplayName'
            'DirectoryBasedEdgeBlockMode'
            'ObjectState'
            'OrganizationId'
            'WhenChanged'
            'WhenChangedUTC'
            'WhenCreated'
            'WhenCreatedUTC'
            'Id'
            'Guid'
        )
    }
}

