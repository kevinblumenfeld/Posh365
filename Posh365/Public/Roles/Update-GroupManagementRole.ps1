function Update-GroupManagementRole {
    <#
    .SYNOPSIS
    This script will create or manage a management role.

    .DESCRIPTION

    It is designed to allow users to modify Exchange Distribution Groups that they already own
    However, it limits their ability to create or remove Distribution Groups.

    .PARAMETER Name
    Name of the Management role you want to create or modify
    Defaults to: "MyDistributionGroupsManagement"

    .PARAMETER Policy
    Name of the Role Policy you want to assign the role to
    Defaults to: "Default Role Assignment Policy"

    .PARAMETER PreventAbilityToCreateGroups
    Removes the ability of the Role to Create DLs

    .PARAMETER PreventAbilityToDeleteGroups
    Removes the ability of the Role to Remove DLs

    .EXAMPLE
    Update-GroupManagementRole -PreventAbilityToCreateGroups -PreventAbilityToDeleteGroups

    This creates a Management Role named: MyDistributionGroupsManagement
    If it already exists it attempts to modify it by removing or adding the ability to create and/or remove groups

    .NOTES
    General notes
    #>

    Param(
        [Parameter()]
        [string] $Name = "MyDistributionGroupsManagement",

        [Parameter()]
        [string] $Policy = "Default Role Assignment Policy",

        [Parameter()]
        [string] $Parent = "MyDistributionGroups",

        [Parameter()]
        [switch] $PreventAbilityToCreateGroups,

        [Parameter()]
        [switch] $PreventAbilityToDeleteGroups

    )

    If (Get-ManagementRole $Name -erroraction silentlycontinue) {
        Write-Warning "Found a Role with Name: $Name"
        Write-Warning "Trying to Modify Existing Role"
    }
    Else {
        Write-Host "Creating Management Role $Name"
        New-ManagementRole -Name $Name -Parent $Parent
    }

    $AbilityToCreateExists = Get-ManagementRoleEntry $Name\New-DistributionGroup -erroraction silentlycontinue
    $AbilityToDeleteExists = Get-ManagementRoleEntry $Name\Remove-DistributionGroup -erroraction silentlycontinue

    If ($PreventAbilityToCreateGroups) {
        If ($AbilityToCreateExists) {
            Update-RoleEntry $Name\New-DistributionGroup Remove
            Write-Host "Removing ability to create Distribution Groups from $Name"
        }
    }
    else {
        Update-RoleEntry $name\New-DistributionGroup Add
        Write-Host "Adding ability to create Distribution Groups to $name"
    }

    If ($PreventAbilityToDeleteGroups) {
        If ($AbilityToDeleteExists) {
            Update-RoleEntry $name\Remove-DistributionGroup Remove
            Write-Host "Removing ability to delete Distribution Groups from $name"
        }
    }
    else {
        Update-RoleEntry $name\Remove-DistributionGroup Add
        Write-Host "Adding ability to delete Distribution Groups to $name"
    }

    If (Get-ManagementRoleAssignment $Name-$Policy -erroraction silentlycontinue) {
        Write-Warning "Found Existing Role Assignment: $Name-$Policy"
        Write-Warning "Making no modifications to Role Assignments"
    }
    Else {
        Write-Host "Creating Management Role Assignment $Name-$Policy"
        New-ManagementRoleAssignment -name ($Name + "-" + $Policy) -Role $Name -Policy $Policy
    }

}

