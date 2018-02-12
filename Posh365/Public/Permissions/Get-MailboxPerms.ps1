Function Get-MailboxPerms {
    
    <#
    .SYNOPSIS
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports

    CSVs headers:
    "Mailbox","UPN","Granted","GrantedUPN","Permission"

    .EXAMPLE
    Get-MailboxPerms -ReportPath C:\PermsReports
    
    .EXAMPLE
    Get-MailboxPerms -ReportPath C:\PermsReports -SkipFullAccess
    
    .EXAMPLE
    Get-MailboxPerms -ReportPath C:\PermsReports -SkipSendOnBehalf

    .EXAMPLE
    Get-MailboxPerms -ReportPath C:\PermsReports -SkipSendAs -SkipFullAccess
    
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,
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
    
    while (!(Test-Path ($RootPath + "$($user).EXCHServer"))) {
        Select-ExchangeServer
    }
    $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")
    
    if ($exscripts) {
        write-output 'Exchange Management Shell loaded'
    }
    else {
        try {
            $null = Get-Command "Get-ExchangeServer" -ErrorAction Stop
        }
        catch {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix
        }
    }
    
    New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
    Set-Location $ReportPath

    Write-Output "Importing Active Directory Users that have at least one proxy address"
    $AllADUsers = Get-ADUsersWithProxyAddress
    Write-Output "Caching hash table. LogonName as Key and Values of DisplayName & UPN"
    $ADHash = $AllADUsers | Get-ADHash
    Write-Output "Caching hash table. DN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashDN = $AllADUsers | Get-ADHashDN
    Write-Output "Caching hash table. CN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashCN = $AllADUsers | Get-ADHashCN

    Write-Output "Retrieving distinguishedname's of all Exchange Mailboxes"
    $allMailboxes = (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname)

    if (! $SkipSendAs) {
        Write-Output "Getting SendAs permissions for each mailbox and writing to file"
        $allMailboxes | Get-SendAsPerms -ADHashDN $ADHashDN -ADHash $ADHash  | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
            Export-csv .\SendAsPerms.csv -NoTypeInformation
    }
    
    if (! $SkipSendOnBehalf) {
        Write-Output "Getting SendOnBehalf permissions for each mailbox and writing to file"
        $allMailboxes | Get-SendOnBehalfPerms -ADHashCN $ADHashCN | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
            Export-csv .\SendOnBehalfPerms.csv -NoTypeInformation
    }
    
    if (! $SkipFullAccess) {
        Write-Output "Getting FullAccess permissions for each mailbox and writing to file"
        $allMailboxes | Get-FullAccessPerms -ADHashDN $ADHashDN -ADHash $ADHash  | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
            Export-csv .\FullAccessPerms.csv -NoTypeInformation
    }
    $AllPermissions = $null
    Get-ChildItem -File -Filter "*.csv" | % {
        $AllPermissions += (import-csv $_)
    }
    $AllPermissions | Export-Csv .\AllPermissions.csv -NoTypeInformation
    Write-Output "Combined all CSV's into a single file named, AllPermissions.csv"
    Write-Output "Opening Folder "
    Invoke-Item .
}