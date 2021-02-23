function Get-PSGGroupDetails {
    [CmdletBinding()]
    Param
    (

    )

    # $GroupList =  Get-GSGroup -Filter *
    # $SettingsList = $GroupList | Get-GSGroupSettings

    $GroupList = Import-Csv C:\Scripts\TAPeople.csv
    $SettingsList = Import-Csv C:\Scripts\TASettings.csv

    $GroupHash = @{ }
    foreach ($Group in $GroupList) {
        <#
        $MemberList = Get-GSGroupMember -Identity $Group.Email
        $OwnerList = $MemberList.where{ $_.Role -eq 'OWNER' }
        $ManagerList = $MemberList.where{ $_.Role -eq 'MANAGER' }
        #>
        $GroupHash[$Group.Email] = @{
            Name               = $Group.Name
            Aliases            = @($Group.Aliases) -ne '' -join '|'
            Description        = $Group.Description
            NonEditableAliases = @($Group.NonEditableAliases) -ne '' -join '|'
            MemberCount        = $Group.DirectMembersCount
            Members            = @($MemberList) -ne '' -join '|'
            ManagerCount       = $ManagerList.Count
            Managers           = @($ManagerList) -ne '' -join '|'
            OwnerCount         = $OwnerList.Count
            Owners             = @($OwnerList) -ne '' -join '|'
        }
    }


    foreach ($Setting in $SettingsList) {

        [PSCustomObject]@{
            Name                                    = $Setting.Name
            Email                                   = $Setting.Email
            Aliases                                 = $GroupHash[$Setting.Email]['Aliases']
            NonEditableAliases                      = $GroupHash[$Setting.Email]['NonEditableAliases']
            MemberCount                             = $GroupHash[$Setting.Email]['MemberCount']
            Members                                 = $GroupHash[$Setting.Email]['Members']
            ManagerCount                            = $GroupHash[$Setting.Email]['ManagerCount']
            Managers                                = $GroupHash[$Setting.Email]['Managers']
            OwnerCount                              = $GroupHash[$Setting.Email]['OwnerCount']
            Owners                                  = $GroupHash[$Setting.Email]['Owners']
            AllowExternalMembers                    = $Setting.AllowExternalMembers
            AllowGoogleCommunication                = $Setting.AllowGoogleCommunication
            AllowWebPosting                         = $Setting.AllowWebPosting
            ArchiveOnly                             = $Setting.ArchiveOnly
            CustomFooterText                        = $Setting.CustomFooterText
            CustomReplyTo                           = $Setting.CustomReplyTo
            CustomRolesEnabledForSettingsToBeMerged = $Setting.CustomRolesEnabledForSettingsToBeMerged
            DefaultMessageDenyNotificationText      = $Setting.DefaultMessageDenyNotificationText
            Description                             = $Setting.Description
            EnableCollaborativeInbox                = $Setting.EnableCollaborativeInbox
            ETag                                    = $Setting.ETag
            FavoriteRepliesOnTop                    = $Setting.FavoriteRepliesOnTop
            Group                                   = $Setting.Group
            IncludeCustomFooter                     = $Setting.IncludeCustomFooter
            IncludeInGlobalAddressList              = $Setting.IncludeInGlobalAddressList
            IsArchived                              = $Setting.IsArchived
            Kind                                    = $Setting.Kind
            MaxMessageBytes                         = $Setting.MaxMessageBytes
            MembersCanPostAsTheGroup                = $Setting.MembersCanPostAsTheGroup
            MessageDisplayFont                      = $Setting.MessageDisplayFont
            MessageModerationLevel                  = $Setting.MessageModerationLevel
            PrimaryLanguage                         = $Setting.PrimaryLanguage
            ReplyTo                                 = $Setting.ReplyTo
            SendMessageDenyNotification             = $Setting.SendMessageDenyNotification
            ShowInGroupDirectory                    = $Setting.ShowInGroupDirectory
            SpamModerationLevel                     = $Setting.SpamModerationLevel
            WhoCanAdd                               = $Setting.WhoCanAdd
            WhoCanAddReferences                     = $Setting.WhoCanAddReferences
            WhoCanApproveMembers                    = $Setting.WhoCanApproveMembers
            WhoCanApproveMessages                   = $Setting.WhoCanApproveMessages
            WhoCanAssignTopics                      = $Setting.WhoCanAssignTopics
            WhoCanAssistContent                     = $Setting.WhoCanAssistContent
            WhoCanBanUsers                          = $Setting.WhoCanBanUsers
            WhoCanContactOwner                      = $Setting.WhoCanContactOwner
            WhoCanDeleteAnyPost                     = $Setting.WhoCanDeleteAnyPost
            WhoCanDeleteTopics                      = $Setting.WhoCanDeleteTopics
            WhoCanDiscoverGroup                     = $Setting.WhoCanDiscoverGroup
            WhoCanEnterFreeFormTags                 = $Setting.WhoCanEnterFreeFormTags
            WhoCanHideAbuse                         = $Setting.WhoCanHideAbuse
            WhoCanInvite                            = $Setting.WhoCanInvite
            WhoCanJoin                              = $Setting.WhoCanJoin
            WhoCanLeaveGroup                        = $Setting.WhoCanLeaveGroup
            WhoCanLockTopics                        = $Setting.WhoCanLockTopics
            WhoCanMakeTopicsSticky                  = $Setting.WhoCanMakeTopicsSticky
            WhoCanMarkDuplicate                     = $Setting.WhoCanMarkDuplicate
            WhoCanMarkFavoriteReplyOnAnyTopic       = $Setting.WhoCanMarkFavoriteReplyOnAnyTopic
            WhoCanMarkFavoriteReplyOnOwnTopic       = $Setting.WhoCanMarkFavoriteReplyOnOwnTopic
            WhoCanMarkNoResponseNeeded              = $Setting.WhoCanMarkNoResponseNeeded
            WhoCanModerateContent                   = $Setting.WhoCanModerateContent
            WhoCanModerateMembers                   = $Setting.WhoCanModerateMembers
            WhoCanModifyMembers                     = $Setting.WhoCanModifyMembers
            WhoCanModifyTagsAndCategories           = $Setting.WhoCanModifyTagsAndCategories
            WhoCanMoveTopicsIn                      = $Setting.WhoCanMoveTopicsIn
            WhoCanMoveTopicsOut                     = $Setting.WhoCanMoveTopicsOut
            WhoCanPostAnnouncements                 = $Setting.WhoCanPostAnnouncements
            WhoCanPostMessage                       = $Setting.WhoCanPostMessage
            WhoCanTakeTopics                        = $Setting.WhoCanTakeTopics
            WhoCanUnassignTopic                     = $Setting.WhoCanUnassignTopic
            WhoCanUnmarkFavoriteReplyOnAnyTopic     = $Setting.WhoCanUnmarkFavoriteReplyOnAnyTopic
            WhoCanViewGroup                         = $Setting.WhoCanViewGroup
            WhoCanViewMembership                    = $Setting.WhoCanViewMembership
        }
    }
}