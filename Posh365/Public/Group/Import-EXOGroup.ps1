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
            if ($CurGroup.RecipientTypeDetails -ne "RoomList") {
                New-DistributionGroup @newparams
            }
            else {
                New-DistributionGroup @newparams -RoomList
            }

            Set-DistributionGroup @setparams

            if ($CurGroups.AcceptMessagesOnlyFrom) {
                $CurGroups.AcceptMessagesOnlyFrom -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFrom @{Add = "$_"}
            }
            if ($CurGroups.AcceptMessagesOnlyFromDLMembers) {
                $CurGroups.AcceptMessagesOnlyFromDLMembers -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFromDLMembers @{Add = "$_"}
            }
            if ($CurGroups.BypassModerationFromSendersOrMembers) {
                $CurGroups.BypassModerationFromSendersOrMembers -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -BypassModerationFromSendersOrMembers @{Add = "$_"}
            }
            if ($CurGroups.GrantSendOnBehalfTo) {
                $CurGroups.GrantSendOnBehalfTo -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -GrantSendOnBehalfTo @{Add = "$_"}
            }
            if ($CurGroups.ManagedBy) {
                $CurGroups.ManagedBy -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -ManagedBy @{Add = "$_"}
            }
            if ($CurGroups.ModeratedBy) {
                $CurGroups.ModeratedBy -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -ModeratedBy @{Add = "$_"}
            }
            if ($CurGroups.RejectMessagesFrom) {
                $CurGroups.RejectMessagesFrom -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFrom @{Add = "$_"}
            }
            if ($CurGroups.RejectMessagesFromDLMembers) {
                $CurGroups.RejectMessagesFromDLMembers -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromDLMembers @{Add = "$_"}
            }
            if ($CurGroups.RejectMessagesFromSendersOrMembers) {
                $CurGroups.RejectMessagesFromSendersOrMembers -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromSendersOrMembers @{Add = "$_"}
            }
            if ($CurGroups.ExtensionCustomAttribute1) {
                $CurGroups.ExtensionCustomAttribute1 -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute1 @{Add = "$_"}
            }
            if ($CurGroups.ExtensionCustomAttribute2) {
                $CurGroups.ExtensionCustomAttribute2 -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute2 @{Add = "$_"}
            }
            if ($CurGroups.ExtensionCustomAttribute3) {
                $CurGroups.ExtensionCustomAttribute3 -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute3 @{Add = "$_"}
            }
            if ($CurGroups.ExtensionCustomAttribute4) {
                $CurGroups.ExtensionCustomAttribute4 -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute4 @{Add = "$_"}
            }
            if ($CurGroups.ExtensionCustomAttribute5) {
                $CurGroups.ExtensionCustomAttribute5 -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute5 @{Add = "$_"}
            }
            if ($CurGroups.MailTipTranslations) {
                $CurGroups.MailTipTranslations -Split ";" | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -MailTipTranslations @{Add = "$_"}
            }
            if ($CurGroups.EmailAddresses) {
                $CurGroups.EmailAddresses -Split ";" | Where-Object {!($_ -clike "SMTP:*")} | 
                    Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_"}
            }
            if ($CurGroups.x500) {
                Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$($CurGroups.x500)"}
            }
            if ($CurGroups.membersSMTP) {
                $CurGroups.membersSMTP -Split ";" | 
                    Add-DistributionGroupMember -Identity $CurGroup.Identity -member "$_"
            }
            
        }
    }
    End {
        
    }
}