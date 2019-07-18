Function Get-EXOMailboxPerms {
    <#
    .SYNOPSIS
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.

    .DESCRIPTION
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports

    Also a file (or command) containing names of Users & Groups - used to isolate report to specific mailboxes.
    The file must contain users (and groups, as groups can have permissions to mailboxes).

    Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.

    Output CSVs headers:
    "Mailbox","MailboxPrimarySMTP","Granted","GrantedPrimarySMTP","RecipientTypeDetails","Permission"

    .PARAMETER SpecificUsersandGroups
    Parameter description

    .PARAMETER SkipSendAs
    Parameter description

    .PARAMETER SkipSendOnBehalf
    Parameter description

    .PARAMETER SkipFullAccess
    Parameter description

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -Path C:\PermsReports -Verbose

    .EXAMPLE
    Get-Recipient -Filter {EmailAddresses -like "*contoso.com"}  | Select -ExpandProperty name | Get-EXOMailboxPerms -Tenant Contoso -Path C:\PermsReports

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -Path C:\PermsReports -SkipFullAccess -Verbose

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -Path C:\PermsReports -SkipSendOnBehalf -Verbose

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -Path C:\PermsReports -SkipSendAs -SkipFullAccess -Verbose
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $SkipSendAs,

        [Parameter()]
        [switch]
        $SkipSendOnBehalf,

        [Parameter()]
        [switch]
        $SkipFullAccess,

        [Parameter(ValueFromPipeline)]
        [string[]]
        $SpecificUsersandGroups
    )
    begin {
        $AllRecipients = [System.Collections.Generic.List[PSObject]]::new()
        $SelectRecipient = @(
            'MailUser', 'UserMailbox', 'RoomMailbox', 'EquipmentMailbox',
            'SharedMailbox', 'MailUniversalDistributionGroup', 'MailUniversalSecurityGroup'
        )
    }
    process {
        New-Item -ItemType Directory -Path $Path -ErrorAction SilentlyContinue

        if ($SpecificUsersandGroups) {
            $Each = foreach ($CurUserGroup in $SpecificUsersandGroups) {
                $Filter = { name -eq '{0}' } -f $CurUserGroup
                Write-Verbose "Fetching filtered recipients to build needed hash tables"
                Get-Recipient -ResultSize Unlimited -Filter $Filter -RecipientTypeDetails $SelectRecipient -ErrorAction SilentlyContinue
            }
            if ($Each) {
                $AllRecipients.Add($Each)
            }
        }
        else {
            Write-Verbose "Fetching recipients to build needed hash tables"
            $AllRecipients = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails $SelectRecipient
        }
    }
    end {
        $AllMailboxDNs = ($AllRecipients | Where-Object { $_.RecipientTypeDetails -in 'UserMailbox', 'RoomMailbox', 'EquipmentMailbox', 'SharedMailbox' }).distinguishedname

        Write-Verbose "Caching hash tables needed"
        $RecipientHash = $AllRecipients | Get-RecipientHash
        $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
        $RecipientDNHash = $AllRecipients | Get-RecipientDNHash
        $RecipientLiveIDHash = $AllRecipients | Get-RecipientLiveIDHash

        if (-not $SkipSendAs) {
            Write-Verbose "Fetching SendAs permissions for each mailbox and writing to file"
            $allMailboxDNs | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
            Export-csv (Join-Path $Path "EXO_SendAs.csv") -NoTypeInformation
        }
        if (-not $SkipSendOnBehalf) {
            Write-Verbose "Fetching SendOnBehalf permissions for each mailbox and writing to file"
            $AllMailboxDNs | Get-EXOSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash |
            Export-csv (Join-Path $Path "EXO_SendOnBehalf.csv") -NoTypeInformation
        }
        if (-not $SkipFullAccess) {
            Write-Verbose "Fetching FullAccess permissions for each mailbox and writing to file"
            $AllMailboxDNs | Get-EXOFullAccessPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
            Export-Csv (Join-Path $Path "EXO_FullAccess.csv") -NoTypeInformation
        }
    }
}
