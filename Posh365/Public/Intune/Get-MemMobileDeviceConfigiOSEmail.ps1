function Get-MemMobileDeviceConfigiOSEmail {
    param (

    )
    $Excludes = @(
        'assignments', 'displayName', 'createdDateTime', 'lastModifiedDateTime'
        'version', 'assignments@odata.context', 'roleScopeTagIds', 'id', '@odata.type'
    )
    Get-MemMobileDeviceConfigiOSEmailData | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'assignments'
            Expression = { @(($_.Assignments.Target.GroupID.foreach{
                            try { Get-GraphGroup -ErrorAction Stop -GroupId $_ }
                            catch { } }).displayName) -ne '' -join "`r`n" }
        }
        '*'
        @{
            Name       = 'createdDateTime'
            Expression = { $_.createdDateTime }
        }
        @{
            Name       = 'lastModifiedDateTime'
            Expression = { $_.lastModifiedDateTime }
        }
        @{
            Name       = 'roleScopeTagIds'
            Expression = { $_.roleScopeTagIds }
        }
        @{
            Name       = 'id'
            Expression = { $_.id }
        }
        @{
            Name       = '@odata.type'
            Expression = { $_.'@odata.type' }
        }
        @{
            Name       = 'version'
            Expression = { $_.version }
        }
    )
}