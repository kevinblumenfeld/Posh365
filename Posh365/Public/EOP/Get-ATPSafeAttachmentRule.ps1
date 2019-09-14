function Get-ATPSafeAttachmentRule {
    [CmdletBinding()]
    param (
    )
    end {
        Get-SafeAttachmentRule | Select-Object @(
            'Name'
            'SafeAttachmentPolicy'
            'State'
            'Priority'
            'Description'
            @{
                Name       = 'Conditions'
                Expression = { @($_.Conditions) -ne '' -join '|' }
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
            'Identity'
        )
    }
}

