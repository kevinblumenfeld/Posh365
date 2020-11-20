function Get-LegacyIntunePolicyDetails {

    [CmdletBinding()]
    param (

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

    $DisplayNameReference = $Object | Select-Object DisplayName | Out-GridView -OutputMode Single -Title 'Choose one object'
    $Difference = $Object | Where-Object { $_.DisplayName -eq $DisplayNameReference.DisplayName }
    $DifferenceHash = Get-IntunePolicyHash -Policy $Difference

    $MainHash = @{ }
    foreach ($RefKey in $DifferenceHash.keys) {
        # if ($RefKey -ne 'Id' -and
        #     $RefKey -ne 'iosManagedAppProtectionReferenceUrl' -and
        #     $RefKey -ne 'Description' -and
        #     $RefKey -ne 'ManagedAppPolicyId' -and
        #     $RefKey -ne 'version' -and
        #     $RefKey -ne 'targetedManagedAppConfigurationReferenceUrl' -and
        #     $RefKey -ne 'targetedManagedAppConfigurationId' -and
        #     $RefKey -ne 'assignments@odata.context' -and
        #     $RefKey -ne 'apps@odata.context' -and
        #     $RefKey -ne 'managedDeviceMobileAppConfigurationId' -and
        #     $RefKey -ne 'iosMobileAppConfigurationReferenceUrl'
        # )
        {
            $MainHash[$RefKey] = $DifferenceHash[$RefKey]
        }
    }
    foreach ($MainKey in $MainHash.keys) {
        [PSCustomObject]@{
            'Type'                  = $PolicyType
            'Property'              = $MainKey
            $Difference.displayName = $MainHash[$MainKey]
        }
    }
}
