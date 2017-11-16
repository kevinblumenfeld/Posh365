Function New-UserToCloud {
    
    [CmdletBinding()]
    Param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "UPN")]
        [string] $UserToCopy,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]   
        [switch] $Shared,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "UPN")]
        [switch] $New,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $FirstName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $LastName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]
        [ValidateScript( {if ($_ -notlike "* *") {Return $True} else {Write-Host "Please choose an SharedMailboxEmailAlias without spaces"}})]
        [string] $SharedMailboxEmailAlias,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]
        [string] $DisplayName,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $OfficePhone,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $MobilePhone,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]
        [string] $Description,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $StreetAddress,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $City,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $State,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $Zip,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [ValidateLength(1, 2)]
        [string] $SAMPrefix,
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "UPN")]
        [switch] $NoMail,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $Country,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $Office,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $Title,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $Department,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $Company,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]        
        [string] $OUSearch = "Resources"
    )
    DynamicParam {
            
            
        # Set the dynamic parameters' name
        $ParamName_UPNSuffix = 'UPNSuffix'
        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ParameterSetName = 'UPN'
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
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamName_UPNSuffix, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParamName_UPNSuffix, $RuntimeParameter)
    
        return $RuntimeParameterDictionary
    
    }
        
    Begin {
        $password_ss = Read-Host "Enter a Password for the User" -AsSecureString
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
        #              Connect                #
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
            Connect-ToCloud ($targetAddressSuffix = Get-Content ($RootPath + "$($user).TargetAddressSuffix")) -AzureADver2
        }
    
        $OUSearch2 = "Users"
        $ou = (Get-ADOrganizationalUnit -Server $domainController -filter * -SearchBase (Get-ADDomain -Server $domainController).distinguishedname -Properties canonicalname | 
                where {$_.canonicalname -match $OUSearch -or $_.canonicalname -match $OUSearch2
            } | Select canonicalname, distinguishedname| sort canonicalname | 
                Out-GridView -PassThru -Title "Choose the OU in which to create the new user, then click OK").distinguishedname
        if (!$NoMail) {
            $GuidFolder = Join-Path $env:TEMP ([Guid]::NewGuid().tostring())
            New-Item -Path $GuidFolder -ItemType Directory
            [string[]]$optionsToAdd = (Get-CloudSkuTable -all | Out-GridView -Title "Options to Add" -PassThru)
            Watch-ToLicense -GuidFolder $GuidFolder -optionsToAdd $optionsToAdd
        }        
    
    }
    
    Process {
    
        #######################################
        # Copy ADUser (Template) & Create New #
        #######################################
        #Requires -Modules ActiveDirectory
        if ($SharedMailboxEmailAlias) {
            $LastName = $SharedMailboxEmailAlias
        }
    
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
            "country"           = $Country
            "office"            = $Office
            "title"             = $Title
            "department"        = $Department
            "company"           = $Company                                    
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
            $userprincipalname = $LastName + "-" + $FirstName + "@" + $PsBoundParameters[$ParamName_UPNSuffix]
                
            $i = 2
            $F = $null
            while (Get-ADUser -LDAPfilter "(userprincipalname=$userprincipalname)") {
                $F = $FirstName + $i
                $userprincipalname = $LastName + "-" + $F + "@" + $PsBoundParameters[$ParamName_UPNSuffix]
                $i++
            }
            if ($F) {
                $name = $LastName + ", " + $F
            }
            else {
                $name = $LastName + ", " + $FirstName
            }
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
        if (!$NoMail) {
            Start-Job -Name DeleteGuidFolder {
                $GuidFolder = $args[0]
                New-Item -Path $GuidFolder -Name "ALLDONE" -Type File
                while ((Get-ChildItem -Path $GuidFolder).count -gt 0) {
                }
                Remove-Item -Path $GuidFolder -Confirm:$False -force -verbose
            } -ArgumentList $GuidFolder
        }
    }
}    
    