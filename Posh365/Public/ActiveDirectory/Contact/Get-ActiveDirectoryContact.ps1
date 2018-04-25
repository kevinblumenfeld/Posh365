function Get-ActiveDirectoryContact { 
    <#
    .SYNOPSIS
    Export Active Directory Contacts
    
    .DESCRIPTION
    Export Active Directory Contacts
    
    .PARAMETER SpecificOU
    Provide specific OU(s) from where to pull.  Otherwise, all AD Contacts will be reported.  Please review the examples provided.
    
    .PARAMETER IncludeSubOUs
    Switch to include sub OU(s) if SpecificOU is specified.  Otherwise, just the single OU will be included.

    .EXAMPLE
    Get-ActiveDirectoryContact | Export-Csv c:\scripts\ADContacts.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    "OU=CONTACTS,OU=CORP,DC=corp,DC=ad,DC=contoso,DC=com" | Get-ActiveDirectoryContact -IncludeSubOUs| Export-Csv c:\scripts\ADContacts.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    "OU=CONTACTS,OU=CORP,DC=corp,DC=ad,DC=contoso,DC=com" | Get-ActiveDirectoryContact | Export-Csv c:\scripts\OneOUofContacts.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    "OU=CONTACTS,OU=CORP,DC=corp,DC=ad,DC=contoso,DC=com", "OU=AnotherOUofContacts,OU=CORP,DC=corp,DC=ad,DC=contoso,DC=com" | Get-ActiveDirectoryContact | Export-Csv c:\scripts\TwoOUsofContacts.csv -notypeinformation -encoding UTF8
    
    #>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $SpecificOU,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [switch] $IncludeSubOUs
        
    )
    Begin {
        $Props = @(
            'CanonicalName', 'Description', 'DisplayName', 'DistinguishedName'
            'givenName', 'legacyExchangeDN', 'mail', 'Name', 'initials', 'sn', 'targetAddress'
            'Title', 'Department', 'Division', 'Company', 'EmployeeID', 'EmployeeNumber'
            'StreetAddress', 'PostalCode', 'telephoneNumber', 'HomePhone', 'mobile', 'pager', 'ipphone'
            'facsimileTelephoneNumber', 'l', 'st', 'cn', 'physicalDeliveryOfficeName', 'co'
            'mailnickname', 'proxyAddresses', 'msExchRecipientDisplayType'
            'msExchRecipientTypeDetails', 'msExchRemoteRecipientType', 'info'
        )
    
        $Selectproperties = @(
            'DisplayName', 'name', 'initials', 'sn', 'Title', 'Department', 'Division'
            'Company', 'EmployeeID', 'EmployeeNumber', 'Description', 'GivenName', 'StreetAddress'
            'PostalCode', 'telephoneNumber', 'HomePhone', 'mobile', 'pager', 'ipphone', 'l', 'st', 'cn'
            'physicalDeliveryOfficeName', 'mailnickname', 'Distinguishedname'
            'legacyExchangeDN', 'mail', 'msExchRecipientDisplayType', 'msExchRecipientTypeDetails'
            'msExchRemoteRecipientType', 'targetaddress', 'info', 'CanonicalName'
        )
    
        $CalculatedProps = @(
            @{n = "OU" ; e = {$_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'}},
            @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join ";" }}
        )
    }
    Process {
        if ($SpecificOU) {
            foreach ($CurSpecificOU in $SpecificOU) {
                if ($IncludeSubOUs) {
                    Get-ADObject -LDAPFilter "objectClass=Contact" -Properties $Props -SearchBase $CurSpecificOU -SearchScope SubTree -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
                }
                else {
                    Get-ADObject -LDAPFilter "objectClass=Contact" -Properties $Props -SearchBase $CurSpecificOU -SearchScope OneLevel -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
                }
            }
        }     
        else {
            Get-ADObject -LDAPFilter "objectClass=Contact" -Properties $Props -ResultSetSize $null | Select-Object ($Selectproperties + $CalculatedProps)
        }     
    }
    End {
        
    }
}