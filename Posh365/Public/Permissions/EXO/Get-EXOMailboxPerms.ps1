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

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -ReportPath C:\PermsReports -Verbose

    .EXAMPLE
    Get-Recipient -Filter {EmailAddresses -like "*contoso.com"}  | Select -ExpandProperty name | Get-EXOMailboxPerms -Tenant Contoso -ReportPath C:\PermsReports

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -ReportPath C:\PermsReports -SkipFullAccess -Verbose

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -ReportPath C:\PermsReports -SkipSendOnBehalf -Verbose

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -ReportPath C:\PermsReports -SkipSendAs -SkipFullAccess -Verbose

    .PARAMETER ReportPath
    Parameter description

    .PARAMETER Tenant
    Parameter description

    .PARAMETER SpecificUsersandGroups
    Parameter description

    .PARAMETER SkipSendAs
    Parameter description

    .PARAMETER SkipSendOnBehalf
    Parameter description

    .PARAMETER SkipFullAccess
    Parameter description

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,

        [Parameter(Mandatory = $true)]
        [string] $Tenant,

        [Parameter()]
        [switch] $SkipSendAs,

        [Parameter()]
        [switch] $SkipSendOnBehalf,

        [Parameter()]
        [switch] $SkipFullAccess,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $SpecificUsersandGroups
    )
    Begin {
        try {
            Get-AcceptedDomain -ErrorAction Stop > $null
        }
        catch {
            Connect-Cloud -Tenant $Tenant -ExchangeOnline
        }
        $allrecipients = [System.Collections.Generic.List[PSObject]]::new()
    }
    Process {
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue

        if ($SpecificUsersandGroups) {
            $each = foreach ($CurUserGroup in $SpecificUsersandGroups) {
                $filter = {name -eq '{0}'} -f $CurUserGroup
                Write-Verbose "Fetching filtered recipients to build needed hash tables"
                Get-Recipient -ResultSize Unlimited -Filter $filter -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup -ErrorAction SilentlyContinue
            }
            if ($each) {
                $allrecipients.add($each)
            }
        }
        else {
            Write-Verbose "Fetching recipients to build needed hash tables"
            $AllRecipients = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails MailUser, UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup
        }
    }
    End {

        $AllMailboxDNs = ($allRecipients | Where-Object {$_.RecipientTypeDetails -in 'UserMailbox', 'RoomMailbox', 'EquipmentMailbox', 'SharedMailbox'}).distinguishedname

        Write-Verbose "Caching hash tables needed"
        $RecipientHash = $AllRecipients | Get-RecipientHash
        $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
        $RecipientDNHash = $AllRecipients | Get-RecipientDNHash
        $RecipientLiveIDHash = $AllRecipients | Get-RecipientLiveIDHash

        if (! $SkipSendAs) {
            Write-Verbose "Fetching SendAs permissions for each mailbox and writing to file"
            $allMailboxDNs | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
                Export-csv (Join-Path $ReportPath "EXOSendAsPerms.csv") -NoTypeInformation
        }
        if (! $SkipSendOnBehalf) {
            Write-Verbose "Fetching SendOnBehalf permissions for each mailbox and writing to file"
            $AllMailboxDNs | Get-EXOSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash |
                Export-csv (Join-Path $ReportPath "EXOSendOnBehalfPerms.csv") -NoTypeInformation
        }
        if (! $SkipFullAccess) {
            Write-Verbose "Fetching FullAccess permissions for each mailbox and writing to file"
            $AllMailboxDNs | Get-EXOFullAccessPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
                Export-csv (Join-Path $ReportPath "EXOFullAccessPerms.csv") -NoTypeInformation
        }
        $Report = $ReportPath.ToString()
        $Report = $Report.TrimEnd('\') + "\*"
        $AllPermissions = $null
        $AllPermissions = Get-ChildItem -Path $Report -Include "EXOSendAsPerms.csv", "EXOSendOnBehalfPerms.csv", "EXOFullAccessPerms.csv" -Exclude "EXOAllPermissions.csv" | % {
            import-csv $_
        }
        $AllPermissions | Export-Csv (Join-Path $ReportPath "EXOAllPermissions.csv") -NoTypeInformation
        Write-Verbose "Combined all CSV's into a single file named, EXOAllPermissions.csv"
    }
}