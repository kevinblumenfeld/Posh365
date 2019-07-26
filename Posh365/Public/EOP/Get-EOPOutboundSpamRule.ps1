function Get-EOPOutboundSpamRule {
    [CmdletBinding()]
    param (
    )
    end {
        Get-HostedOutboundSpamFilterRule | Select-Object @(
            'Name'
            'Identity'
            'Priority'
            'HostedOutboundSpamFilterPolicy'
            @{
                Name       = 'Conditions'
                Expression = { @($_.Conditions) -ne '' -join '|' }
            }
            'Description'
            @{
                Name       = 'ExceptIfFrom'
                Expression = { @($_.ExceptIfFrom) -ne '' -join '|' }
            }
            @{
                Name       = 'ExceptIfFrom'
                Expression = { @($_.ExceptIfFrom) -ne '' -join '|' }
            }
            @{
                Name       = 'ExceptIfFromMemberOf'
                Expression = { @($_.ExceptIfFromMemberOf) -ne '' -join '|' }
            }
            @{
                Name       = 'ExceptIfSenderDomainIs'
                Expression = { @($_.ExceptIfSenderDomainIs) -ne '' -join '|' }
            }
            @{
                Name       = 'Exceptions'
                Expression = { @($_.Exceptions) -ne '' -join '|' }
            }
            @{
                Name       = 'From'
                Expression = { @($_.From) -ne '' -join '|' }
            }
            @{
                Name       = 'FromMemberOf'
                Expression = { @($_.FromMemberOf) -ne '' -join '|' }
            }
            @{
                Name       = 'SenderDomainIs'
                Expression = { @($_.SenderDomainIs) -ne '' -join '|' }
            }
            'Comments'
            'Guid'
            'RuleVersion'
            'State'
            'WhenChanged'
        )
    }
}

