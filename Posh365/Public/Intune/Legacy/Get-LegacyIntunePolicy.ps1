function Get-LegacyIntunePolicy {
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
        $ObjectList = Get-IntuneAppProtectionPolicyAndroid -Expand assignments, apps | Out-GridView -OutputMode Multiple
    }
    elseif ($PolicyType -eq 'AppProtectionPolicyiOS') {
        $ObjectList = Get-IntuneAppProtectionPolicyIos -Expand assignments, apps | Out-GridView -OutputMode Multiple
    }
    elseif ($PolicyType -eq 'AppConfigManagedApps') {
        $ObjectList = Get-IntuneAppConfigurationPolicyTargeted -Expand assignments, apps | Out-GridView -OutputMode Multiple
    }
    elseif ($PolicyType -eq 'AppConfigManagedDevices') {
        $ObjectList = Get-DeviceAppManagement_MobileAppConfigurations -Expand assignments | Out-GridView -OutputMode Multiple
    }

    foreach ($Object in $ObjectList) {
        $Exclude = @(
            'assignments', 'apps', 'Id', 'iosManagedAppProtectionReferenceUrl'
            'Description', 'ManagedAppPolicyId', 'version', 'targetedManagedAppConfigurationReferenceUrl'
            'targetedManagedAppConfigurationId', 'assignments@odata.context', 'apps@odata.context'
            'managedDeviceMobileAppConfigurationId', 'iosMobileAppConfigurationReferenceUrl'
            'iosManagedAppProtectionId', 'iosManagedAppProtectionReferenceURL', 'CustomSettings'
            'Settings'
        )
        $Object | Select-Object -ExcludeProperty $Exclude -Property @(
            '*'
            @{
                Name       = 'assignments'
                Expression = {
                    $GroupNameList = [System.Collections.Generic.List[string]]::New()
                    foreach ($Group in $_.Assignments.Target) {
                        try {
                            $GroupName = Get-AADGroup -groupId $Group.groupId | Select-Object -ExpandProperty displayName
                            $GroupNameList.Add($GroupName)
                        }
                        catch { }
                    }
                    @($GroupNameList) -ne '' -join "`r`n"
                }
            }
            @{
                Name       = 'CustomSettings'
                Expression = { @($_.CustomSettings.foreach{ $_.Name }) -ne '' -join "`r`n" }
            }
            @{
                Name       = 'Settings'
                Expression = { @($_.Settings.foreach{ '{0} --> {1}' -f $_.AppConfigKey, $_.AppConfigKeyValue }) -ne '' -join "`r`n" }
            }
            @{
                Name       = 'apps'
                Expression = { @($_.apps.id) -ne '' -join "`r`n" }
            }
        )
    }
}