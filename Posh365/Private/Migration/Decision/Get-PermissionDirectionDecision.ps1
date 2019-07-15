function Get-PermissionDirectionDecision {
    [CmdletBinding()]
    param (

    )
    end {

        $PermissionSplat = @{
            Title      = 'Choose one or more options and click OK'
            OutputMode = 'Multiple'
        }
        $PermissionDirectionDecision = @(
            [PSCustomObject]@{
                'Options' = 'Show me delegates (those granted access to mailbox(es) you just selected)'
            },
            [PSCustomObject]@{
                'Options' = 'Show me delegated (the mailboxes that can be accessed by mailbox(es) you just selected)'
            }
        )
        $PermissionDirectionDecision | Out-GridView @PermissionSplat
    }
}
