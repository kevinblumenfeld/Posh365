function Get-MemMobileDeviceComplianceAndroidWork {
    param (

    )
    $Excludes = @(
        'assignments', 'displayName', 'scheduledactionsforrule', 'createdDateTime', 'lastModifiedDateTime'
        'version', 'assignments@odata.context', 'scheduledActionsForRule@odata.context', 'roleScopeTagIds'
        'id', '@odata.type'
    )
    Get-MemMobileDeviceComplianceiOSData | Select-Object -ExcludeProperty $Excludes -Property @(
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
        @{
            Name       = 'ActionsforNonCompliance'
            Expression = { @($_.scheduledActionsForRule.scheduledActionConfigurations.foreach{ '{0} --> {1}' -f $_.actionType, $_.gracePeriodHours }) -ne '' -join "`r`n" }
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