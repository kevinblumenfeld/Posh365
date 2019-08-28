function Get-ATPAntiPhishPolicy {
    [CmdletBinding()]
    param (
    )
    end {
        Get-AntiPhishPolicy | Select-Object @(
            'Name'
            'Identity'
            'AntiSpoofEnforcementType'
            'AuthenticationFailAction'
            'MailboxIntelligenceProtectionAction'
            'TargetedDomainProtectionAction'
            'TargetedUserProtectionAction'
            'PhishThresholdLevel'
            @{
                Name       = 'TargetedUsersToProtect'
                Expression = { @($_.TargetedUsersToProtect) -ne '' -join '|' }
            }
            @{
                Name       = 'ExcludedSenders'
                Expression = { @($_.ExcludedSenders) -ne '' -join '|' }
            }
            @{
                Name       = 'MailboxIntelligenceProtectionActionRecipients'
                Expression = { @($_.MailboxIntelligenceProtectionActionRecipients) -ne '' -join '|' }
            }
            @{
                Name       = 'TargetedDomainActionRecipients'
                Expression = { @($_.TargetedDomainActionRecipients) -ne '' -join '|' }
            }
            @{
                Name       = 'TargetedUserActionRecipients'
                Expression = { @($_.TargetedUserActionRecipients) -ne '' -join '|' }
            }
            @{
                Name       = 'ExcludedDomains'
                Expression = { @($_.ExcludedDomains) -ne '' -join '|' }
            }
            @{
                Name       = 'TargetedDomainsToProtect'
                Expression = { @($_.TargetedDomainsToProtect) -ne '' -join '|' }
            }
            @{
                Name       = 'SenderDomainIs'
                Expression = { @($_.SenderDomainIs) -ne '' -join '|' }
            }
            'EnableAuthenticationSafetyTip'
            'EnableAuthenticationSoftPassSafetyTip'
            'Enabled'
            'EnableMailboxIntelligence'
            'EnableMailboxIntelligenceProtection'
            'EnableOrganizationDomainsProtection'
            'EnableSimilarDomainsSafetyTips'
            'EnableSimilarUsersSafetyTips'
            'EnableSuspiciousSafetyTip'
            'EnableTargetedDomainsProtection'
            'EnableTargetedUserProtection'
            'EnableUnauthenticatedSender'
            'EnableUnusualCharactersSafetyTips'
            'IsDefault'
            'TreatSoftPassAsAuthenticated'
            'WhenChangedUTC'
            'WhenCreatedUTC'
            'ExchangeObjectId'
            'Guid'
        )
    }
}

