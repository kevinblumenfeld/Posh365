Function Rename-User {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(Position = 0, Mandatory = $true)]
        [string] $UsersSamAccount,
        
        [parameter(Position = 1, Mandatory = $true)]
        [string] $FutureFirstName,

        [parameter(Position = 2, Mandatory = $true)]
        [string] $FutureLastName
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
        $DomainController = Get-Content ($RootPath + "$($user).DomainController")   
        
        While (!(Get-Content ($RootPath + "$($user).DisplayNameFormat") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-DisplayNameFormat
        }
        $DisplayNameFormat = Get-Content ($RootPath + "$($user).DisplayNameFormat")     

        #######################################
        #   Connect to On Premises Exchange   #
        #######################################
        try {
            (Get-OnPremExchangeServer -erroraction stop)[0] | Out-Null
        }
        catch {
            Connect-ToExchange -ExchangeServer $ExchangeServer
        }

        ########################################
        #         Connect to Office 365        #
        ########################################
        if (! $NoMail) {
            try {
                Get-AzureADDomain -erroraction stop | Out-Null
            }
            catch {
                Try {
                    Connect-ToCloud $targetAddressSuffix -MSOnline -AzureADver2 -erroraction stop

                } 
                Catch {
                    Write-Output "Failed to Connect to Cloud.  Please try again."
                    Break
                }
            }
    
        }

        #Requires -Modules ActiveDirectory

        Set-OnPremRemoteMailbox -Identity $UsersSamAccount -EmailAddressPolicyEnabled:$false

        # DisplayName
        $FirstName = $FutureFirstName
        $LastName = $FutureLastName
        $DisplayName = $ExecutionContext.InvokeCommand.ExpandString($DisplayNameFormat)

        #########################################
        #  Create Parameters ADUser Name Change #
        #########################################

        $hash = @{
            "DisplayName" = $DisplayName
            "GivenName"   = $FirstName
            "SurName"     = $LastName
        }
        $params = @{}
        ForEach ($key in $hash.keys) {
            if ($($hash.item($key))) {
                $params.add($key, $($hash.item($key)))
            }
        }
        
        #########################################
        #          Create New ADUser            #
        #########################################

        Set-ADUser -Identity $UsersSamAccount @params -Server $domainController
        
        # Purge old jobs
        Get-Job | where {$_.State -ne 'Running'}| Remove-Job

        Set-OnPremRemoteMailbox -Identity $UsersSamAccount -EmailAddressPolicyEnabled:$true
            
        # After Email Address Policy, Set UPN to same as PrimarySMTP
        $CurrentUser = Get-OnPremRemoteMailbox $UsersSamAccount | select DistinguishedName,primarysmtpaddress
        Set-ADUser -Identity $UsersSamAccount -Server $domainController -userprincipalname $CurrentUser.primarysmtpaddress
        Rename-ADObject $CurrentUser.DistinguishedName -NewName $DisplayName

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

        Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$UsersSamAccount)" -Properties $Properties -searchBase (Get-ADDomain -Server $domainController).distinguishedname -SearchScope SubTree |
            select ($Selectproperties + $CalculatedProps) | FL
    }

    Process {

    }

    End {
    
    }
}    
