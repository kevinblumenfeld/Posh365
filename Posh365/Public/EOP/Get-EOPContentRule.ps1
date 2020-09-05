function Get-EOPContentRule {
    [CmdletBinding()]
    param (
    )

    Get-HostedContentFilterRule | Select-Object @(
        'Name'
        'State'
        'Identity'
        'AdminDisplayName'
        'Priority'
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
            Name       = 'RecipientDomainIs'
            Expression = { @($_.RecipientDomainIs) -ne '' -join '|' }
        }
        @{
            Name       = 'SentTo'
            Expression = { @($_.SentTo) -ne '' -join '|' }
        }
        @{
            Name       = 'SentToMemberOf'
            Expression = { @($_.SentToMemberOf) -ne '' -join '|' }
        }
    )
}
