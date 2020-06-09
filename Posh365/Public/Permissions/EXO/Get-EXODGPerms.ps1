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
    "Object","PrimarySmtpAddress","Granted","GrantedSMTP","RecipientTypeDetails","Permission"

    .PARAMETER SpecificUsersandGroups
    Parameter description

    .PARAMETER SkipSendAs
    Parameter description

    .PARAMETER SkipSendOnBehalf
    Parameter description

    .EXAMPLE
    Get-EXODGPerms

    .EXAMPLE
    Get-Recipient -Filter {EmailAddresses -like "*contoso.com"} -ResultSize Unlimited | Select -ExpandProperty name | Get-EXODGPerms

    #>
    [CmdletBinding()]
    param (
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
        $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
        if (-not (Test-Path $PoshPath)) {
            $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
        }
    }
    process {
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
        $AllDGDNs = $allRecipients | Where-Object { $_.RecipientTypeDetails -in 'MailUniversalDistributionGroup', 'MailUniversalSecurityGroup', 'MailNonUniversalGroup' }
        $AllDGSA = $AllDGDNs.ExternalDirectoryObjectId
        $AllDGSOB = $AllDGDNs
        Write-Host "Caching hash tables needed"
        $RecipientHash = $AllRecipients | Get-RecipientHash
        $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
        $RecipientDNHash = $AllRecipients | Get-RecipientDNHash
        $RecipientLiveIDHash = $AllRecipients | Get-RecipientLiveIDHash
        $RecipientNameHash = $AllRecipients | Get-RecipientNameHash

        if (-not $SkipSendAs) {
            Write-Host "`r`n`r`nGetting SendAs permissions for each Distribution Group and writing to file`r`n" -ForegroundColor Yellow
            $AllDGSA | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientLiveIDHash $RecipientLiveIDHash |
            Export-Csv (Join-Path $PoshPath "EXO_DGSendAs.csv") -NoTypeInformation
        }
        if (-not $SkipSendOnBehalf) {
            Write-Host "`r`n`r`nGetting SendOnBehalf permissions for each Distribution Group and writing to file`r`n" -ForegroundColor Yellow
            $AllDGSOB | Get-EXODGSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash -RecipientNameHash $RecipientNameHash |
            Export-Csv (Join-Path $PoshPath "EXO_DGSendOnBehalf.csv") -NoTypeInformation
        }
    }
}
