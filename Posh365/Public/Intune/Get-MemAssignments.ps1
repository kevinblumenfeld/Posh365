function Get-MemAssignments {
    param (
        [Parameter()]
        [switch]
        $AssignedOnly,

        [Parameter()]
        [switch]
        $DontIncludeMobileApps
    )

    $AHash = [ordered]@{ }

    if (-not $DontIncludeMobileApps) {
        Write-Host "Gathering Assignments for Mobile Apps" -ForegroundColor Cyan
        Get-MemMobileApp | ForEach-Object {
            $AHash['{0} ({1})' -f $_.DisplayName, $_.Store] = @{
                Type        = 'MobileApps'
                Assignments = $_.Assignments
            }
        }
    }

    Write-Host "Gathering Assignments for Mobile App Configurations" -ForegroundColor Cyan
    Get-MemMobileAppConfig | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'MobileAppConfig'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile App Configurations Targeted" -ForegroundColor Cyan
    Get-MemMobileAppConfigTargeted | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'AppConfigTargeted'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile App Protection Policies - iOS" -ForegroundColor Cyan
    Get-MemMobileAppProtectioniOS | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'AppProtectioniOS'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile App Protection Policies - Android" -ForegroundColor Cyan
    Get-MemMobileAppProtectionAndroid | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'AppProtectionAndroid'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile Device Compliance Policies - Android at Work" -ForegroundColor Cyan
    Get-MemMobileDeviceComplianceAndroidWork | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'DeviceComplianceAndroidWork'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile Device Compliance Policies - iOS" -ForegroundColor Cyan
    Get-MemMobileDeviceComplianceiOS | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'DeviceComplianceiOS'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile Device Configuration Profiles - iOS - Device Restrictions" -ForegroundColor Cyan
    Get-MemMobileDeviceConfigiOSDeviceRestrictions | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'DeviceConfigiOSDeviceRestricti'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile Device Configuration Profiles - iOS - Email" -ForegroundColor Cyan
    Get-MemMobileDeviceConfigiOSEmail | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'DeviceConfigiOSEmail'
            Assignments = $_.Assignments
        }
    }
    Write-Host "Gathering Assignments for Mobile Device Configuration Profiles - iOS - WiFi" -ForegroundColor Cyan
    Get-MemMobileDeviceConfigiOSWifi | ForEach-Object {
        $AHash[$_.DisplayName] = @{
            Type        = 'DeviceConfigiOSWifi'
            Assignments = $_.Assignments
        }
    }

    if ($AssignedOnly) {
        foreach ($Key in $AHash.keys) {
            if ($AHash[$Key]['Assignments']) {
                [PSCustomObject]@{
                    Type        = $AHash[$Key]['Type']
                    DisplayName = $Key
                    Assignments = $AHash[$Key]['Assignments']
                }
            }
        }
    }
    else {
        foreach ($Key in $AHash.keys) {
            [PSCustomObject]@{
                Type        = $AHash[$Key]['Type']
                DisplayName = $Key
                Assignments = $AHash[$Key]['Assignments']
            }
        }
    }

}
