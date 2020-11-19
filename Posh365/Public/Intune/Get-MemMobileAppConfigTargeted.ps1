function Get-MemMobileAppConfigTargeted {
    param (

    )
    $Excludes = @(
        'assignments', 'apps', 'DisplayName', 'customSettings'
        'assignments@odata.context', 'deploymentSummary@odata.context'
        'apps@odata.context'
    )
    Get-MemMobileAppConfigTargetedData | Select-Object -ExcludeProperty $Excludes -Property @(
        @{
            Name       = 'DisplayName'
            Expression = { $_.DisplayName }
        }
        @{
            Name       = 'Apps'
            Expression = { @(($_.Apps).id) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'assignments'
            Expression = { @(($_.Assignments.Target.GroupID.foreach{ Get-GraphGroup -GroupId $_ }).displayName) -ne '' -join "`r`n" }
        }
        @{
            Name       = 'CustomSettings'
            Expression = { @($_.CustomSettings.foreach{ '{0} --> {1}' -f $_.Name, $_.Value }) -ne '' -join "`r`n" }
        }
        '*'
    )
}