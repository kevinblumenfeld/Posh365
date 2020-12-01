function Get-MemGroupAppAssignment {
    param (
        [Parameter()]
        [switch]
        $IncludeUnassigned
    )

    $AppList = Get-MemMobileAppData | Select-Object -ExpandProperty Value
    foreach ($App in $AppList) {
        foreach ($Assigned in $App.Assignments) {
            $Group = try { (Get-GraphGroup -ErrorAction Stop -GroupId $Assigned.Target.GroupId).displayName } catch { }
            if ($Group -or $IncludeUnassigned) {
                $Store = [regex]::matches($App.'@odata.type', '[^\.]*$').value[0]
                [PSCustomObject]@{
                    Group                    = $Group
                    DisplayName              = $App.DisplayName
                    OS                       = if ($Store -like "*iOS*") { 'iOS' }
                    elseif ($Store -like "*Android*") { 'Android' }
                    elseif ($Store -like "*Windows*") { 'Windows' }
                    else { $Store }
                    Intent                   = $Assigned.Intent
                    UninstallOnDeviceRemoval = $Assigned.Settings.uninstallOnDeviceRemoval
                    VPN                      = $Assigned.Settings.vpnConfigurationId
                    Store                    = $Store
                }
            }
        }
    }
}
