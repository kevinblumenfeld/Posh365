function Find-Spill {
    [CmdletBinding()]
    param ()
    do {
        $Splat = try {
            Invoke-Expression (Show-Command -NoCommonParameter -PassThru SpillFinder) -ErrorAction Stop
        }
        catch {
            Write-Host "Show-Command Error: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
        $TenantPath = Join-Path -Path $Env:USERPROFILE -ChildPath ('.Posh365/Credentials/Graph/{0}' -f $Splat.Tenant)
        $TenantCred = Join-Path -Path $TenantPath -ChildPath ('{0}Cred.xml' -f $Splat.Tenant)
        $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Splat.Tenant)
        if (-not (Test-Path $TenantConfig) -or -not (Test-Path $TenantCred) ) { Export-GraphConfig -Tenant $Splat.Tenant }
    } until ($Splat.count -gt 2)
    if ($Splat.ContainsKey('OptionToDeleteMessages')) {
        Invoke-FindSpill @Splat | Out-GridView -PassThru -Title 'Choose Messages to Delete and Click OK' | Remove-GraphMailMessage
    }
    else {
        Invoke-FindSpill @Splat | Out-GridView -PassThru -Title 'Choose Messages to Delete and Click OK'
    }
}
