function Get-ATPAntiPhishRule {
    [CmdletBinding()]
    param (
    )
    end {
        Get-AntiPhishRule | Select-Object @(
            'Name'
            'Priority'
            'AntiPhishPolicy'
            'Description'
            'AuthenticationFailAction'
            'MailboxIntelligenceProtectionAction'
            'TargetedDomainProtectionAction'
            'TargetedUserProtectionAction'
            'PhishThresholdLevel'
            @{
                Name       = 'RecipientDomainIs'
                Expression = { @($_.RecipientDomainIs) -ne '' -join '|' }
            }
            @{
                Name       = 'ExceptIfRecipientDomainIs'
                Expression = { @($_.ExceptIfRecipientDomainIs) -ne '' -join '|' }
            }
            @{
                Name       = 'ExceptIfSentTo'
                Expression = { @($_.ExceptIfSentTo) -ne '' -join '|' }
            }
            @{
                Name       = 'ExceptIfSentToMemberOf'
                Expression = { @($_.ExceptIfSentToMemberOf) -ne '' -join '|' }
            }
            @{
                Name       = 'Exceptions'
                Expression = { @($_.Exceptions) -ne '' -join '|' }
            }
            'Comments'
            'WhenChanged'
            'ExchangeObjectId'
            'Guid'
        )
    }
}

