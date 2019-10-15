function Get-MailboxFolderPerms {
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $MailboxList,

        [parameter()]
        [hashtable]
        $ADHashDisplayName,

        [parameter()]
        [hashtable]
        $ADHashType,

        [parameter()]
        [hashtable]
        $ADHashDisplay,

        [parameter()]
        [hashtable]
        $UserGroupHash,

        [parameter()]
        [hashtable]
        $GroupMemberHash
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting: `t $Mailbox"
            $StatSplat = @{
                Identity    = $Mailbox.UserPrincipalName
                ErrorAction = 'SilentlyContinue'
            }
            $Calendar = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Calendar | Select-Object -First 1).Name)
            $Inbox = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Inbox | Select-Object -First 1).Name)
            $SentItems = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope SentItems | Select-Object -First 1).Name)
            $Contacts = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Contacts | Select-Object -First 1).Name)
            $CalAccessList = Get-MailboxFolderPermission $Calendar | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT User:*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($CalAccessList) {
                Foreach ($CalAccess in $CalAccessList) {
                    $Logon = $ADHashDisplayName[$CalAccess.User].logon
                    $DisplayType = $ADHashDisplayName[$CalAccess.User].msExchRecipientDisplayType
                    if ($GroupMemberHash[$Logon].Members -and
                        $ADHashDisplay["$DisplayType"] -match 'group') {
                        foreach ($Member in @($GroupMemberHash.$Logon.Members)) {
                            Write-Verbose "  Member:`t$Member"
                            New-Object -TypeName psobject -property @{
                                Object             = $Mailbox.DisplayName
                                UserPrincipalName  = $Mailbox.UserPrincipalName
                                PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                                Folder             = 'CALENDAR'
                                AccessRights       = ($CalAccess.AccessRights) -join ','
                                Granted            = $UserGroupHash[$Member].DisplayName
                                GrantedUPN         = $UserGroupHash[$Member].UserPrincipalName
                                GrantedSMTP        = $UserGroupHash[$Member].PrimarySMTPAddress
                                TypeDetails        = "GroupMember"
                                DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($CalAccess.User)".msExchRecipientDisplayType)"
                            }
                        }
                    }
                    elseif ( $ADHashDisplayName[$CalAccess.User].objectClass -notmatch 'group') {
                        New-Object -TypeName psobject -property @{
                            Object             = $Mailbox.DisplayName
                            UserPrincipalName  = $Mailbox.UserPrincipalName
                            PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                            Folder             = 'CALENDAR'
                            AccessRights       = ($CalAccess.AccessRights) -join ','
                            Granted            = $CalAccess.User
                            GrantedUPN         = $ADHashDisplayName."$($CalAccess.User)".UserPrincipalName
                            GrantedSMTP        = $ADHashDisplayName."$($CalAccess.User)".PrimarySMTPAddress
                            TypeDetails        = $ADHashType."$($ADHashDisplayName."$($CalAccess.User)".msExchRecipientTypeDetails)"
                            DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($CalAccess.User)".msExchRecipientDisplayType)"
                        }
                    }
                }
            }
            $InboxAccessList = Get-MailboxFolderPermission $Inbox | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT User:*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($InboxAccessList) {
                Foreach ($InboxAccess in $InboxAccessList) {
                    $Logon = $ADHashDisplayName[$InboxAccess.User].logon
                    $DisplayType = $ADHashDisplayName[$InboxAccess.User].msExchRecipientDisplayType
                    if ($GroupMemberHash[$Logon].Members -and
                        $ADHashDisplay["$DisplayType"] -match 'group') {
                        foreach ($Member in @($GroupMemberHash.$Logon.Members)) {
                            Write-Verbose "  Member:`t$Member"
                            New-Object -TypeName psobject -property @{
                                Object             = $Mailbox.DisplayName
                                UserPrincipalName  = $Mailbox.UserPrincipalName
                                PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                                Folder             = 'INBOX'
                                AccessRights       = ($InboxAccess.AccessRights) -join ','
                                Granted            = $UserGroupHash[$Member].DisplayName
                                GrantedUPN         = $UserGroupHash[$Member].UserPrincipalName
                                GrantedSMTP        = $UserGroupHash[$Member].PrimarySMTPAddress
                                TypeDetails        = "GroupMember"
                                DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($InboxAccess.User)".msExchRecipientDisplayType)"
                            }
                        }
                    }
                    elseif ( $ADHashDisplayName[$InboxAccess.User].objectClass -notmatch 'group') {
                        New-Object -TypeName psobject -property @{
                            Object             = $Mailbox.DisplayName
                            UserPrincipalName  = $Mailbox.UserPrincipalName
                            PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                            Folder             = 'INBOX'
                            AccessRights       = ($InboxAccess.AccessRights) -join ','
                            Granted            = $InboxAccess.User
                            GrantedUPN         = $ADHashDisplayName."$($InboxAccess.User)".UserPrincipalName
                            GrantedSMTP        = $ADHashDisplayName."$($InboxAccess.User)".PrimarySMTPAddress
                            TypeDetails        = $ADHashType."$($ADHashDisplayName."$($InboxAccess.User)".msExchRecipientTypeDetails)"
                            DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($InboxAccess.User)".msExchRecipientDisplayType)"
                        }
                    }
                }
            }
            $SentAccessList = Get-MailboxFolderPermission $SentItems | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT User:*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($SentAccessList) {
                Foreach ($SentAccess in $SentAccessList) {
                    $Logon = $ADHashDisplayName[$SentAccess.User].logon
                    $DisplayType = $ADHashDisplayName[$SentAccess.User].msExchRecipientDisplayType
                    if ($GroupMemberHash[$Logon].Members -and
                        $ADHashDisplay["$DisplayType"] -match 'group') {
                        foreach ($Member in @($GroupMemberHash.$Logon.Members)) {
                            Write-Verbose "  Member:`t$Member"
                            New-Object -TypeName psobject -property @{
                                Object             = $Mailbox.DisplayName
                                UserPrincipalName  = $Mailbox.UserPrincipalName
                                PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                                Folder             = 'SENTITEMS'
                                AccessRights       = ($SentAccess.AccessRights) -join ','
                                Granted            = $UserGroupHash[$Member].DisplayName
                                GrantedUPN         = $UserGroupHash[$Member].UserPrincipalName
                                GrantedSMTP        = $UserGroupHash[$Member].PrimarySMTPAddress
                                TypeDetails        = "GroupMember"
                                DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($SentAccess.User)".msExchRecipientDisplayType)"
                            }
                        }
                    }
                    elseif ( $ADHashDisplayName[$SentAccess.User].objectClass -notmatch 'group') {
                        New-Object -TypeName psobject -property @{
                            Object             = $Mailbox.DisplayName
                            UserPrincipalName  = $Mailbox.UserPrincipalName
                            PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                            Folder             = 'SENTITEMS'
                            AccessRights       = ($SentAccess.AccessRights) -join ','
                            Granted            = $SentAccess.User
                            GrantedUPN         = $ADHashDisplayName."$($SentAccess.User)".UserPrincipalName
                            GrantedSMTP        = $ADHashDisplayName."$($SentAccess.User)".PrimarySMTPAddress
                            TypeDetails        = $ADHashType."$($ADHashDisplayName."$($SentAccess.User)".msExchRecipientTypeDetails)"
                            DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($SentAccess.User)".msExchRecipientDisplayType)"
                        }
                    }
                }
            }
            $ContactsAccessList = Get-MailboxFolderPermission $Contacts | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT User:*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($ContactsAccessList) {
                Foreach ($ContactsAccess in $ContactsAccessList) {
                    $Logon = $ADHashDisplayName[$ContactsAccess.User].logon
                    $DisplayType = $ADHashDisplayName[$ContactsAccess.User].msExchRecipientDisplayType
                    if ($GroupMemberHash[$Logon].Members -and
                        $ADHashDisplay["$DisplayType"] -match 'group') {
                        foreach ($Member in @($GroupMemberHash.$Logon.Members)) {
                            Write-Verbose "  Member:`t$Member"
                            New-Object -TypeName psobject -property @{
                                Object             = $Mailbox.DisplayName
                                UserPrincipalName  = $Mailbox.UserPrincipalName
                                PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                                Folder             = 'CONTACTS'
                                AccessRights       = ($ContactsAccess.AccessRights) -join ','
                                Granted            = $UserGroupHash[$Member].DisplayName
                                GrantedUPN         = $UserGroupHash[$Member].UserPrincipalName
                                GrantedSMTP        = $UserGroupHash[$Member].PrimarySMTPAddress
                                TypeDetails        = "GroupMember"
                                DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($ContactsAccess.User)".msExchRecipientDisplayType)"
                            }
                        }
                    }
                    elseif ( $ADHashDisplayName[$ContactsAccess.User].objectClass -notmatch 'group') {
                        New-Object -TypeName psobject -property @{
                            Object             = $Mailbox.DisplayName
                            UserPrincipalName  = $Mailbox.UserPrincipalName
                            PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                            Folder             = 'CONTACTS'
                            AccessRights       = ($ContactsAccess.AccessRights) -join ','
                            Granted            = $ContactsAccess.User
                            GrantedUPN         = $ADHashDisplayName."$($ContactsAccess.User)".UserPrincipalName
                            GrantedSMTP        = $ADHashDisplayName."$($ContactsAccess.User)".PrimarySMTPAddress
                            TypeDetails        = $ADHashType."$($ADHashDisplayName."$($ContactsAccess.User)".msExchRecipientTypeDetails)"
                            DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($ContactsAccess.User)".msExchRecipientDisplayType)"
                        }
                    }
                }
            }
        }
    }
    end {

    }
}
