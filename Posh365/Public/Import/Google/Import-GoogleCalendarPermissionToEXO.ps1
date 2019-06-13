
function Import-GoogleCalendarPermissionToEXO {
    <#
    .SYNOPSIS
    This is specific to Groups but can be tweaked for users specifically.

    .DESCRIPTION
    Assign Groups Permissions to Calendar Folders of 365 mailboxes
    This is specific to Groups but can be tweaked for users specifically.

    .PARAMETER Calendar
    Passed at Pipeline

    .EXAMPLE
    import-csv .\groupsWithPerms.csv | Import-GoogleCalendarPermissionToEXO

    .NOTES
    Headers of CSV
    Calendar	Role	ScopeType	ScopeValue

    #>


    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Calendar

    )
    Begin {

    }
    Process {
        ForEach ($Cal in $Calendar) {

            $Access = switch ($Cal.Role) {
                'Owner' { 'Editor' }
                'Writer' { 'Editor' }
                'Reader' { 'LimitedDetails' }
                'freeBusyReader' { 'LimitedDetails' }
            }

            $filterstring = '{0}:\Calendar' -f $Cal.Calendar

            Write-Host "$filterstring" -ForegroundColor Green

            $MemberList = Get-DistributionGroupMember -identity $Cal.ScopeValue | Where-Object { $_.RecipientTypeDetails -ne 'MailUser' }
            foreach ($Member in $MemberList) {
                Write-Host "$($Member.primarysmtpaddress) $($Member.RecipientTypeDetails)" -ForegroundColor White

                $PermSplat = @{
                    Identity     = $filterstring
                    AccessRights = $Access
                }

                if ($Cal.ScopeType -eq 'Domain') {
                    $PermSplat['User'] = 'Default'
                    $PermSplat['SendNotificationToUser'] = $false
                    Set-MailboxFolderPermission @PermSplat
                }
                else {
                    $PermSplat['User'] = $Member.primarysmtpaddress
                    $PermSplat['SendNotificationToUser'] = $true
                    Add-MailboxFolderPermission @PermSplat
                }
            }
        }
    }
    End {

    }
}
