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
        $ADHashDisplay
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
            $Calendar = (($Mailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Calendar | Select-Object -First 1).Name)
            $Inbox = (($Mailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope Inbox | Select-Object -First 1).Name)
            $SentItems = (($Mailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics @StatSplat -FolderScope SentItems | Select-Object -First 1).Name)
            $CalAccessList = Get-MailboxFolderPermission $Calendar | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.User -notlike 'NT User:*' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($CalAccessList) {
                Foreach ($CalAccess in $CalAccessList) {
                    New-Object -TypeName psobject -property @{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Folder             = 'CALENDAR'
                        AccessRights       = ($CalAccess.AccessRights) -join '|'
                        Granted            = $CalAccess.User
                        GrantedUPN         = $ADHashDisplayName."$($CalAccess.User)".UserPrincipalName
                        GrantedSMTP        = $ADHashDisplayName."$($CalAccess.User)".PrimarySMTPAddress
                        TypeDetails        = $ADHashType."$($ADHashDisplayName."$($CalAccess.User)".msExchRecipientTypeDetails)"
                        DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($CalAccess.User)".msExchRecipientDisplayType)"
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
                    New-Object -TypeName psobject -property @{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Folder             = 'INBOX'
                        AccessRights       = ($InboxAccess.AccessRights) -join '|'
                        Granted            = $InboxAccess.User
                        GrantedUPN         = $ADHashDisplayName."$($InboxAccess.User)".UserPrincipalName
                        GrantedSMTP        = $ADHashDisplayName."$($InboxAccess.User)".PrimarySMTPAddress
                        TypeDetails        = $ADHashType."$($ADHashDisplayName."$($InboxAccess.User)".msExchRecipientTypeDetails)"
                        DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($InboxAccess.User)".msExchRecipientDisplayType)"
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
                    New-Object -TypeName psobject -property @{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Folder             = 'SENTITEMS'
                        AccessRights       = ($SentAccess.AccessRights) -join '|'
                        Granted            = $SentAccess.User
                        GrantedUPN         = $ADHashDisplayName."$($SentAccess.User)".UserPrincipalName
                        GrantedSMTP        = $ADHashDisplayName."$($SentAccess.User)".PrimarySMTPAddress
                        TypeDetails        = $ADHashType."$($ADHashDisplayName."$($SentAccess.User)".msExchRecipientTypeDetails)"
                        DisplayType        = $ADHashDisplay."$($ADHashDisplayName."$($SentAccess.User)".msExchRecipientDisplayType)"
                    }
                }
            }
        }
    }
    end {

    }
}
