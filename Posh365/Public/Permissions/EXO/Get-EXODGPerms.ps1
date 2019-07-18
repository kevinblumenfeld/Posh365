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
    "Object","ObjectPrimarySMTP","Granted","GrantedPrimarySMTP","RecipientTypeDetails","Permission"

    .PARAMETER Path
    Parameter description

    .PARAMETER SpecificUsersandGroups
    Parameter description

    .PARAMETER SkipSendAs
    Parameter description

    .PARAMETER SkipSendOnBehalf
    Parameter description

    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -Path C:\PermsReports -Verbose

    .EXAMPLE
    Get-Recipient -Filter {EmailAddresses -like "*contoso.com"} -ResultSize Unlimited | Select -ExpandProperty name | Get-EXODGPerms -Tenant Contoso -Path C:\PermsReports

    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -Path C:\PermsReports -SkipFullAccess -Verbose

    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -Path C:\PermsReports -SkipSendOnBehalf -Verbose

    .EXAMPLE
    Get-EXODGPerms -Tenant Contoso -Path C:\PermsReports -SkipSendAs -SkipFullAccess -Verbose

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

        [Parameter(ValueFromPipeline)]
        [string[]]
        $SpecificUsersandGroups
    )
    begin {
        $allrecipients = [System.Collections.Generic.List[PSObject]]::new()
    }
    process {
        New-Item -ItemType Directory -Path $Path -ErrorAction SilentlyContinue

        if ($SpecificUsersandGroups) {
            $each = foreach ($CurUserGroup in $SpecificUsersandGroups) {
                $filter = { name -eq '{0}' } -f $CurUserGroup
                Get-Recipient -ResultSize Unlimited -Filter $filter -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup -ErrorAction SilentlyContinue
            }
            if ($each) {
                $allrecipients.add($each)
            }
        }
        else {
            $AllRecipients = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup
        }
    }
    end {
        $AllDGDNs = ($allRecipients | Where-Object { $_.RecipientTypeDetails -in 'MailUniversalDistributionGroup', 'MailUniversalSecurityGroup' }).distinguishedname

        Write-Verbose "Caching hash tables needed"
        $RecipientHash = $AllRecipients | Get-RecipientHash
        $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
        $RecipientDNHash = $AllRecipients | Get-RecipientDNHash
        $RecipientLiveIDHash = $AllRecipients | Get-RecipientLiveIDHash

        if (-not $SkipSendAs) {
            Write-Verbose "Getting SendAs permissions for each Distribution Group and writing to file"
            $AllDGDNs | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
            Export-Csv (Join-Path $Path "EXO_DGSendAs.csv") -NoTypeInformation
        }
        if (-not $SkipSendOnBehalf) {
            Write-Verbose "Getting SendOnBehalf permissions for each Distribution Group and writing to file"
            $AllDGDNs | Get-EXOSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash |
            Export-Csv (Join-Path $Path "EXO_DGSendOnBehalf.csv") -NoTypeInformation
        }
    }
}
