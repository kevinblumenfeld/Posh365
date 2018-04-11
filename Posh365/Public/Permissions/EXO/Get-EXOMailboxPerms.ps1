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
            $null = Get-AcceptedDomain -ErrorAction Stop
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
                Get-Recipient -Filter $filter -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup -ErrorAction SilentlyContinue
            }
            if ($each) {
                $allrecipients.add($each)
            }
        }
        else {
            $AllRecipients = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup
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
            Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
            $allMailboxDNs | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
                Export-csv (Join-Path $ReportPath ($tenant + "-EXOPermissions_SendAs.csv")) -NoTypeInformation
        }
        if (! $SkipSendOnBehalf) {
            Write-Verbose "Getting SendOnBehalf permissions for each mailbox and writing to file"
            $AllMailboxDNs | Get-EXOSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash |
                Export-csv (Join-Path $ReportPath ($tenant + "-EXOPermissions_SendOnBehalf.csv")) -NoTypeInformation
        }
        if (! $SkipFullAccess) {
            Write-Verbose "Getting FullAccess permissions for each mailbox and writing to file"
            $AllMailboxDNs | Get-EXOFullAccessPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
                Export-csv (Join-Path $ReportPath ($tenant + "-EXOPermissions_FullAccess.csv")) -NoTypeInformation
        }
        $AllPermissions = $null
        Get-ChildItem -Path $ReportPath -Include "*-EXOPermissions_FullAccess.csv", "*-EXOPermissions_SendOnBehalf.csv", "*-EXOPermissions_SendAs.csv" -Recurse | % {
            $AllPermissions += (import-csv $_)
        }
        $AllPermissions | Export-Csv (Join-Path $ReportPath ($tenant + "-EXOPermissions_All.csv")) -NoTypeInformation
        Write-Verbose "Combined all CSV's into a single file named, AllEXOPermissions.csv"
    }
}