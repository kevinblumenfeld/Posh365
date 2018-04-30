Function Get-EXODGPerms {  
    <#
    .SYNOPSIS
    By default, creates permissions reports for all Distribution Groups with SendAs, SendOnBehalf and FullAccess delegates.

    .DESCRIPTION
    By default, creates permissions reports for all Distribution Groups with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports
    
    Also a file (or command) containing names of Users & Groups - used to isolate report to specific Distribution Groups.  
    The file must contain users (and groups, as groups can have permissions to Distribution Groups).

    Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.

    Output CSVs headers:
    "Mailbox","MailboxPrimarySMTP","Granted","GrantedPrimarySMTP","RecipientTypeDetails","Permission"

    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -ReportPath C:\PermsReports -Verbose
    
    .EXAMPLE
    Get-Recipient -Filter {EmailAddresses -like "*contoso.com"}  | Select -ExpandProperty name | Get-EXODGPerms -Tenant Contoso -ReportPath C:\PermsReports
    
    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -ReportPath C:\PermsReports -SkipFullAccess -Verbose
    
    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -ReportPath C:\PermsReports -SkipSendOnBehalf -Verbose

    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -ReportPath C:\PermsReports -SkipSendAs -SkipFullAccess -Verbose
    
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
        $AllDGDNs = ($allRecipients | Where-Object {$_.RecipientTypeDetails -in 'MailUniversalDistributionGroup', 'MailUniversalSecurityGroup'}).distinguishedname 

        Write-Verbose "Caching hash tables needed"
        $RecipientHash = $AllRecipients | Get-RecipientHash
        $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
        $RecipientDNHash = $AllRecipients | Get-RecipientDNHash
        $RecipientLiveIDHash = $AllRecipients | Get-RecipientLiveIDHash

        if (! $SkipSendAs) {
            Write-Verbose "Getting SendAs permissions for each Distribution Group and writing to file"
            $AllDGDNs | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
                Export-csv (Join-Path $ReportPath ($tenant + "-EXODGPermissions_SendAs.csv")) -NoTypeInformation
        }
        if (! $SkipSendOnBehalf) {
            Write-Verbose "Getting SendOnBehalf permissions for each Distribution Group and writing to file"
            $AllDGDNs | Get-EXOSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash |
                Export-csv (Join-Path $ReportPath ($tenant + "-EXODGPermissions_SendOnBehalf.csv")) -NoTypeInformation
        }
        $AllPermissions = $null
        $AllPermissions = Get-ChildItem -Path $Report -Depth 0 -Include ($tenant + "-EXODGPermissions_SendAs.csv"), ($tenant + "-EXODGPermissions_SendOnBehalf.csv") -Recurse | % {
            import-csv $_
        }
        $AllPermissions | Export-Csv (Join-Path $ReportPath ($tenant + "-EXODGPermissions_All.csv")) -NoTypeInformation
        Write-Verbose "Combined all CSV's into a single file named, EXODGPermissions_All.csv"
    }
}