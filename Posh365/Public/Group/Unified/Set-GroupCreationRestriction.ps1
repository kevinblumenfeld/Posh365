
function Set-GroupCreationRestriction {
    <#
    .SYNOPSIS
    Choose one group from Out-GridView to manage all Groups and Teams Creation

    .DESCRIPTION
    Choose one group from Out-GridView to manage all Groups and Teams Creation

    .PARAMETER AllowGroupCreation
    False by default, thus all not in group (chosen) are restricted from creating 365 Unified Groups and Microsoft Teams
    There is no need to use this parameter unless it is desired to open creation back up to all users.

    If this parameter is set to $true, all users will be able to manage all Groups and Teams Creation

    .EXAMPLE
    Set-GroupCreationRestriction

    .NOTES
    This disable the ability to create groups in all Office 365 services that use groups, including:

    Outlook

    SharePoint

    Yammer

    Microsoft Teams

    Microsoft Stream

    StaffHub

    Planner

    PowerBI

    Roadmap

    #>

    param (

        [Parameter()]
        [switch]
        $AllowGroupCreation = $false
    )


    $GroupChoice = Get-AzureADGroup -All:$true | Select-Object DisplayName, Description, Mail, DirSyncEnabled, SecurityEnabled, Objectid |
    Out-GridView -Title 'Select one group to manage creation of Office 365 Groups and Microsoft Teams' -OutputMode Single

    if (-not $GroupChoice) { return }

    $SettingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value 'Group.Unified' -EQ).id

    if ( -not $SettingsObjectID) {
        $Template = Get-AzureADDirectorySettingTemplate | Where-object { $_.DisplayName -eq 'Group.Unified' }
        $SettingsCopy = $Template.CreateDirectorySetting()
        New-AzureADDirectorySetting -DirectorySetting $SettingsCopy
        $SettingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value 'Group.Unified' -EQ).id
    }

    $SettingsCopy = Get-AzureADDirectorySetting -Id $SettingsObjectID
    $SettingsCopy['EnableGroupCreation'] = $AllowGroupCreation
    $SettingsCopy['GroupCreationAllowedGroupId'] = $GroupChoice.objectid

    Set-AzureADDirectorySetting -Id $SettingsObjectID -DirectorySetting $SettingsCopy

    (Get-AzureADDirectorySetting -Id $SettingsObjectID).Values

}