Function Get-DiscoveryInfo {
    <#
    .SYNOPSIS
    On-Premises Active Directory discovery

    .EXAMPLE

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

    )

    try {
        Import-Module activedirectory -ErrorAction Stop -Verbose:$false
    }
    catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }

    do {
        $Answer = Read-Host "Connect to Exchange Server? (Y/N)"
        if ($Answer -eq "Y") {
            $ServerName = Read-Host "Type the name of the Exchange Server and hit enter"
            Connect-Exchange -Server $ServerName
        }
    } until ($Answer -eq 'Y' -or $Answer -eq 'N')


    $Discovery = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Discovery'
    $Detailed = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Detailed'
    $CSV = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'CSV'
    New-Item -ItemType Directory -Path $Discovery -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $Detailed -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $CSV -ErrorAction SilentlyContinue

    $Csv = @{
        NoTypeInformation = $true
        Encoding          = 'UTF8'
    }

    $DomainNameHash = Get-DomainNameHash

    Write-Verbose "Retrieving Active Directory Objects that have at least one proxy address"
    $allADObjects = Get-ADObjectsWithProxyAddress -DomainNameHash $DomainNameHash
    <#
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

    Write-Verbose "Retrieving distinguishedname's of all Exchange Mailboxes"
    $allMailboxDN = $allMailbox | Select-Object -ExpandProperty distinguishedname
    #>


    Write-Verbose "Retrieving all Active Directory Users"
    $allADUsers = Get-ActiveDirectoryUser -DetailedReport

    Write-Verbose "Exporting all Active Directory Users to file"
    $allADUsers | Export-Clixml -Path (Join-Path -Path $Detailed -ChildPath 'ADUsers.xml')
    $allADUsers | Export-Csv @CSV -Path (Join-Path -Path $Detailed -ChildPath 'ADUsers.csv')

    Write-Verbose "Retrieving all Exchange Receive Connectors"
    Get-ExchangeReceiveConnector | Export-Csv @CSV -Path (Join-Path -Path $Detailed -ChildPath 'ReceiveConn.csv')

    Write-Verbose "Retrieving all Exchange Send Connectors"
    Get-ExchangeSendConnector | Export-Csv @CSV -Path (Join-Path -Path $Detailed -ChildPath 'SendConn.csv')

    Write-Verbose "Retrieving all Exchange Distribution Groups"
    $allGroups = Get-ExchangeDistributionGroup -DetailedReport

    Write-Verbose "Exporting all Exchange Distribution Groups to file ExchangeDistributionGroups.csv"
    $allGroups | Export-Csv (Join-Path -Path $Detailed -ChildPath "RawExchangeDistributionGroups.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all Exchange Distribution Groups Members to file DistributionGroupMembers.csv"
    $allGroups | Export-CsvData -JoinType and -Match "." -FindInColumn "MembersName" -ReportPath $ExchangePath -fileName "DistributionGroupMembers.csv"

    Write-Verbose "Retrieving distinguishedname's of all Exchange Distribution Groups"
    $allGroupsDN = $allGroups | Select-Object -expandproperty distinguishedname

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
    $allADUsers | Where-Object { $_.InheritanceBroken -eq "True" } | Select-Object DisplayName, InheritanceBroken, OU, PrimarySmtpAddress, UserPrincipalName |
    Export-Csv (Join-Path -Path $ADPath -ChildPath "InheritanceBroken.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all Exchange Mailboxes to ExchangeMailboxes.csv"
    $allMailbox | Select-Object $MailboxProperties |
    Export-Csv (Join-Path -Path $ExchangePath -ChildPath "ExchangeMailboxes.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all smtp addresses for Exchange Mailboxes"
    $allMailbox | Export-CsvData -JoinType and -Match "smtp:" -FindInColumn "EmailAddresses" -ReportPath "$ExchangePath" -fileName "MailboxSmtpAddresses.csv"

    Write-Verbose "Exporting all sip addresses for Exchange Mailboxes"
    $allMailbox | Export-CsvData -JoinType and -Match "sip:" -FindInColumn "EmailAddresses" -ReportPath "$ExchangePath" -fileName "MailboxSipAddresses.csv"

    Write-Verbose "Exporting all Exchange Distribution Groups to ExchangeDistributionGroups.csv"
    $allGroups | Select-Object $GroupProperties |
    Export-Csv (Join-Path -Path $ExchangePath -ChildPath "ExchangeDistributionGroups.csv") -NoTypeInformation -Encoding UTF8

    Write-Verbose "Exporting all smtp addresses for Exchange Distribution Groups"
    $allGroups | Export-CsvData -JoinType and -Match "smtp:" -FindInColumn "EmailAddresses" -ReportPath "$ExchangePath" -fileName "DistributionGroupSmtpAddresses.csv"


}
