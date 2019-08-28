function Get-ATPSafeLinksRule {
    [CmdletBinding()]
    param (
    )
    end {
        Get-SafeLinksRule | Select-Object @(
            'Name'
            'State'
            'Priority'
            'SafeLinksPolicy'
            'Description'
            'DeliverMessageAfterScan'
            'DisableUrlRewrite'
            'DoNotAllowClickThrough'
            'DoNotTrackUserClicks'
            'EnableForInternalSenders'
            'EnableSafeLinksForTeams'
            'ScanUrls'
            'TrackClicks'
            'WhiteListedUrls'
            @{
                Name       = 'RecipientDomainIs'
                Expression = { @($_.RecipientDomainIs) -ne '' -join '|' }
            }
            @{
                Name       = 'ExceptIfRecipientDomainIs'
                Expression = { @($_.ExceptIfRecipientDomainIs) -ne '' -join '|' }
            }
            @{
                Name       = 'SentTo'
                Expression = { @($_.SentTo) -ne '' -join '|' }
            }
            @{
                Name       = 'SentToMemberOf'
                Expression = { @($_.SentToMemberOf) -ne '' -join '|' }
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
            @{
                Name       = 'Conditions'
                Expression = { @($_.Conditions) -ne '' -join '|' }
            }
            'Guid'
            'Identity'
            'WhenChanged'
        )
    }
}

