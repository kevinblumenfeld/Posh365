function Import-EXOGroup { 
    <#
    .SYNOPSIS
    Import Office 365 Distribution Groups
    
    .DESCRIPTION
    Import Office 365 Distribution Groups
    
    .PARAMETER Groups
    CSV of new groups and attributes to create.
    
    .EXAMPLE
    Import-Csv .\importgroups.csv | Import-EXOGroup


    #>

    [CmdletBinding()]
    Param 
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        $Groups
    )
    Begin {

    }
    Process {
        ForEach ($CurGroup in $Groups) {
            $newhash = @{
                Alias                              = $CurGroup.Alias
                BypassNestedModerationEnabled      = $CurGroup.BypassNestedModerationEnabled
                DisplayName                        = $CurGroup.DisplayName
                IgnoreNamingPolicy                 = $CurGroup.IgnoreNamingPolicy
                ManagedBy                          = $CurGroup.ManagedBy
                MemberDepartRestriction            = $CurGroup.MemberDepartRestriction
                MemberJoinRestriction              = $CurGroup.MemberJoinRestriction
                ModeratedBy                        = $CurGroup.ModeratedBy
                ModerationEnabled                  = $CurGroup.ModerationEnabled
                Name                               = $CurGroup.Name
                Notes                              = $CurGroup.Notes
                PrimarySmtpAddress                 = $CurGroup.PrimarySmtpAddress
                RequireSenderAuthenticationEnabled = $CurGroup.RequireSenderAuthenticationEnabled
                SendModerationNotifications        = $CurGroup.SendModerationNotifications
                Type                               = $CurGroup.Type
            }            
            $sethash = @{
                BypassModerationFromSendersOrMembers = $CurGroup.BypassModerationFromSendersOrMembers
                BypassSecurityGroupManagerCheck      = $CurGroup.BypassSecurityGroupManagerCheck
                CustomAttribute1                     = $CurGroup.CustomAttribute1
                CustomAttribute10                    = $CurGroup.CustomAttribute10
                CustomAttribute11                    = $CurGroup.CustomAttribute11
                CustomAttribute12                    = $CurGroup.CustomAttribute12
                CustomAttribute13                    = $CurGroup.CustomAttribute13
                CustomAttribute14                    = $CurGroup.CustomAttribute14
                CustomAttribute15                    = $CurGroup.CustomAttribute15
                CustomAttribute2                     = $CurGroup.CustomAttribute2
                CustomAttribute3                     = $CurGroup.CustomAttribute3
                CustomAttribute4                     = $CurGroup.CustomAttribute4
                CustomAttribute5                     = $CurGroup.CustomAttribute5
                CustomAttribute6                     = $CurGroup.CustomAttribute6
                CustomAttribute7                     = $CurGroup.CustomAttribute7
                CustomAttribute8                     = $CurGroup.CustomAttribute8
                CustomAttribute9                     = $CurGroup.CustomAttribute9
                ExtensionCustomAttribute1            = $CurGroup.ExtensionCustomAttribute1
                ExtensionCustomAttribute2            = $CurGroup.ExtensionCustomAttribute2
                ExtensionCustomAttribute3            = $CurGroup.ExtensionCustomAttribute3
                ExtensionCustomAttribute4            = $CurGroup.ExtensionCustomAttribute4
                ExtensionCustomAttribute5            = $CurGroup.ExtensionCustomAttribute5
                HiddenFromAddressListsEnabled        = $CurGroup.HiddenFromAddressListsEnabled
                Identity                             = $CurGroup.Identity
                RejectMessagesFrom                   = $CurGroup.RejectMessagesFrom
                RejectMessagesFromDLMembers          = $CurGroup.RejectMessagesFromDLMembers
                RejectMessagesFromSendersOrMembers   = $CurGroup.RejectMessagesFromSendersOrMembers
                ReportToManagerEnabled               = $CurGroup.ReportToManagerEnabled
                ReportToOriginatorEnabled            = $CurGroup.ReportToOriginatorEnabled
                SendOofMessageToOriginatorEnabled    = $CurGroup.SendOofMessageToOriginatorEnabled
                SimpleDisplayName                    = $CurGroup.SimpleDisplayName
                WindowsEmailAddress                  = $CurGroup.WindowsEmailAddress

            }
            $newparams = @{}
            ForEach ($h in $newhash.keys) {
                if ($($newhash.item($h))) {
                    $newparams.add($h, $($newhash.item($h)))
                }
            }            
            $setparams = @{}
            ForEach ($h in $sethash.keys) {
                if ($($sethash.item($h))) {
                    $setparams.add($h, $($sethash.item($h)))
                }
            }
            # if ($CurGroup.RecipientTypeDetails -eq "RoomList") {New-DistributionGroup @newparams -RoomList}
            # else {New-DistributionGroup @newparams}
            New-DistributionGroup @newparams
            Set-DistributionGroup @setparams
        }
    }
    End {
        
    }
}