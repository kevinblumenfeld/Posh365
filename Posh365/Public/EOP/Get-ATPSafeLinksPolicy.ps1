function Get-ATPSafeLinksPolicy {
    [CmdletBinding()]
    param (
    )
    end {
        Get-SafeLinksPolicy | Select-Object @(
            'Name'
            'IsEnabled'
            'AllowClickThrough'
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
                Name       = 'DoNotRewriteUrls'
                Expression = { @($_.DoNotRewriteUrls) -ne '' -join '|' }
            }
            @{
                Name       = 'ExcludedUrls'
                Expression = { @($_.ExcludedUrls) -ne '' -join '|' }
            }
            'IsDefault'
            'Guid'
            'Identity'
            'WhenChanged'
            'WhenCreated'
        )
    }
}

