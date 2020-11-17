function Compare-IntunePolicy {
    <#
    .SYNOPSIS
    Compare two Intune Policies

    .DESCRIPTION
    Compare two Intune Policies

    .EXAMPLE
    Compare-IntunePolicy

    This example will let you choose the policy type and both policies with Out-GridView menus

    .EXAMPLE
    Compare-IntunePolicy | Out-GridView

    .EXAMPLE
    Compare-IntunePolicy | Export-PoshExcel .\Comparison.xlsx

    .EXAMPLE
    Compare-IntunePolicy | Export-Csv .\Comparison.csv -notypeinformation

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        # [Parameter()]
        # $Reference,

        # [Parameter()]
        # $Difference,

        # [Parameter()]
        # [ValidateSet('AppProtectionPolicyAndroid', 'AppProtectionPolicyiOS', 'AppConfigManagedApps', 'AppConfigManagedDevices')]
        # $PolicyType
    )

    if (-not $PolicyType) {
        $Type = @('AppProtectionPolicyAndroid', 'AppProtectionPolicyiOS', 'AppConfigManagedApps', 'AppConfigManagedDevices') | ForEach-Object {
            [PSCustomObject]@{
                PolicyType = $_
            }
        } | Out-GridView -OutputMode Single -Title 'Choose Policy Type'
        if (-not $Type) { return }
        $PolicyType = $Type.PolicyType
    }

    if ($PolicyType -eq 'AppProtectionPolicyAndroid') {
        $Object = Get-IntuneAppProtectionPolicyAndroid -Expand assignments, apps
    }
    elseif ($PolicyType -eq 'AppProtectionPolicyiOS') {
        $Object = Get-IntuneAppProtectionPolicyIos -Expand assignments, apps
    }
    elseif ($PolicyType -eq 'AppConfigManagedApps') {
        $Object = Get-IntuneAppConfigurationPolicyTargeted -Expand assignments, apps
    }
    elseif ($PolicyType -eq 'AppConfigManagedDevices') {
        $Object = Get-DeviceAppManagement_MobileAppConfigurations -Expand assignments
    }

    $DisplayNameReference = $Object | Select-Object DisplayName | Out-GridView -OutputMode Single -Title 'Choose Reference Object'
    $DisplayNameDifference = $Object | Select-Object DisplayName | Out-GridView -OutputMode Single -Title 'Choose Difference Object'
    $Reference = $Object | Where-Object { $_.DisplayName -eq $DisplayNameReference.DisplayName }
    $Difference = $Object | Where-Object { $_.DisplayName -eq $DisplayNameDifference.DisplayName }
    if (-not ($Reference -and $Difference)) { return }
    $ReferenceHash = Get-IntunePolicyHash -Policy $Reference
    $DifferenceHash = Get-IntunePolicyHash -Policy $Difference

    $MainHash = @{ }
    foreach ($RefKey in $ReferenceHash.keys) {
        if ($DifferenceHash[$RefKey] -ne $ReferenceHash[$RefKey] -and
            $RefKey -ne 'Id' -and
            $RefKey -ne 'iosManagedAppProtectionReferenceUrl' -and
            $RefKey -ne 'Description' -and
            $RefKey -ne 'ManagedAppPolicyId' -and
            $RefKey -ne 'version' -and
            $RefKey -ne 'targetedManagedAppConfigurationReferenceUrl' -and
            $RefKey -ne 'targetedManagedAppConfigurationId' -and
            $RefKey -ne 'assignments@odata.context' -and
            $RefKey -ne 'apps@odata.context' -and
            $RefKey -ne 'managedDeviceMobileAppConfigurationId' -and
            $RefKey -ne 'iosMobileAppConfigurationReferenceUrl'
        ) {
            $MainHash[$RefKey] = @{
                'Difference' = $DifferenceHash[$RefKey]
                'Reference'  = $ReferenceHash[$RefKey]
            }
        }
    }
    foreach ($MainKey in $MainHash.keys) {
        [PSCustomObject]@{
            'Type'                  = $PolicyType
            'Property'              = $MainKey
            $Reference.displayName  = $MainHash[$MainKey]['Difference']
            $Difference.displayName = $MainHash[$MainKey]['Reference']
        }
    }
}