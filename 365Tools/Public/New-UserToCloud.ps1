Function New-UserToCloud {
    <#
    .SYNOPSIS
    
    1. Copies the properties of an existing AD User to a new AD User
    2. Enables the ADUser as a Remote Mailbox in Exchange/Office 365 (can select -noMail switch to assign no mailbox)
    3. Syncs changes to Office 365 with Azure AD Connect (AADC)
    4. Grid of licenses are presented to user of script to select from and then applied to 365 User

    ##########
    # Must be run on PowerShell 5+ (run as administrator) with the following tools installed:
    # Windows 10/2016 comes pre-installed with PowerShell 5.1
    #
    #  1) RSAT(Active Directory tools including AD Module for PowerShell
    #  2) Exchange Management Tools - Ensure the version matches exactly the version of Exchange installed onprem. 
    #  3) Run Select-Servers once, to choose an AD Connect Server, Domain Controller, Exchange Server & Target Address Suffix
    #       this allows the scripts to lock in specifics server names.  This should only be changed should the servers chosen are changed
    #       It is best to choose the domain controller with which AD Connect is connected.
    #       Need be, domain controllers can be hard coded to use a list of DCs (in order), so that the first in the list is typically the only DC used:
    #       This is the process:
    #          https://vanhybrid.com/2016/01/25/force-azure-ad-connect-to-connect-to-specific-domain-controllers-only/
    #  4) Be sure to enclose in "Double Quotes" anything with special characters, for example, spaces, commas, hyphens etc. The examples below, illustrate this well.
    ##########

    .EXAMPLE

    When using the EmailDomain parameter, simply type -EmailDomain, then hit the space-bar, then tab through the available email domains.  The email domains are dynamically acquired from the environment where the script is run.
    
    New-UserToCloud -UserToCopy SmithJ -FirstName Naomi -LastName Queen -StorePhone "777-222-3333,234" -MobilePhone "404-234-5555" -Description "Naomi's Description" -Prefix NN -Password "Pass1255!!!$" -EmailDomain contoso.com
    
    .EXAMPLE
    Notice the -NoMail switch (below).  This skips the process of creating a mailbox for this user

    New-UserToCloud -NoMail -UserToCopy SmithJ -FirstName Naomi -LastName Queen -StorePhone "777-222-3333,234" -MobilePhone "404-234-5555" -Description "Naomi's Description" -Prefix NN -Password "Pass1255!!!$" -EmailDomain contoso.com
    
    .EXAMPLE
    Notice the -Shared switch (below).  Use this to create a shared mailbox.  An Exchange Online License is needed but is automatically removed after 6 minutes

    New-UserToCloud -Shared -UserToCopy SharedTemplate -FirstName Shared -LastName Sales -Description "Shared's Description" -Prefix NN -Password "Pass1255!!!$" -EmailDomain contoso.com
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]  
        [string] $UserToCopy,
        [Parameter(ParameterSetName = "Shared")]   
        [switch] $Shared,
        [Parameter(ParameterSetName = "New")]
        [switch] $New,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $FirstName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $LastName,
        [Parameter(Mandatory, ParameterSetName = "Shared")]
        [ValidateScript( {if ($_ -notlike "* *") {Return $True} else {Write-Host "Please choose an SharedMailboxEmailAlias without spaces"}})]
        [string] $SharedMailboxEmailAlias,
        [Parameter(ParameterSetName = "Shared")]
        [string] $DisplayName,
        [Parameter(ParameterSetName = "Copy")]
        [Parameter(ParameterSetName = "New")]
        [string] $OfficePhone,
        [Parameter(ParameterSetName = "Copy")]
        [Parameter(ParameterSetName = "New")]
        [string] $MobilePhone,
        [parameter(ParameterSetName = "Copy")]
        [parameter(ParameterSetName = "New")]
        [Parameter(ParameterSetName = "Shared")]
        [string] $Description,
        [parameter(ParameterSetName = "New")]
        [string] $StreetAddress,
        [parameter(ParameterSetName = "New")]
        [string] $City,
        [parameter(ParameterSetName = "New")]
        [string] $State,
        [parameter(ParameterSetName = "New")]
        [string] $Zip,
        [parameter(ParameterSetName = "Copy")]
        [Parameter(ParameterSetName = "New")]
        [ValidateLength(1, 2)]
        [string] $SAMPrefix,
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "NoMail")]
        [string] $Password,
        [Parameter(ParameterSetName = "Copy")]
        [Parameter(ParameterSetName = "New")]
        [switch] $NoMail,
        [parameter(ParameterSetName = "Copy")]
        [parameter(ParameterSetName = "New")]
        [parameter(ParameterSetName = "Shared")]        
        [parameter(ParameterSetName = "NoMail")]       
        [string] $OUSearch = "Resources"
    )
    DynamicParam {
        
        
        # Set the dynamic parameters' name
        $ParamName_emaildomain = 'EmailDomain'
        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ParameterSetName = 'NoMail'
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute) 
        # Create the dictionary 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        # Generate and set the ValidateSet 
        $arrSet = [adsi]([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).schema.name.replace("CN=Schema", "LDAP://CN=Partitions")| select -ExpandProperty upnsuffixes
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)    
        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)
        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_emaildomain, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParamName_emaildomain, $RuntimeParameter)

        return $RuntimeParameterDictionary

    }
    
    Begin {

        $RootPath = $env:USERPROFILE + "\ps\"
        $User = $env:USERNAME
        $GuidFolder = Join-Path $env:TEMP ([Guid]::NewGuid().tostring())
        New-Item -Path $GuidFolder -ItemType Directory
       
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
        try {
            Get-AzureADTenantDetail -erroraction stop | Out-Null
        }
        catch {
            Connect-ToCloud Office365 -AzureADver2
        }

        $OUSearch2 = "Users"
        $ou = (Get-ADOrganizationalUnit -Server $domainController -filter * -SearchBase (Get-ADDomain -Server $domainController).distinguishedname -Properties canonicalname | 
                where {$_.canonicalname -match $OUSearch -or $_.canonicalname -match $OUSearch2
            } | Select canonicalname, distinguishedname| sort canonicalname | 
                Out-GridView -PassThru -Title "Choose the OU in which to create the new user, then click OK").distinguishedname
                
        [string[]]$optionsToAdd = (Get-CloudSkuTable -all | Out-GridView -Title "Options to Add" -PassThru)

        Watch-ToLicense -GuidFolder $GuidFolder -optionsToAdd $optionsToAdd
    }

    Process {

        #######################################
        # Copy ADUser (Template) & Create New #
        #######################################
        #Requires -Modules ActiveDirectory
        if ($SharedMailboxEmailAlias) {
            $LastName = $SharedMailboxEmailAlias
        }

        $password_ss = ConvertTo-SecureString -String $Password -AsPlainText -Force

        if ($UserToCopy) {
            if ($UserToCopy -like "*@*") {
                $UserToCopy = (Get-ADUser -LDAPfilter "(userprincipalname=$UserToCopy)").samaccountname
            }
            $template = Get-ADUser -Identity $UserToCopy -Server $domainController -Properties Enabled, StreetAddress, City, State, PostalCode
            $template = $template | Select Enabled, StreetAddress, City, State, PostalCode
            $groupMembership = Get-ADUser -Identity $UserToCopy -Server $domainController -Properties memberof | select -ExpandProperty memberof    
        }
        $Last = $LastName -replace (" ", "")
        $First = $FirstName -replace (" ", "")

        #######################
        #     NOT SHARED      #
        #######################
        if (!$Shared) {

            $DisplayName = $ExecutionContext.InvokeCommand.ExpandString($DisplayNameFormat)
   
            ##############################################
            #              SamAccountName                #
            ##############################################
            if (!$SAMPrefix) {
                $SamAccountName = (($Last[0..6] -join '') + $First)[0..7] -join ''
                $i = 2
                while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                    $CharactersUsedForIteration = ([string]$i).Length
                    $SamAccountName = ((($Last[0..(6 - $CharactersUsedForIteration)] -join '') + $First)[0..(7 - $CharactersUsedForIteration)] -join '') + $i
                    $i++
                }
            }

            else {
                $SamAccountName = ((($SAMPrefix + $LastName)[0..6] -join '') + $First)[0..7] -join ''
                $i = 2
                while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                    $CharactersUsedForIteration = ([string]$i).Length
                    $SamAccountName = (((($SAMPrefix + $LastName)[0..(6 - $CharactersUsedForIteration)] -join '') + $First)[0..(7 - $CharactersUsedForIteration)] -join '') + $i
                    $i++
                }
            }

        } ###   End: NOT SHARED    ###

        #######################
        #  SHARED  UPN & SAM  #
        #######################

        Else {
            $LastName = $LastName.replace(" ", "")

            $SamAccountName = $Last[0..7] -join ''
            $i = 2
            while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                $CharactersUsedForIteration = ([string]$i).Length
                $SamAccountName = ($Last[0..(7 - $CharactersUsedForIteration)] -join '') + $i
                $i++
            }

        }

        # SamAccount To Lower
        $samaccountname = $samaccountname.tolower()
        
        # cn
        $cn = $DisplayName
        $i = 2
        while (Get-ADUser -Server $domainController -LDAPFilter "(cn=$cn)") {
            $cn = $DisplayName + $i
            $i++
        }
        $name = $cn

        #########################################
        #   Create Parameters for New ADUser    #
        #########################################
            
        $hash = @{
            "Instance"          = $template
            "Name"              = $name
            "DisplayName"       = $DisplayName
            "GivenName"         = $FirstName
            "SurName"           = $LastName
            "OfficePhone"       = $OfficePhone
            "mobile"            = $MobilePhone
            "description"       = $Description
            "streetaddress"     = $StreetAddress
            "city"              = $City
            "state"             = $State
            "postalcode"        = $Zip
            "SamAccountName"    = $samaccountname
            "UserPrincipalName" = $userprincipalname
            "AccountPassword"   = $password_ss
            "Path"              = $ou
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
        New-ADUser @params -Server $domainController -ChangePasswordAtLogon:$true -Enabled:$true
        
        if ($UserToCopy) {
            $groupMembership | Add-ADGroupMember -Server $domainController -Members $samaccountname
        }

        # Purge old jobs
        Get-Job | where {$_.State -ne 'Running'}| Remove-Job

        if (!$NoMail) {

            ##################################################
            # Enable Remote Mailbox in Office 365 & set UPN  #
            ##################################################
            Enable-OnPremRemoteMailbox -DomainController $domainController -Identity $samaccountname -RemoteRoutingAddress ($samaccountname + "@" + $targetAddressSuffix) -Alias $samaccountname 
            
            # After Email Address Policy, Set UPN to same as PrimarySMTP #
            $userprincipalname = (Get-ADUser -Server $domainController -Identity $SamAccountName -Properties proxyaddresses | Select @{
                    n = "PrimarySMTPAddress" ; e = {( $_.proxyAddresses | ? {$_ -cmatch "SMTP:*"}).Substring(5)}
                }).primarysmtpaddress
            Set-ADUser -Server $domainController -Identity $SamAccountName -userprincipalname $userprincipalname
           
            ########################################
            #          Convert To Shared           #
            ########################################
            if ($Shared) {
                Start-Job -Name ConvertToShared {
                    Start-Sleep -Seconds 300
                    $userprincipalname = $args[0]
                    $userprincipalname | Convert-ToShared
                } -ArgumentList  $userprincipalname | Out-Null
            }

            ########################################
            #     Write UPNs to Temp GUID file     # 
            ########################################

            $tempfile = Join-Path $GuidFolder ([Guid]::NewGuid().tostring())
            $UserPrincipalName | Set-Content $tempfile
    
        } # End of IF MAIL (ABOVE)

        # IF "NO MAIL" FOR THIS USER (BELOW)
        Else {
            $LastName = $LastName.replace(" ", "")
            $FirstName = $FirstName.replace(" ", "")
            $userprincipalname = $LastName + "-" + $FirstName + "@" + $PsBoundParameters[$ParamName_emaildomain]
            
            $i = 2
            $F = $null
            while (Get-ADUser -LDAPfilter "(userprincipalname=$userprincipalname)") {
                $F = $FirstName + $i
                $userprincipalname = $LastName + "-" + $F + "@" + $PsBoundParameters[$ParamName_emaildomain]
                $i++
            }
            if ($F) {
                $name = $LastName + ", " + $F
            }
            else {
                $name = $LastName + ", " + $FirstName
            }
            $userprincipalname = $LastName + "-" + $FirstName + "@" + $PsBoundParameters[$ParamName_emaildomain]
            Set-ADUser -Server $domainController -Identity $SamAccountName -userprincipalname $userprincipalname
        }

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

    End {
        ########################################
        #         Sync Azure AD Connect        #
        ########################################
        Sync-ADConnect

        ########################################
        # Stop the Licensing Watcher Function  #
        ########################################
        Start-Job -Name DeleteGuidFolder {
            $GuidFolder = $args[0]
            New-Item -Path $GuidFolder -Name "ALLDONE" -Type File
            while ((Get-ChildItem -Path $GuidFolder).count -gt 0) {
            }
            Remove-Item -Path $GuidFolder -Confirm:$False -force -verbose
        } -ArgumentList $GuidFolder
    }
}    
