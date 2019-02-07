Function Update-RoleEntry {
    <#
    .SYNOPSIS
    Function to modify a role by removing or adding Role Entries

    .DESCRIPTION

    (If no Action is passed we assume remove)
    $roleentry should be in the form Role\Roleentry e.g. MyRole\New-DistributionGroup

    .PARAMETER RoleEntry
    Parameter description

    .PARAMETER Action
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    Param(
        [Parameter()]
        $RoleEntry,

        [Parameter()]
        $Action
    )

    Switch ($Action) {
        Add {Add-ManagementRoleEntry $RoleEntry -confirm:$false}
        Remove {Remove-ManagementRoleEntry $RoleEntry -confirm:$false}
        Default {Remove-ManagementRoleEntry $RoleEntry -confirm:$false}
    }
}