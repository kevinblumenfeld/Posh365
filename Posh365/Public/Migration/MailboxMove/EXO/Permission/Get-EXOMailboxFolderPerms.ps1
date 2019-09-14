function Get-EXOMailboxFolderPerms {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory)]
        $MailboxList
    )
    end {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting:`t $($Mailbox.DisplayName)"
            $StatSplat = @{
                Identity = $Mailbox.UserPrincipalName
            }
            $Calendar = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Calendar | Select-Object -First 1).Name)
            $Inbox = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Inbox | Select-Object -First 1).Name)
            $SentItems = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope SentItems | Select-Object -First 1).Name)
            $Contacts = (($Mailbox.UserPrincipalName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Contacts | Select-Object -First 1).Name)
            $CalAccessList = Get-MailboxFolderPermission $Calendar | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT:S-1-5*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($CalAccessList) {
                Foreach ($CalAccess in $CalAccessList) {
                    [PSCustomObject]@{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Folder             = 'CALENDAR'
                        AccessRights       = ($CalAccess.AccessRights) -join ','
                        Granted            = $CalAccess.user.DisplayName
                        GrantedSMTP        = $CalAccess.user.adrecipient.PrimarySMTPAddress
                        TypeDetails        = $CalAccess.user.adrecipient.RecipientTypeDetails
                    }
                }
            }
            $InboxAccessList = Get-MailboxFolderPermission $Inbox | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT:S-1-5*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($InboxAccessList) {
                Foreach ($InboxAccess in $InboxAccessList) {
                    [PSCustomObject]@{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Folder             = 'INBOX'
                        AccessRights       = ($InboxAccess.AccessRights) -join ','
                        Granted            = $InboxAccess.user.DisplayName
                        GrantedSMTP        = $InboxAccess.user.adrecipient.PrimarySMTPAddress
                        TypeDetails        = $InboxAccess.user.adrecipient.RecipientTypeDetails
                    }
                }
            }
            $SentAccessList = Get-MailboxFolderPermission $SentItems | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT:S-1-5*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($SentAccessList) {
                Foreach ($SentAccess in $SentAccessList) {
                    [PSCustomObject]@{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Folder             = 'SENTITEMS'
                        AccessRights       = ($SentAccess.AccessRights) -join ','
                        Granted            = $SentAccess.user.DisplayName
                        GrantedSMTP        = $SentAccess.user.adrecipient.PrimarySMTPAddress
                        TypeDetails        = $SentAccess.user.adrecipient.RecipientTypeDetails
                    }
                }
            }
            $ContactsAccessList = Get-MailboxFolderPermission $Contacts | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT:S-1-5*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($ContactsAccessList) {
                Foreach ($ContactsAccess in $ContactsAccessList) {
                    [PSCustomObject]@{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Folder             = 'CONTACTS'
                        AccessRights       = ($ContactsAccess.AccessRights) -join ','
                        Granted            = $ContactsAccess.user.DisplayName
                        GrantedSMTP        = $ContactsAccess.user.adrecipient.PrimarySMTPAddress
                        TypeDetails        = $ContactsAccess.user.adrecipient.RecipientTypeDetails
                    }
                }
            }
        }
    }
}
