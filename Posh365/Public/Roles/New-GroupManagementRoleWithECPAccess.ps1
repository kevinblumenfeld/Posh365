function New-GroupManagementRoleWithECPAccess {
    <#
    .SYNOPSIS
    This script will create or manage a management role.

    .DESCRIPTION

    It is designed to allow users to modify Exchange Distribution Groups that they already own via ECP
    However, it limits their ability to create or remove Distribution Groups.
    This is commonly used for mailboxes of DG owners migrated to Office 365

    .PARAMETER Name
    Name of the Management Role you want to create
    Defaults to: "ManageDG"

    .PARAMETER Parent
    Base the Role Entries on the Parent Policy
    Defaults to: "Distribution Groups"

    .EXAMPLE
    New-GroupManagementRoleWithECPAccess
    Add-RoleGroupMember -Identity "User-ManageDG" -Member core@contoso.com

    .EXAMPLE
    New-GroupManagementRoleWithECPAccess -Name ManageDistGroups
    Add-RoleGroupMember -Identity "User-ManageDistGroups" -Member core@contoso.com

    This creates a Management Role named: ManageDG with Role Entries from the Parent 'Distribution Groups'
    It removes the role entries that allow the user to do anything but manage distribution groups via the EMC
    Typically https://hybrid.contoso.com/ecp or similar

    .NOTES
    General notes
    #>

    Param(
        [Parameter()]
        [string] $Name = "ManageDG",

        [Parameter()]
        [string] $Parent = "Distribution Groups"

    )

    If (Get-ManagementRole $Name -erroraction silentlycontinue) {
        Write-Warning "Found a Role with Name: $Name"
        Write-Warning "Check why this Role is already in place"
        Write-Warning "If necessary, rerun with different name parameter"
        break
    }
    Else {
        try {
            New-ManagementRole -Name $Name -Parent $Parent -erroraction stop
            Write-Host "Created Management Role $Name" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create Management Role $Name" -ForegroundColor Red
        }

    }

    $Role = Get-ManagementRoleEntry "$Name\*" | Where-Object {
        $_.Name -ne 'Get-Recipient' -and
        $_.Name -ne 'Remove-DistributionGroupMember' -and
        $_.Name -ne 'Add-DistributionGroupMember' -and
        $_.Name -ne 'Update-DistributionGroupMember' -and
        $_.Name -notlike 'Get-*Group*'
    }

    foreach ($CurRole in $Role) {
        $RoleEntry = '{0}\{1}' -f $CurRole.Role, $CurRole.Name
        try {
            Update-RoleEntry -RoleEntry $RoleEntry Remove -erroraction stop
            Write-Host "Successfully Updated Management Role Entry by Removing: $RoleEntry" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to Update Management Role Entry. Unable to Remove: $RoleEntry" -ForegroundColor Red
        }

    }

    $Roles = $Name
    $RoleGroupName = "User-$Name"

    $RoleGroupSplat = @{
        Name        = $RoleGroupName
        Description = "Members in this management role group can update the membership of the groups they own"
        Roles       = $Roles
    }
    try {
        New-RoleGroup @RoleGroupSplat
        Write-Host "Successfully created Role Group User-$Name" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to create Role Group User-$Name" -ForegroundColor Red
    }


    $Assignment = $Roles + '-' + $RoleGroupName
    try {
        Set-ManagementRoleAssignment $Assignment -RecipientRelativeWriteScope 'MyDistributionGroups'
        Write-Host "Successfully set Management Role Assignment $($Assignment)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to set Management Role Assignment $($Assignment)" -ForegroundColor Red
    }

}
