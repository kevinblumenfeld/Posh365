function Get-PermissionDecisionBatch {
    [CmdletBinding()]
    param (

    )
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
        },
        [PSCustomObject]@{
            'Options' = 'AddToBatch'
        }
    )
    $PermissionDecision | Out-GridView @PermissionSplat
}
