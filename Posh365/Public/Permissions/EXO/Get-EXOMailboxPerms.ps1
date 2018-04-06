Function Get-EXOMailboxPerms {  
    <#
    .SYNOPSIS
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports
    Also a file containing Users & Groups can be used to isolate report to specific mailboxes.  The file must contain users and groups.
    Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.

    Output CSVs headers:
    "Mailbox","MailboxPrimarySMTP","Granted","GrantedPrimarySMTP","RecipientTypeDetails","Permission"

    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -ReportPath C:\PermsReports -Verbose
    
    .EXAMPLE
    Get-EXOMailboxPerms -Tenant Contoso -ReportPath C:\PermsReports -ListofUPNs c:\scripts\upns.txt
    
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
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,

        [Parameter(Mandatory = $true)]
        [string] $Tenant,

        [Parameter(Mandatory = $false)]
        [System.IO.FileInfo] $SpecificUsersandGroups,

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

    Write-Verbose "Getting recipients"
    if ($SpecificUsersandGroups) {
        $UPNS = Get-Content $SpecificUsersandGroups
        $allrecipients = foreach ($upn in $upns) {
            Get-Recipient $upn -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup -ErrorAction SilentlyContinue
        }
    }
    else {
        $AllRecipients = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup
    }
    
    $AllMailboxDNs = ($allRecipients | Where-Object {$_.RecipientTypeDetails -in 'UserMailbox', 'RoomMailbox', 'EquipmentMailbox', 'SharedMailbox'}).distinguishedname 

    Write-Verbose "Caching hash tables needed"
    $RecipientHash = $AllRecipients | Get-RecipientHash
    $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
    $RecipientDNHash = $AllRecipients | Get-RecipientDNHash
    $RecipientLiveIDHash = $AllRecipients | Get-RecipientLiveIDHash

    if (! $SkipSendAs) {
        Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
        $allMailboxDNs | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
            Export-csv (Join-Path $ReportPath "EXOSendAsPerms.csv") -NoTypeInformation
    }
    if (! $SkipSendOnBehalf) {
        Write-Verbose "Getting SendOnBehalf permissions for each mailbox and writing to file"
        $AllMailboxDNs | Get-EXOSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash |
            Export-csv (Join-Path $ReportPath "EXOSendOnBehalfPerms.csv") -NoTypeInformation
    }
    if (! $SkipFullAccess) {
        Write-Verbose "Getting FullAccess permissions for each mailbox and writing to file"
        $AllMailboxDNs | Get-EXOFullAccessPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
            Export-csv (Join-Path $ReportPath "EXOFullAccessPerms.csv") -NoTypeInformation
    }

    $AllPermissions = $null
    Get-ChildItem -Path $ReportPath -Filter "*.csv" -Exclude "*allEXOpermissions.csv" -Recurse | % {
        $AllPermissions += (import-csv $_)
    }
    $AllPermissions | Export-Csv (Join-Path $ReportPath "AllEXOPermissions.csv") -NoTypeInformation
    Write-Verbose "Combined all CSV's into a single file named, AllEXOPermissions.csv"
}