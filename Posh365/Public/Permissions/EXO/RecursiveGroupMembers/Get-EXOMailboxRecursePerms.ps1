Function Get-EXOMailboxRecursePerms {
    
    <#
    .SYNOPSIS
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports
    Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.

    CSVs headers:
    "Mailbox","MailboxPrimarySMTP","Granted","GrantedPrimarySMTP","RecipientTypeDetails","Permission"

    .EXAMPLE
    Get-EXOMailboxRecursePerms -Tenant Contoso -ReportPath C:\PermsReports -Verbose
    
    .EXAMPLE
    Get-EXOMailboxRecursePerms -Tenant Contoso -ReportPath C:\PermsReports -SkipFullAccess -Verbose
    
    .EXAMPLE
    Get-EXOMailboxRecursePerms -Tenant Contoso -ReportPath C:\PermsReports -SkipSendOnBehalf -Verbose

    .EXAMPLE
    Get-EXOMailboxRecursePerms -Tenant Contoso -ReportPath C:\PermsReports -SkipSendAs -SkipFullAccess -Verbose
    
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
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
        [switch] $SkipFullAccess
    )

    try {
        $null = Get-AcceptedDomain -ErrorAction Stop
    }
    catch {
        Connect-Cloud -Tenant $Tenant -ExchangeOnline
    }
    
    New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue

    Write-Verbose "Getting all recipients"
    $AllRecipients = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup, MailNonUniversalGroup, DynamicDistributionGroup
    $AllMailboxDNs = ($allRecipients | Where-Object {$_.RecipientTypeDetails -in 'UserMailbox', 'RoomMailbox', 'EquipmentMailbox', 'SharedMailbox'}).distinguishedname
    $AllGroupDNs = ($allRecipients | Where-Object {$_.RecipientTypeDetails -in 'NonUniversalGroup', 'MailNonUniversalGroup', 'MailUniversalSecurityGroup', 'MailUniversalDistributionGroup', 'DynamicDistributionGroup', 'UniversalDistributionGroup', 'UniversalSecurityGroup', 'NonUniversalGroup'}).distinguishedname
    $AllGroupNames = ($allRecipients | Where-Object {$_.RecipientTypeDetails -in 'NonUniversalGroup', 'MailNonUniversalGroup', 'MailUniversalSecurityGroup', 'MailUniversalDistributionGroup', 'DynamicDistributionGroup', 'UniversalDistributionGroup', 'UniversalSecurityGroup', 'NonUniversalGroup'}).Name

    Write-Verbose "Caching hash tables needed"
    $RecipientHash = $AllRecipients | Get-RecipientHash
    $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
    $RecipientDNHash = $AllRecipients | Get-RecipientDNHash
    $GroupMemberHash = $AllGroupNames | Get-DistributionGroupMembersHash -Recurse

    if (! $SkipSendAs) {
        Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
        $allMailboxDNs | Get-EXOSendAsRecursePerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash -GroupMemberHash $GroupMemberHash |
            Export-csv (Join-Path $ReportPath "EXOSendAsRecursePerms.csv") -NoTypeInformation
    }
    if (! $SkipSendOnBehalf) {
        Write-Verbose "Getting SendOnBehalf permissions for each mailbox and writing to file"
        $AllMailboxDNs | Get-EXOSendOnBehalfRecursePerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash -GroupMemberHash $GroupMemberHash |
            Export-csv (Join-Path $ReportPath "EXOSendOnBehalfRecursePerms.csv") -NoTypeInformation
    }
    if (! $SkipFullAccess) {
        Write-Verbose "Getting FullAccess permissions for each mailbox and writing to file"
        $AllMailboxDNs | Get-EXOFullAccessRecursePerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash -GroupMemberHash $GroupMemberHash |
            Export-csv (Join-Path $ReportPath "EXOFullAccessRecursePerms.csv") -NoTypeInformation
    }

    $AllPermissions = $null
    Get-ChildItem -Path $ReportPath -Filter "*.csv" -Exclude "*allEXOpermissionsRecurse.csv" -Recurse | % {
        $AllPermissions += (import-csv $_)
    }
    $AllPermissions | Export-Csv (Join-Path $ReportPath "AllEXOPermissionsRecurse.csv") -NoTypeInformation
    Write-Verbose "Combined all CSV's into a single file named, AllEXOPermissionsRecurse.csv"
}
