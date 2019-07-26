function Get-EOPContentPolicy {
    [CmdletBinding()]
    param (
    )
    end {
        Get-HostedContentFilterPolicy | Select-Object @(
            'Identity'
            'AdminDisplayName'
            @{
                Name       = 'AllowedSenderDomains'
                Expression = { @($_.AllowedSenderDomains) -ne '' -join '|' }
            }
            @{
                Name       = 'AllowedSenders'
                Expression = { @($_.AllowedSenders) -ne '' -join '|' }
            }
            @{
                Name       = 'BlockedSenderDomains'
                Expression = { @($_.BlockedSenderDomains) -ne '' -join '|' }
            }
            @{
                Name       = 'BlockedSenders'
                Expression = { @($_.BlockedSenders) -ne '' -join '|' }
            }
            @{
                Name       = 'LanguageBlockList'
                Expression = { @($_.LanguageBlockList) -ne '' -join '|' }
            }
            @{
                Name       = 'RegionBlockList'
                Expression = { @($_.RegionBlockList) -ne '' -join '|' }
            }
            @{
                Name       = 'RedirectToRecipients'
                Expression = { @($_.RedirectToRecipients) -ne '' -join '|' }
            }
            @{
                Name       = 'TestModeBccToRecipients'
                Expression = { @($_.TestModeBccToRecipients) -ne '' -join '|' }
            }
            'AddXHeaderValue'
            'BulkSpamAction'
            'BulkThreshold'
            'DownloadLink'
            'EnableEndUserSpamNotifications'
            'EnableLanguageBlockList'
            'EnableRegionBlockList'
            'EndUserSpamNotificationCustomFromAddress'
            'EndUserSpamNotificationCustomFromName'
            'EndUserSpamNotificationCustomSubject'
            'EndUserSpamNotificationFrequency'
            'EndUserSpamNotificationLanguage'
            'EndUserSpamNotificationLimit'
            'HighConfidenceSpamAction'
            'IncreaseScoreWithBizOrInfoUrls'
            'IncreaseScoreWithImageLinks'
            'IncreaseScoreWithNumericIps'
            'IncreaseScoreWithRedirectToOtherPort'
            'InlineSafetyTipsEnabled'
            'MarkAsSpamBulkMail'
            'MarkAsSpamEmbedTagsInHtml'
            'MarkAsSpamEmptyMessages'
            'MarkAsSpamFormTagsInHtml'
            'MarkAsSpamFramesInHtml'
            'MarkAsSpamFromAddressAuthFail'
            'MarkAsSpamJavaScriptInHtml'
            'MarkAsSpamNdrBackscatter'
            'MarkAsSpamObjectTagsInHtml'
            'MarkAsSpamSensitiveWordList'
            'MarkAsSpamSpfRecordHardFail'
            'MarkAsSpamWebBugsInHtml'
            'ModifySubjectValue'
            'PhishSpamAction'
            'QuarantineRetentionPeriod'
            'SpamAction'
            'TestModeAction'
            'ZapEnabled'
        )
    }
}
