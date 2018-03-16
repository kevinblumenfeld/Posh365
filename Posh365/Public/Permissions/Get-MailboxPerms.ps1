Function Get-MailboxPerms {
    
    <#
    .SYNOPSIS
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports
    Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.
    The combined report will be called, AllPermissions.csv

    If same Report Path is chosen, existing files will be overwritten.

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
    
    .EXAMPLE
    Get-MailboxPerms -ReportPath C:\PermsReports -PowerShell2 -ExchangeServer "ExServer01"
    *ONLY PS2: When running from PowerShell 2 (Exchange 2010 Server)*

    *FIRST*: Be sure to dot-source the function with the below command (change the path):
    Get-ChildItem -Path "C:\scripts\Posh365\" -filter *.ps1 -Recurse | % { . $_.fullname }
    It is normal to see errors when running the above command                 
    
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
        [switch] $SkipFullAccess,

        [Parameter()]
        [switch] $PowerShell2,
        
        [Parameter()]
        [string] $ExchangeServer
    )

    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $User = $env:USERNAME

    Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
        ($_.name -eq "OnPremExchage" -or $_.name -like "Session for implicit remoting module at*") -and ($_.availability -ne "Available" -and $_.State -ne "Opened")} | 
        ForEach-Object {Remove-PSSession $_.id}
    
    if ($PowerShell2) {
        Write-Warning "**************************************************************************************************"
        Write-Warning "    You have selected -PowerShell2 which indicates that you are running this from PowerShell 2    "
        Write-Warning "If you haven't already, make sure to dot-source the functions with this command (change the Path):"
        Write-Warning "      Get-ChildItem -Path `"C:\scripts\Posh365\`" -filter *.ps1 -Recurse | % { . `$_.fullname }   "
        Write-Warning "                    It is normal to see errors when running the above command                     "
        Write-Warning "**************************************************************************************************"
        if (!$ExchangeServer) {
            Write-Warning "********************************************************************************************"
            Write-Warning "               Re-Run the command specifying the -ExchangeServer parameter                  "
            Write-Warning "ex. Get-MailboxPerms -ReportPath C:\PermsReports -PowerShell2 -ExchangeServer `"ExServer01`""
            Write-Warning "                               Script is terminating                                        "
            Write-Warning "********************************************************************************************"
            throw
        }
        if (Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
                ($_.name -eq "OnPremExchage" -or $_.name -like "Session for implicit remoting module at*") -and ($_.availability -ne "Available" -and $_.State -ne "Opened")}) {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix -NoMessageForPS2
        }
    }
    else {
        while (!(Test-Path ($RootPath + "$($user).EXCHServer"))) {
            Select-ExchangeServer
        }
        $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")
        if (Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
                ($_.name -eq "OnPremExchage" -or $_.name -like "Session for implicit remoting module at*") -and ($_.availability -ne "Available" -and $_.State -ne "Opened")}) {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix
        }
    }
    New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue

    $DomainNameHash = Get-DomainNameHash

    Write-Output "Importing Active Directory Users that have at least one proxy address"
    $AllADUsers = Get-ADUsersWithProxyAddress -DomainNameHash $DomainNameHash

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
            Export-csv (Join-Path $ReportPath "SendAsPerms.csv") -NoTypeInformation
    }
    
    if (! $SkipSendOnBehalf) {
        Write-Output "Getting SendOnBehalf permissions for each mailbox and writing to file"
        $allMailboxes | Get-SendOnBehalfPerms -ADHashCN $ADHashCN | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
            Export-csv (Join-Path $ReportPath "SendOnBehalfPerms.csv") -NoTypeInformation
    }
    
    if (! $SkipFullAccess) {
        Write-Output "Getting FullAccess permissions for each mailbox and writing to file"
        $allMailboxes | Get-FullAccessPerms -RecipientHash $RecipientHash |
            Export-csv (Join-Path $ReportPath "FullAccessPerms.csv") -NoTypeInformation
    }

    $AllPermissions = $null
    Get-ChildItem -Path $ReportPath -Filter "*.csv" -Exclude "*allpermissions.csv" -Recurse | % {
        $AllPermissions += (import-csv $_)
    }
    
    $AllPermissions | Export-Csv (Join-Path $ReportPath "AllPermissions.csv") -NoTypeInformation
    Write-Output "Combined all CSV's into a single file named, AllPermissions.csv"
}