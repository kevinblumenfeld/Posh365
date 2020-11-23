function Get-DiscoveryIntune {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Tenant
    )

    $PoshPath = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Posh365'
    $DiscoPath = Join-Path $PoshPath -ChildPath 'Discovery'
    $TenantPath = Join-Path $DiscoPath -ChildPath "$Tenant\Intune"
    $Detailed = Join-Path $TenantPath -ChildPath 'Detailed'
    $CSV = Join-Path $TenantPath -ChildPath 'CSV'
    $null = New-Item -ItemType Directory -Path $DiscoPath  -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $TenantPath  -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $Detailed  -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $CSV  -ErrorAction SilentlyContinue


    Write-Host "Gathering Conditional Access Policies" -ForegroundColor Cyan
    Get-ConditionalAccessPolicy | Export-Csv "$CSV\ConditionalAccessPolicy.csv" -NoTypeInformation

    Write-Host "Gathering Mobile Apps" -ForegroundColor Cyan
    Get-MemMobileApp | Export-Csv "$CSV\App.csv" -NoTypeInformation

    Write-Host "Gathering Mobile App Configurations" -ForegroundColor Cyan
    Get-MemMobileAppConfig | Export-Csv "$CSV\AppConfig.csv" -NoTypeInformation

    Write-Host "Gathering Mobile App Configurations Targeted" -ForegroundColor Cyan
    Get-MemMobileAppConfigTargeted | Export-Csv "$CSV\AppConfigTargeted.csv" -NoTypeInformation

    Write-Host "Gathering Mobile App Protection Policies - iOS" -ForegroundColor Cyan
    Get-MemMobileAppProtectioniOS | Export-Csv "$CSV\AppProtectioniOS.csv" -NoTypeInformation

    Write-Host "Gathering Mobile App Protection Policies - Android" -ForegroundColor Cyan
    Get-MemMobileAppProtectionAndroid | Export-Csv "$CSV\AppProtectionAndroid.csv" -NoTypeInformation

    Write-Host "Gathering Mobile Device Compliance Policies - Android at Work" -ForegroundColor Cyan
    Get-MemMobileDeviceComplianceAndroidWork | Export-Csv "$CSV\DeviceComplianceAndroidWork.csv" -NoTypeInformation

    Write-Host "Gathering Mobile Device Configuration Profiles - iOS - Device Restrictions" -ForegroundColor Cyan
    Get-MemMobileDeviceConfigiOSDeviceRestrictions | Export-Csv "$CSV\DeviceConfigiOSDeviceRestrictions.csv" -NoTypeInformation

    Write-Host "Gathering Mobile Device Configuration Profiles - iOS - Email" -ForegroundColor Cyan
    Get-MemMobileDeviceConfigiOSEmail | Export-Csv "$CSV\DeviceConfigiOSEmail.csv" -NoTypeInformation

    Write-Host "Gathering Mobile Device Configuration Profiles - iOS - WiFi" -ForegroundColor Cyan
    Get-MemMobileDeviceConfigiOSWifi | Export-Csv "$CSV\DeviceConfigiOSWifi.csv" -NoTypeInformation

    $ExcelSplat = @{
        TableStyle              = 'Medium2'
        FreezeTopRowFirstColumn = $true
        AutoSize                = $true
        BoldTopRow              = $false
        ClearSheet              = $true
        ErrorAction             = 'SilentlyContinue'
    }
    Get-ChildItem $CSV -Filter "*.csv" | Sort-Object Name | ForEach-Object {
        Write-Host "Exporting to Excel : " -ForegroundColor White -NoNewline
        Write-Host "$($_.BaseName)" -ForegroundColor Green

        Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName (-join $_.BaseName[0..29]) -Path (Join-Path $TenantPath 'Base_Intune_Discovery.xlsx')

        if ( $_.BaseName -eq 'App' ) {
            Import-Csv $_.fullname | Export-Excel @ExcelSplat -WorksheetName (-join $_.BaseName[0..29]) -Path (Join-Path $TenantPath 'Intune_Discovery.xlsx')
        }
        else {
            Import-Csv $_.fullname | Format-Vertical | Export-Excel @ExcelSplat -WorksheetName (-join $_.BaseName[0..29]) -Path (Join-Path $TenantPath 'Intune_Discovery.xlsx')
        }
    }
}
