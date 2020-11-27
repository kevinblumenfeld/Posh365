function Get-MemMobileApp {
    param (

    )
    $Excludes = @(
        'DisplayName', 'Assignments', 'assignments@odata.context'
        'minimumSupportedOperatingSystem', 'roleScopeTagIds', 'isAssigned'
        '@odata.type'
    )
    Get-MemMobileAppData | Select-Object -ExpandProperty Value | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'OS'
            Expression = {
                $Store = [regex]::matches($_.'@odata.type', '[^\.]*$').value[0]
                if ($Store -like "*iOS*") { 'iOS' }
                elseif ($Store -like "*Android*") { 'Android' }
                elseif ($Store -like "*Windows*") { 'Windows' }
                else { $Store }
            }
        }
        @{
            Name       = 'Assignments'
            Expression = {
                $AList = [System.Collections.Generic.List[string]]::New()
                @($_.Assignments) | ForEach-Object {
                    $GroupId = try {
                        (Get-GraphGroup -ErrorAction Stop -GroupId $_.Target.groupId).displayName
                    }
                    catch { }
                    $item = '{0} {1} [ uodr:{2} ] [ vpn:{3} ]' -f $GroupId, ($_.Intent).ToUpper(), $_.Settings.uninstallOnDeviceRemoval, $_.Settings.vpnConfigurationId
                    $AList.Add($item)
                }
                @($Alist) -join "`r`n"
            }
        }
        @{
            Name       = 'Store'
            Expression = { [regex]::matches($_.'@odata.type', '[^\.]*$').value[0] }
        }
        @{
            Name       = 'minimumSupportedOperatingSystem'
            Expression = {
                $MinVer = [System.Collections.Generic.List[string]]::New()
                @($_.minimumSupportedOperatingSystem.PSObject.Properties).foreach{
                    $ver = '{0} {1}' -f $_.name, $_.value
                    $MinVer.Add($ver)
                }
                @($MinVer) -ne '' -join "`r`n"
            }
        }
        @{
            Name       = 'isAssigned'
            Expression = { $_.isAssigned }
        }
        '*'
        @{
            Name       = 'roleScopeTagIds'
            Expression = { $_.roleScopeTagIds }
        }
    )
}
