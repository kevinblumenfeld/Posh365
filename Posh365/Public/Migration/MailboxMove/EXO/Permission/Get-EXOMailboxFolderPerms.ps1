function Get-EXOMailboxFolderPerms {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory)]
        $MailboxList,

        [Parameter(Mandatory)]
        $AllRecipients
    )
    begin {
        $RecipientHash = $AllRecipients | Get-RecipientHash
    }
    end {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting:`t $($Mailbox.DisplayName)"
            $StatSplat = @{
                Identity = $Mailbox.UserPrincipalName
            }
            $Calendar = (($Mailbox.UserPrincipalName) + ":\" + (@(Get-EXOMailboxFolderStatistics @StatSplat -FolderScope Calendar -Verbose:$false) | Select-Object -First 1).Name)
            $Inbox = (($Mailbox.UserPrincipalName) + ":\" + (@(Get-EXOMailboxFolderStatistics @StatSplat -FolderScope Inbox -Verbose:$false) | Select-Object -First 1).Name)
            $SentItems = (($Mailbox.UserPrincipalName) + ":\" + (@(Get-EXOMailboxFolderStatistics @StatSplat -FolderScope SentItems -Verbose:$false) | Select-Object -First 1).Name)
            $Contacts = (($Mailbox.UserPrincipalName) + ":\" + (@(Get-EXOMailboxFolderStatistics @StatSplat -FolderScope Contacts -Verbose:$false) | Select-Object -First 1).Name)
            $CalAccessList = Get-EXOMailboxFolderPermission -Identity $Calendar -Verbose:$false | Where-Object {
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
                        Granted            = $CalAccess.user
                        GrantedSMTP        = $RecipientHash["$($CalAccess.user)"].PrimarySMTPAddress
                        TypeDetails        = $RecipientHash["$($CalAccess.user)"].RecipientTypeDetails
                    }
                }
            }
            $InboxAccessList = Get-EXOMailboxFolderPermission -Identity $Inbox -Verbose:$false | Where-Object {
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
                        Granted            = $InboxAccess.user
                        GrantedSMTP        = $RecipientHash["$($InboxAccess.user)"].PrimarySMTPAddress
                        TypeDetails        = $RecipientHash["$($InboxAccess.user)"].RecipientTypeDetails
                    }
                }
            }
            $SentAccessList = Get-EXOMailboxFolderPermission -Identity $SentItems -Verbose:$false | Where-Object {
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
                        Granted            = $SentAccess.user
                        GrantedSMTP        = $RecipientHash["$($SentAccess.user)"].PrimarySMTPAddress
                        TypeDetails        = $RecipientHash["$($SentAccess.user)"].RecipientTypeDetails
                    }
                }
            }
            $ContactsAccessList = Get-EXOMailboxFolderPermission -Identity $Contacts -Verbose:$false | Where-Object {
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
                        Granted            = $ContactsAccess.user
                        GrantedSMTP        = $RecipientHash["$($ContactsAccess.user)"].PrimarySMTPAddress
                        TypeDetails        = $RecipientHash["$($ContactsAccess.user)"].RecipientTypeDetails
                    }
                }
            }
        }
    }
}
