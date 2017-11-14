Function Rename-SamAccount {
    <#
    .SYNOPSIS


    .EXAMPLE
    
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]    
        $CurrentSamAccountName,
        [Parameter(Mandatory = $True)]
        $FutureSamAccountName
    )
    
    Begin {

        $RootPath = $env:USERPROFILE + "\ps\"
        $User = $env:USERNAME
        if (!(Test-Path $RootPath)) {
            try {
                New-Item -ItemType Directory -Path $RootPath -ErrorAction STOP | Out-Null
            }
            catch {
                throw $_.Exception.Message
            }           
        }        
        While (!(Get-Content ($RootPath + "$($user).ADConnectServer") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-ADConnectServer
        }
        
        While (!(Get-Content ($RootPath + "$($user).EXCHServer") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-ExchangeServer
        }
        $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")

        While (!(Get-Content ($RootPath + "$($user).TargetAddressSuffix") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-TargetAddressSuffix
        }
        $targetAddressSuffix = Get-Content ($RootPath + "$($user).TargetAddressSuffix")
          
        While (!(Get-Content ($RootPath + "$($user).DomainController") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-DomainController
        }
        $domainController = Get-Content ($RootPath + "$($user).DomainController")     

        Import-Module ActiveDirectory

        ##############################################
        #              SamAccountName                #
        ##############################################
        $SamAccountName = $FutureSamAccountName
        $i = 2
        while (get-aduser -Server $domainController -LDAPfilter "(samaccountname=$SamAccountName)") {
            $SamAccountName = ($FutureSamAccountName + $i)
            $i++
        }
        
        $samaccountname = $samaccountname.tolower()

        (Get-ADUser -Identity $CurrentSamAccountName -Server $domainController -Properties proxyAddresses).proxyAddresses | % {
            if (($_ -cmatch "SMTP:*") -and ($($_).substring(5).split("@"))[0] -eq $CurrentSamAccountName) {
                Set-ADUser -Identity $CurrentSamAccountName -remove @{proxyaddresses = "$($_)"} -Server $domainController
                Set-ADUser -Identity $CurrentSamAccountName -add @{proxyaddresses = ("smtp:" + $($_).substring(5))} -Server $domainController
                Set-ADUser -Identity $CurrentSamAccountName -add @{proxyaddresses = ("SMTP:" + $SamAccountName + "@" + ($($_).substring(5).split("@"))[1])} -Server $domainController
                Set-ADUser -Identity $CurrentSamAccountName -Server $domainController -replace @{mail = ($SamAccountName + "@" + ($($_).substring(5).split("@"))[1]); UserPrincipalName = $SamAccountName + "@" + ($($_).substring(5).split("@"))[1]}
            } 
            if (($_ -cmatch "smtp:*") -and ($($_).substring(5).split("@"))[0] -eq $CurrentSamAccountName) {
                Set-ADUser -Identity $CurrentSamAccountName -add @{proxyaddresses = ("smtp:" + $SamAccountName + "@" + ($($_).substring(5).split("@"))[1])} -Server $domainController
            }
            if (($($_).substring(5).split("@"))[1] -eq $targetAddressSuffix) {
                Set-ADUser -Identity $CurrentSamAccountName -remove @{proxyaddresses = "$($_)"} -Server $domainController
            }
        }
        Set-ADUser -Identity $CurrentSamAccountName -replace @{mailnickname = $samaccountname; targetaddress = ($samaccountname + "@" + $targetAddressSuffix)} -Server $domainController
        Set-ADUser -Identity $CurrentSamAccountName -SamAccountName $SamAccountName -Server $domainController
        ########################################
        #         Sync Azure AD Connect        #
        ########################################
        Sync-ADConnect

        ########################################
        #   Verbose Output of ADUser Created   #
        ########################################
        $properties = @(
            'DisplayName', 'Title', 'Office', 'Department', 'Division'
            'Company', 'Organization', 'EmployeeID', 'EmployeeNumber', 'Description', 'GivenName'
            'Surname', 'StreetAddress', 'City', 'State', 'PostalCode', 'Country', 'countryCode'
            'POBox', 'MobilePhone', 'OfficePhone', 'HomePhone', 'Fax', 'cn'
            'mailnickname', 'samaccountname', 'UserPrincipalName', 'proxyAddresses'
            'Distinguishedname', 'legacyExchangeDN', 'EmailAddress', 'msExchRecipientDisplayType'
            'msExchRecipientTypeDetails', 'msExchRemoteRecipientType', 'targetaddress'
        )

        $Selectproperties = @(
            'DisplayName', 'Title', 'Office', 'Department', 'Division'
            'Company', 'Organization', 'EmployeeID', 'EmployeeNumber', 'Description', 'GivenName'
            'Surname', 'StreetAddress', 'City', 'State', 'PostalCode', 'Country', 'countryCode'
            'POBox', 'MobilePhone', 'OfficePhone', 'HomePhone', 'Fax', 'cn'
            'mailnickname', 'samaccountname', 'UserPrincipalName', 'Distinguishedname'
            'legacyExchangeDN', 'EmailAddress', 'msExchRecipientDisplayType'
            'msExchRecipientTypeDetails', 'msExchRemoteRecipientType', 'targetaddress'
        )

        $CalculatedProps = @(
            @{n = "OU" ; e = {$_.Distinguishedname | ForEach-Object {($_ -split '(OU=)', 2)[1, 2] -join ''}}},
            @{n = "PrimarySMTPAddress" ; e = {( $_.proxyAddresses | ? {$_ -cmatch "SMTP:*"}).Substring(5) -join ";" }},
            @{n = "smtp" ; e = {( $_.proxyAddresses | ? {$_ -cmatch "smtp:*"}).Substring(5) -join ";" }},
            @{n = "x500" ; e = {( $_.proxyAddresses | ? {$_ -match "x500:*"}).Substring(0) -join ";" }},
            @{n = "SIP" ; e = {( $_.proxyAddresses | ? {$_ -match "SIP:*"}).Substring(4) -join ";" }}
        )   

        Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)" -Properties $Properties -searchBase (Get-ADDomain -Server $domainController).distinguishedname -SearchScope SubTree |
            select ($Selectproperties + $CalculatedProps) | FL
    }
    Process {

    }

    End {
    
    }
}     
