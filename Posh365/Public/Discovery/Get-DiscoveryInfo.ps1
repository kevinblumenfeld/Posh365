Function Get-DiscoveryInfo {
    ##
    <#
    .SYNOPSIS
    On-Premises Active Directory and Exchange Discovery script
    
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
        [string] $ExchangeServer,

        [Parameter()]
        [switch] $SkipSendAs,

        [Parameter()]
        [switch] $SkipSendOnBehalf,

        [Parameter()]
        [switch] $SkipFullAccess
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
    New-Item -ItemType Directory -Path (Join-Path $ReportPath "RawData") -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path (Join-Path $ReportPath "ActiveDirectory") -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path (Join-Path $ReportPath "Exchange") -ErrorAction SilentlyContinue
    $RawDataPath = Join-Path $ReportPath "RawData"
    $ADPath = Join-Path $ReportPath "ActiveDirectory"
    $ExchangePath = Join-Path $ReportPath "Exchange"

    $DomainNameHash = Get-DomainNameHash

    Write-Verbose "Retrieving Active Directory Objects that have at least one proxy address"
    $allADObjects = Get-ADObjectsWithProxyAddress -DomainNameHash $DomainNameHash

    Write-Verbose "Caching hash table. LogonName as Key and Values of DisplayName & UPN"
    $ADHash = $allADObjects | Get-ADHash

    Write-Verbose "Caching hash table for Groups. LogonName as Key and Values of DisplayName & UPN"
    $ADHashDG = $allADObjects | Get-ADHashDG

    Write-Verbose "Caching hash table. DN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashDN = $allADObjects | Get-ADHashDN

    Write-Verbose "Caching hash table for Groups. DN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashDGDN = $AllADObjects | Get-ADHashDGDN

    Write-Verbose "Caching hash table. CN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashCN = $allADObjects | Get-ADHashCN
    
    Write-Verbose "Retrieving all Active Directory Users"
    $allADUsers = Get-ActiveDirectoryUser -DetailedReport

    Write-Verbose "Exporting all Active Directory Users to RawADUsers.csv"
    $allADUsers | Export-csv (Join-Path -Path $RawDataPath -ChildPath "RawADUsers.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Retrieving all Exchange Mailboxes"
    $allMailbox = Get-ExchangeMailbox -DetailedReport

    Write-Verbose "Exporting all Exchange Mailboxes to RawExchangeMailboxes.csv"
    $allMailbox | Export-csv (Join-Path -Path $RawDataPath -ChildPath "RawExchangeMailboxes.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Retrieving distinguishedname's of all Exchange Mailboxes"
    $allMailboxDN = $allMailbox | Select -expandproperty distinguishedname

    Write-Verbose "Retrieving all Exchange Distribution Groups"
    $allGroups = Get-ExchangeDistributionGroup -DetailedReport

    Write-Verbose "Exporting all Exchange Distribution Groups to file ExchangeDistributionGroups.csv"
    $allGroups | Export-csv (Join-Path -Path $RawDataPath -ChildPath "RawExchangeDistributionGroups.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all Exchange Distribution Groups Members to file DistributionGroupMembers.csv"
    $allGroups | Export-CsvData -JoinType and -Match "." -FindInColumn "MembersName" -ReportPath "$ReportPath" -subDirectory "Exchange" -fileName "DistributionGroupMembers.csv"

    Write-Verbose "Retrieving distinguishedname's of all Exchange Distribution Groups"
    $allGroupsDN = $allGroups | Select -expandproperty distinguishedname

    $MailboxProperties = @(
        'DisplayName', 'OU', 'RecipientTypeDetails', 'UserPrincipalName', 'PrimarySmtpAddress', 'Identity', 'Alias'
        'ForwardingAddress', 'ForwardingSmtpAddress', 'LitigationHoldDate', 'AccountDisabled', 'DeliverToMailboxAndForward'
        'HiddenFromAddressListsEnabled', 'LitigationHoldEnabled', 'LitigationHoldDuration'
        'LitigationHoldOwner', 'Office', 'RetentionPolicy', 'WindowsEmailAddress', 'ArchiveName', 'AcceptMessagesOnlyFrom'
        'AcceptMessagesOnlyFromDLMembers', 'AcceptMessagesOnlyFromSendersOrMembers', 'RejectMessagesFrom', 'RejectMessagesFromDLMembers'
        'RejectMessagesFromSendersOrMembers', 'InPlaceHolds', 'x500', 'EmailAddresses'
    )
    
    $GroupProperties = @(
        'DisplayName', 'OU', 'RecipientTypeDetails', 'Alias', 'ManagedBy', 'GroupType', 'Identity', 'PrimarySmtpAddress', 'WindowsEmailAddress'
        'AcceptMessagesOnlyFromSendersOrMembers', 'x500', 'EmailAddresses'
    )

    Write-Verbose "Exporting all ADUser with Inheritance Broken to InheritanceBroken.csv"
    $allADUsers | where {$_.InheritanceBroken -eq "True"} | Select DisplayName, InheritanceBroken, OU, PrimarySmtpAddress, UserPrincipalName |
        Export-csv (Join-Path -Path $ADPath -ChildPath "InheritanceBroken.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all Exchange Mailboxes to ExchangeMailboxes.csv"
    $allMailbox | Select $MailboxProperties | 
        Export-csv (Join-Path -Path $ExchangePath -ChildPath "ExchangeMailboxes.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all smtp addresses for Exchange Mailboxes"
    $allMailbox | Export-CsvData -JoinType and -Match "smtp:" -FindInColumn "MembersName" -ReportPath "$ReportPath" -subDirectory "Exchange" -fileName "MailboxSmtpAddresses.csv"
    
    Write-Verbose "Exporting all sip addresses for Exchange Mailboxes"
    $allMailbox | Export-CsvData -JoinType and -Match "sip:" -FindInColumn "MembersName" -ReportPath "$ReportPath" -subDirectory "Exchange" -fileName "MailboxSipAddresses.csv"
    
    Write-Verbose "Exporting all Exchange Distribution Groups to ExchangeDistributionGroups.csv"
    $allGroups | Select $GroupProperties | 
        Export-csv (Join-Path -Path $ExchangePath -ChildPath "ExchangeDistributionGroups.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all smtp addresses for Exchange Distribution Groups"
    $allGroups | Export-CsvData -JoinType and -Match "smtp:" -FindInColumn "MembersName" -ReportPath "$ReportPath" -subDirectory "Exchange" -fileName "MailboxSmtpAddresses.csv"
        
    $FwdSelect = @('DisplayName', 'UserPrincipalName', 'ForwardingAddress')
    $FwdSelectCalc = @(
        @{n = 'FwdDisplayName'; e = {$ADHashCN["$($_.ForwardingAddress)"].DisplayName}},
        @{n = 'FwdPrimarySmtpAddress'; e = {$ADHashCN["$($_.ForwardingAddress)"].PrimarySmtpAddress}},
        @{n = 'FwdmsExchRecipientTypeDetails'; e = {$ADHashCN["$($_.ForwardingAddress)"].msExchRecipientTypeDetails}},
        @{n = 'FwdmsExchRecipientDisplayType'; e = {$ADHashCN["$($_.ForwardingAddress)"].msExchRecipientDisplayType}}
    )

    Write-Verbose "Exporting Mailboxes with Forwarding Addresses to file FowardingAddress.csv"
    $allMailbox | Where-Object {$_.ForwardingAddress} | Select @($FwdSelect + $FwdSelectCalc) |
        Export-csv (Join-Path $ExchangePath -ChildPath "FowardingAddress.csv") -NoTypeInformation -Encoding UTF8

    $HiddenSelect = @('DisplayName', 'UserPrincipalName', 'alias', 'HiddenFromAddressListsEnabled')

    Write-Verbose "Exporting Mailboxes that are Hidden from the GAL to file HiddenFromGAL.csv"
    $allMailbox | Where-Object {$_.HiddenFromAddressListsEnabled -eq $TRUE} | Select $HiddenSelect |
        Export-csv (Join-Path $ExchangePath -ChildPath "HiddenFromGAL.csv") -NoTypeInformation -Encoding UTF8

    if (-not $SkipSendAs) {
        Write-Verbose "Getting SendAs permissions for each mailbox and writing to file SendAsPerms.csv"
        $allMailboxDN | Get-SendAsPerms -ADHashDN $ADHashDN -ADHash $ADHash  | Select Object, UPN, Granted, GrantedUPN, Permission |
            Export-csv (Join-Path $ExchangePath -ChildPath "SendAsPerms.csv") -NoTypeInformation -Encoding UTF8
    }
    
    if (-not $SkipSendOnBehalf) {
        Write-Verbose "Getting SendOnBehalf permissions for each mailbox and writing to file SendOnBehalfPerms.csv"
        $allMailboxDN | Get-SendOnBehalfPerms -ADHashCN $ADHashCN | Select Object, UPN, Granted, GrantedUPN, Permission |
            Export-csv (Join-Path $ExchangePath -ChildPath "SendOnBehalfPerms.csv") -NoTypeInformation -Encoding UTF8
    }
    
    if (-not $SkipFullAccess) {
        Write-Verbose "Getting FullAccess permissions for each mailbox and writing to file FullAccessPerms.csv"
        $allMailboxDN | Get-FullAccessPerms -ADHashDN $ADHashDN -ADHash $ADHash | Select Object, UPN, Granted, GrantedUPN, Permission |
            Export-csv (Join-Path $ExchangePath -ChildPath "FullAccessPerms.csv") -NoTypeInformation -Encoding UTF8
    }

    $AllPermissions = $null
    $Report = $ReportPath.ToString()
    $Report = $Report.TrimEnd('\') + "\*"
    $AllPermissions = Get-ChildItem -Path $Report -Include "SendAsPerms.csv", "SendOnBehalfPerms.csv", "FullAccessPerms.csv" -Exclude "AllPermissions.csv" | % {
        Import-Csv $_
    }
    
    $AllPermissions | Export-Csv (Join-Path $ExchangePath -ChildPath "AllPermissions.csv") -NoTypeInformation -Encoding UTF8
    Write-Verbose "Combined all Mailbox Delegate Permission CSV's into a single file named, AllPermissions.csv"

    Write-Verbose "Exporting Distribution Group Send-as Delegate Permission to file DGSendAsPerms.csv"
    $allGroupsDN | Get-DGSendAsPerms -ADHashDGDN $ADHashDGDN -ADHashDG $ADHashDG  | Select Object, PrimarySMTP, Granted, GrantedUPN, GrantedSMTP, Permission |
        Export-csv (Join-Path $ExchangePath -ChildPath "DGSendAsPerms.csv") -NoTypeInformation

}