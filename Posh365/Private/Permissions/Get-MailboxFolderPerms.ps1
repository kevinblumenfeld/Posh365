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
        $MailboxList,

        [parameter()]
        [hashtable] $ADHashDisplayName
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting: `t $Mailbox"

            $Calendar = (($Mailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics -Identity $Mailbox.UserPrincipalName -FolderScope Calendar | Select-Object -First 1).Name)
            $Inbox = (($Mailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics -Identity $Mailbox.UserPrincipalName -FolderScope Inbox | Select-Object -First 1).Name)
            $SentItems = (($Mailbox.SamAccountName) + ":\" + (Get-MailboxFolderStatistics -Identity $Mailbox.UserPrincipalName -FolderScope SentItems | Select-Object -First 1).Name)

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
                        GrantedUPN         = $ADHashDisplayName.($CalAccess.User).UserPrincipalName
                        GrantedSMTP        = $ADHashDisplayName.($CalAccess.User).PrimarySMTPAddress
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
                        Granted            = $CalAccess.User
                        GrantedUPN         = $ADHashDisplayName.($CalAccess.User).UserPrincipalName
                        GrantedSMTP        = $ADHashDisplayName.($CalAccess.User).PrimarySMTPAddress
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
                        Granted            = $CalAccess.User
                        GrantedUPN         = $ADHashDisplayName.($CalAccess.User).UserPrincipalName
                        GrantedSMTP        = $ADHashDisplayName.($CalAccess.User).PrimarySMTPAddress
                    }
                }
            }
        }
    }
    end {

    }
}
