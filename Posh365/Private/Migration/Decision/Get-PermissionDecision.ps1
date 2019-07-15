function Get-PermissionDecision {
    [CmdletBinding()]
    param (

    )
    end {

        $PermissionSplat = @{
            Title      = 'Choose one or more options and click OK'
            OutputMode = 'Multiple'
        }
        $PermissionDecision = @(
            [PSCustomObject]@{
                'Options' = 'FullAccess'
            },
            [PSCustomObject]@{
                'Options' = 'SendAs'
            },
            [PSCustomObject]@{
                'Options' = 'SendOnBehalf'
            },
            [PSCustomObject]@{
                'Options' = 'Folder'
            }
        )
        $PermissionDecision | Out-GridView @PermissionSplat
    }
}
