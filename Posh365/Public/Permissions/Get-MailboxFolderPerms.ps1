function Get-MailboxFolderPerms {
    <#
    .SYNOPSIS
    Outputs Mailbox Folder Permissions for each object that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+
    It needs to be run on the version for the mailbox where we seek permissions.

    .EXAMPLE

    Get-Mailbox -ResultSize unlimited | Get-MailboxFolderPerms | Export-csv .\MailboxFolderPerms.csv -NoTypeInformation

    If not running from Exchange Management Shell (EMS), run this first:

    Connect-Exchange -NoPrefix

    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $Mailbox
    )
    Begin {
        Try {
            import-module ActiveDirectory -ErrorAction Stop -Verbose:$false
        }
        Catch {
            Write-Host "This module depends on the ActiveDirectory module."
            Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
            throw
        }
    }
    Process {
        ForEach ($CurMailbox in $Mailbox) {

            Write-Verbose "Inspecting: `t $CurMailbox"

            $Calendar = (($CurMailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics -Identity $CurMailbox.UserPrincipalName -FolderScope Calendar | Select-Object -First 1).Name)
            $Inbox = (($CurMailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics -Identity $CurMailbox.UserPrincipalName -FolderScope Inbox | Select-Object -First 1).Name)
            $SentItems = (($CurMailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics -Identity $CurMailbox.UserPrincipalName -FolderScope SentItems | Select-Object -First 1).Name)

            $CalAccess = Get-MailboxFolderPermission $Calendar | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($CalAccess) {
                Foreach ($CurCalAccess in $CalAccess) {
                    New-Object -TypeName psobject -property @{
                        DisplayName        = $CurMailbox.DisplayName
                        PrimarySMTPAddress = $CurMailbox.PrimarySMTPAddress
                        UserPrincipalName  = $CurMailbox.UserPrincipalName
                        Folder             = 'CALENDAR'
                        AccessRights       = ($CurCalAccess.AccessRights) -join '|'
                        User               = $CurCalAccess.User
                    }
                }
            }
            else {
                New-Object -TypeName psobject -property @{
                    DisplayName        = $CurMailbox.DisplayName
                    PrimarySMTPAddress = $CurMailbox.PrimarySMTPAddress
                    UserPrincipalName  = $CurMailbox.UserPrincipalName
                    Folder             = 'CALENDAR'
                    AccessRights       = 'None'
                    User               = 'None'
                }
            }

            $InboxAccess = Get-MailboxFolderPermission $Inbox | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($InboxAccess) {
                Foreach ($CurInboxAccess in $InboxAccess) {
                    New-Object -TypeName psobject -property @{
                        DisplayName        = $CurMailbox.DisplayName
                        PrimarySMTPAddress = $CurMailbox.PrimarySMTPAddress
                        UserPrincipalName  = $CurMailbox.UserPrincipalName
                        Folder             = 'INBOX'
                        AccessRights       = ($CurInboxAccess.AccessRights) -join '|'
                        User               = $CurInboxAccess.User
                    }
                }
            }
            else {
                New-Object -TypeName psobject -property @{
                    DisplayName        = $CurMailbox.DisplayName
                    PrimarySMTPAddress = $CurMailbox.PrimarySMTPAddress
                    UserPrincipalName  = $CurMailbox.UserPrincipalName
                    Folder             = 'INBOX'
                    AccessRights       = 'None'
                    User               = 'None'
                }
            }
            $SentAccess = Get-MailboxFolderPermission $SentItems | Where-Object {
                $_.User -notmatch 'Default' -and
                $_.User -notmatch 'Anonymous' -and
                $_.AccessRights -notmatch 'None'
            }
            If ($SentAccess) {
                Foreach ($CurSentAccess in $SentAccess) {
                    New-Object -TypeName psobject -property @{
                        DisplayName        = $CurMailbox.DisplayName
                        PrimarySMTPAddress = $CurMailbox.PrimarySMTPAddress
                        UserPrincipalName  = $CurMailbox.UserPrincipalName
                        Folder             = 'SENTITEMS'
                        AccessRights       = ($CurSentAccess.AccessRights) -join '|'
                        User               = $CurSentAccess.User
                    }
                }
            }
            else {
                New-Object -TypeName psobject -property @{
                    DisplayName        = $CurMailbox.DisplayName
                    PrimarySMTPAddress = $CurMailbox.PrimarySMTPAddress
                    UserPrincipalName  = $CurMailbox.UserPrincipalName
                    Folder             = 'SENTITEMS'
                    AccessRights       = 'None'
                    User               = 'None'
                }
            }
        }

    }
    END {

    }
}
