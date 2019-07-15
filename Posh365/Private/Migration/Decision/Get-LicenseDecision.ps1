function Get-LicenseDecision {
    [CmdletBinding()]
    param (

    )
    end {

        $LicenseSkuSplat = @{
            Title      = 'Choose one or more options and click OK'
            OutputMode = 'Multiple'
        }
        $LicenseSkuDecision = @(
            [PSCustomObject]@{
                'Options' = 'AddSkus'
            },
            [PSCustomObject]@{
                'Options' = 'AddOptions'
            },
            [PSCustomObject]@{
                'Options' = 'RemoveSkus'
            },
            [PSCustomObject]@{
                'Options' = 'RemoveOptions'
            }
        )
        $LicenseSkuDecision | Out-GridView @LicenseSkuSplat
    }
}
