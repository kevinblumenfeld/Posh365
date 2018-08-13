Function Get-DiscoveryInfo {
    ##
    <#
    .SYNOPSIS
    By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
    Switches can be added to isolate one or more reports
    Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.
    The combined report will be called, AllPermissions.csv

    If same Report Path is chosen, existing files will be overwritten.

    CSVs headers:
    "Object","UPN","Granted","GrantedUPN","Permission"

    .EXAMPLE
    Get-DiscoveryInfo -ReportPath C:\PermsReports -Verbose
    
    .EXAMPLE
    Get-DiscoveryInfo -ReportPath C:\PermsReports -SkipFullAccess -Verbose
    
    .EXAMPLE
    Get-DiscoveryInfo -ReportPath C:\PermsReports -SkipSendOnBehalf -Verbose

    .EXAMPLE
    Get-DiscoveryInfo -ReportPath C:\PermsReports -SkipSendAs -SkipFullAccess -Verbose
    
    .EXAMPLE
    Get-DiscoveryInfo -ReportPath C:\PermsReports -PowerShell2 -ExchangeServer "ExServer01" -Verbose
    ***ONLY PS2: When running from PowerShell 2 (Exchange 2010 Server)***

    ***FIRST***: Be sure to dot-source the function with the below command (change the path):
    Get-ChildItem -Path "C:\scripts\Posh365\" -filter *.ps1 -Recurse | % { . $_.fullname }
    It is normal to see errors when running the above command, as some of the functions (that aren't needed here) do not support PS2                 
    
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,

        [Parameter()]
        [switch] $EstablishRemoteSessionToExchange,
        
        [Parameter()]
        [switch] $PowerShell2,
        
        [Parameter()]
        [string] $ExchangeServer
    )

    Try {
        import-module activedirectory -ErrorAction Stop -Verbose:$false
    }
    Catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }
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
        if (-not $ExchangeServer) {
            Write-Warning "********************************************************************************************"
            Write-Warning "               Re-Run the command specifying the -ExchangeServer parameter                  "
            Write-Warning "ex. Get-DiscoveryInfo -ReportPath C:\PermsReports -PowerShell2 -ExchangeServer `"ExServer01`""
            Write-Warning "                               Script is terminating                                        "
            Write-Warning "********************************************************************************************"
            throw
        }
        if (Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
                ($_.name -eq "OnPremExchage" -or $_.name -like "Session for implicit remoting module at*") -and ($_.availability -ne "Available" -and $_.State -ne "Opened")}) {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix -NoMessageForPS2
        }
    }
    elseif ($EstablishRemoteSessionToExchange) {
        while (-not(Test-Path ($RootPath + "$($user).EXCHServer"))) {
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

    Write-Verbose "Importing Active Directory Users that have at least one proxy address"
    $allADUsers = Get-ADUsersWithProxyAddress -DomainNameHash $DomainNameHash

    Write-Verbose "Importing Active Directory Objects that have at least one proxy address"
    $allADObjects = Get-ADObjectsWithProxyAddress -DomainNameHash $DomainNameHash

    Write-Verbose "Caching hash table. LogonName as Key and Values of DisplayName & UPN"
    $ADHash = $allADUsers | Get-ADHash

    Write-Verbose "Caching hash table. LogonName as Key and Values of DisplayName & UPN"
    $ADHashDG = $AllADObjects | Get-ADHashDG

    Write-Verbose "Caching hash table. DN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashDN = $allADUsers | Get-ADHashDN

    Write-Verbose "Caching hash table. CN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashCN = $allADObjects | Get-ADHashCN

    Write-Verbose "Retrieve all Exchange Mailboxes"
    $allMailbox = Get-ExchangeMailbox -DetailedReport

    Write-Verbose "Retrieve all Exchange Distribution Groups"
    $allGroups = Get-ExchangeDistributionGroup -DetailedReport

    Write-Verbose "Export all Exchange Mailboxes to CSV"
    $allMailbox | Export-csv (Join-Path $ReportPath "ExchangeMailboxes.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Retrieving distinguishedname's of all Exchange Mailboxes"
    $allMailboxDN = $allMailbox | Select -expandproperty distinguishedname

    Write-Verbose "Export all Exchange Distribution Groups to CSV"
    $allGroups | Export-csv (Join-Path $ReportPath "ExchangeDistributionGroups.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Retrieving distinguishedname's of all Exchange Distribution Groups"
    $allGroupsDN = $allGroups | Select -expandproperty distinguishedname

    ##############
    $FwdSelect = @('DisplayName', 'UserPrincipalName', 'ForwardingAddress')
    $FwdSelectCalc = @(
        @{n = 'FwdDisplayName'; e = {$ADHashCN["$($_.ForwardingAddress)"].DisplayName}},
        @{n = 'FwdPrimarySmtpAddress'; e = {$ADHashCN["$($_.ForwardingAddress)"].PrimarySmtpAddress}},
        @{n = 'msExchRecipientTypeDetails'; e = {$ADHashCN["$($_.ForwardingAddress)"].msExchRecipientTypeDetails}},
        @{n = 'msExchRecipientDisplayType'; e = {$ADHashCN["$($_.ForwardingAddress)"].msExchRecipientDisplayType}}
    )

    $allMailbox | Where-Object {$_.ForwardingAddress} | Select @($FwdSelect + $FwdSelectCalc) |
        Export-csv (Join-Path $ReportPath "FowardingAddress.csv") -NoTypeInformation -Encoding UTF8

    $HiddenSelect = @('DisplayName', 'UserPrincipalName', 'alias', 'HiddenFromAddressListsEnabled')

    $allMailbox | Where-Object {$_.HiddenFromAddressListsEnabled -eq $TRUE} | Select $HiddenSelect |
        Export-csv (Join-Path $ReportPath "HiddenFromGAL.csv") -NoTypeInformation -Encoding UTF8

    ##### PERMS #####
    if (-not $SkipSendAs) {
        Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
        $allMailboxDN | Get-SendAsPerms -ADHashDN $ADHashDN -ADHash $ADHash  | Select Object, UPN, Granted, GrantedUPN, Permission |
            Export-csv (Join-Path $ReportPath "SendAsPerms.csv") -NoTypeInformation -Encoding UTF8
    }
    
    if (-not $SkipSendOnBehalf) {
        Write-Verbose "Getting SendOnBehalf permissions for each mailbox and writing to file"
        $allMailboxDN | Get-SendOnBehalfPerms -ADHashCN $ADHashCN | Select Object, UPN, Granted, GrantedUPN, Permission |
            Export-csv (Join-Path $ReportPath "SendOnBehalfPerms.csv") -NoTypeInformation -Encoding UTF8
    }
    
    if (-not $SkipFullAccess) {
        Write-Verbose "Getting FullAccess permissions for each mailbox and writing to file"
        $allMailboxDN | Get-FullAccessPerms -ADHashDN $ADHashDN -ADHash $ADHash | Select Object, UPN, Granted, GrantedUPN, Permission |
            Export-csv (Join-Path $ReportPath "FullAccessPerms.csv") -NoTypeInformation -Encoding UTF8
    }



    $AllPermissions = $null
    $Report = $ReportPath.ToString()
    $Report = $Report.TrimEnd('\') + "\*"
    $AllPermissions = Get-ChildItem -Path $Report -Include "SendAsPerms.csv", "SendOnBehalfPerms.csv", "FullAccessPerms.csv" -Exclude "AllPermissions.csv" | % {
        Import-Csv $_
    }
    
    $AllPermissions | Export-Csv (Join-Path $ReportPath "AllPermissions.csv") -NoTypeInformation -Encoding UTF8
    Write-Verbose "Combined all CSV's into a single file named, AllPermissions.csv"

    $allGroupsDN | Get-DGSendAsPerms -ADHashDGDN $ADHashDGDN -ADHashDG $ADHashDG  | Select Object, PrimarySMTP, Granted, GrantedUPN, GrantedSMTP, Permission |
        Export-csv (Join-Path $ReportPath "DGSendAsPerms.csv") -NoTypeInformation
    ##### PERMS #####

}