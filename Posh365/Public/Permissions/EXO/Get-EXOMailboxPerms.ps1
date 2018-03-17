Function Get-EXOMailboxPerms {
    
    <#
    .SYNOPSIS
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports
    Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.

    CSVs headers:
    "Mailbox","UPN","Granted","GrantedUPN","Permission"

    .EXAMPLE
    Get-EXOMailboxPerms -ReportPath C:\PermsReports
    
    .EXAMPLE
    Get-EXOMailboxPerms -ReportPath C:\PermsReports -SkipFullAccess
    
    .EXAMPLE
    Get-EXOMailboxPerms -ReportPath C:\PermsReports -SkipSendOnBehalf

    .EXAMPLE
    Get-EXOMailboxPerms -ReportPath C:\PermsReports -SkipSendAs -SkipFullAccess
    
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

    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $User = $env:USERNAME

    try {
        $null = Get-AcceptedDomain -ErrorAction Stop
    }
    catch {
        Connect-Cloud -Tenant $Tenant -ExchangeOnline
    }
    
    New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
    Set-Location $ReportPath

    Write-Output "Get Recipient"
    $AllRecipients = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails UserMailbox, RoomMailbox, EquipmentMailbox, SharedMailbox, MailUniversalDistributionGroup, MailUniversalSecurityGroup
    $AllMailboxDNs = ($allRecipients | Where-Object {$_.RecipientTypeDetails -in 'UserMailbox', 'RoomMailbox', 'EquipmentMailbox', 'SharedMailbox'}).distinguishedname 

    Write-Output "Caching hash table. Name as Key and Value of PrimarySMTPAddress"
    $RecipientHash = $AllRecipients | Get-RecipientHash
    $RecipientMailHash = $AllRecipients | Get-RecipientMailHash
    $RecipientDNHash = $AllRecipients | Get-RecipientDNHash

    # Write-Output "Caching hash table. DN as Key and Values of DisplayName, UPN & LogonName"
    # $ADHashDN = $AllRecipients | Get-ADHashDN

    # Write-Output "Caching hash table. CN as Key and Values of DisplayName, UPN & LogonName"
    # $ADHashCN = $AllRecipients | Get-ADHashCN

    # Write-Output "Retrieving distinguishedname's of all Exchange Mailboxes"
    # $allMailboxes = (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname)

    if (! $SkipSendAs) {
        Write-Output "Getting SendAs permissions for each mailbox and writing to file"
        $allMailboxDNs | Get-EXOSendAsPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash |
            Export-csv .\SendAsPerms.csv -NoTypeInformation
    }
    if (! $SkipSendOnBehalf) {
        Write-Output "Getting SendOnBehalf permissions for each mailbox and writing to file"
        $AllMailboxDNs | Get-EXOSendOnBehalfPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash -RecipientDNHash $RecipientDNHash |
            Export-csv .\SendOnBehalfPerms.csv -NoTypeInformation
    }
    if (! $SkipFullAccess) {
        Write-Output "Getting FullAccess permissions for each mailbox and writing to file"
        $AllMailboxDNs | Get-EXOFullAccessPerms -RecipientHash $RecipientHash -RecipientMailHash $RecipientMailHash |
            Export-csv .\FullAccessPerms.csv -NoTypeInformation
    }

    $AllPermissions = $null
    Get-ChildItem -Filter "*.csv" -Exclude "*allpermissions.csv" -Recurse | % {
        $AllPermissions += (import-csv $_)
    }
    $AllPermissions | Export-Csv .\AllPermissions.csv -NoTypeInformation
        Write-Output "Combined all CSV's into a single file named, AllPermissions.csv"

    # Write-Output "Opening Folder "
    # Invoke-Item .
    
}
# Get-EXOMailboxPerms -Tenant LAPCM -ReportPath C:\scripts\new4 -SkipSendOnBehalf