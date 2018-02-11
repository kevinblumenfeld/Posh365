Function New-UserToCloud {
    
    [CmdletBinding()]
    Param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [string] $UserToCopy,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]   
        [switch] $Shared,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [switch] $New,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $FirstName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [string] $LastName,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Shared")]
        [switch] $SpecifyRetentionPolicy,
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
        [string] $SAMPrefix,
        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = "New")]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "UPN")]
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
        $ParameterAttribute.Mandatory = $false
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ParameterSetName = 'Copy'
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)  
        # Create and set the parameters' attributes
        $ParameterAttribute2 = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute2.Mandatory = $false
        $ParameterAttribute2.Position = 1
        $ParameterAttribute2.ParameterSetName = 'New'
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute2)  
        # Create and set the parameters' attributes
        $ParameterAttribute3 = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute3.Mandatory = $true
        $ParameterAttribute3.Position = 1
        $ParameterAttribute3.ParameterSetName = 'UPN'
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute3)  
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

        While (!(Get-Content ($RootPath + "$($user).SamAccountNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameCharacters
        }
        [int]$SamAccountNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameCharacters")     

        While (!(Get-Content ($RootPath + "$($user).SamAccountNameOrder") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-SamAccountNameOrder
        }
        $SamAccountNameOrder = Get-Content ($RootPath + "$($user).SamAccountNameOrder")
        
        if ($SamAccountNameOrder -eq "SamFirstFirst") {

            While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
                Select-SamAccountNameNumberOfFirstNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters
            }
            [int]$SamAccountNameNumberOfFirstNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters")
            
            While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
                Select-SamAccountNameNumberOfLastNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters -SamAccountNameNumberOfFirstNameCharacters $SamAccountNameNumberOfFirstNameCharacters
            }
            [int]$SamAccountNameNumberOfLastNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters")
            
        }
        else {
            While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
                Select-SamAccountNameNumberOfLastNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters
            }
            [int]$SamAccountNameNumberOfLastNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters")
            
            While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
                Select-SamAccountNameNumberOfFirstNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters -SamAccountNameNumberOfLastNameCharacters $SamAccountNameNumberOfLastNameCharacters
            }
            [int]$SamAccountNameNumberOfFirstNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfFirstNameCharacters")
            
        }

        #######################################
        #              Connect                #
        #######################################
        try {
            $null = Get-Command "Get-OnPremExchangeServer" -ErrorAction Stop
        }
        catch {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest
        }
        try {
            $null = Get-AzureADTenantDetail -erroraction stop -ErrorAction Stop
        }
        catch {
            Connect-Cloud $targetAddressSuffix -AzureADver2      
        }
        If ($SpecifyRetentionPolicy) {
            try {
                $null = Get-Command "Get-CloudMsolAccountSku" -ErrorAction Stop
            }
            Catch {
                Connect-Cloud $targetAddressSuffix -ExchangeOnline -EXOPrefix
            }
            Remove-Variable -Name RetentionPolicyToAdd -ErrorAction SilentlyContinue
            while ($RetentionPolicyToAdd.count -ne "1") {
                try {
                    $RetentionPolicyToAdd = ((Get-CloudRetentionPolicy -erroraction stop).name | Out-GridView -Title "Choose a single Retention Policy and Click OK" -PassThru)
                }
                Catch {
                    Write-Output "Error running the command Get-CloudRetentionPolicy."
                    Write-Output "Please make sure you are connected to Exchange Online with the Prefix, Cloud, and try again"
                    Break
                }
            }
        }

    
        $OUSearch2 = "Users"
        $ou = (Get-ADOrganizationalUnit -Server $domainController -filter * -SearchBase (Get-ADDomain -Server $domainController).distinguishedname -Properties canonicalname | 
                where {$_.canonicalname -match $OUSearch -or $_.canonicalname -match $OUSearch2
            } | Select canonicalname, distinguishedname| sort canonicalname | 
                Out-GridView -PassThru -Title "Choose the OU in which to create the new user, then click OK").distinguishedname
        if (!$NoMail) {
            $GuidFolder = Join-Path $env:TEMP ([Guid]::NewGuid().tostring())
            New-Item -Path $GuidFolder -ItemType Directory
            [string[]]$optionsToAdd = (Get-CloudSkuTable -all | Out-GridView -Title "Choose License Options, with Control + Click" -PassThru)
            Watch-ToLicense -GuidFolder $GuidFolder -optionsToAdd $optionsToAdd
            $GuidFolderRetention = Join-Path $env:TEMP ([Guid]::NewGuid().tostring())
            New-Item -Path $GuidFolderRetention -ItemType Directory
            Watch-ToSetRetention -GuidFolderRetention $GuidFolderRetention -RetentionPolicyToAdd $RetentionPolicyToAdd

        }        
    
    }
    
    Process {
    
        #######################################
        # Copy ADUser (Template) & Create New #
        #######################################

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
                if ($SamAccountNameOrder -eq "SamFirstFirst") {
                    # SamFIRSTFirst
                    $SamAccountName = (($First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last)[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join ''
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = ((($First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last)[0..($SamAccountNameNumberOfLastNameCharacters - ($CharactersUsedForIteration + 1))] -join '') + $i
                        $i++
                    }
                }
                else {
                    # SamFIRSTFirst
                    $SamAccountName = (($Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '') + $First)[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join ''
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = ((($Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '') + $First)[0..($SamAccountNameNumberOfFirstNameCharacters - ($CharactersUsedForIteration + 1))] -join '') + $i
                        $i++
                    }
                }
            }
    
            else {
                [int]$SAMPrefixNumberOfCharacters = ([string]$SAMPrefix).Length
                if ($SamAccountNameOrder -eq "SamFirstFirst") {
                    # SamFIRSTFirst w/ PREFIX
                    $SamAccountName = (($SAMPrefix + $First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last)[0..($SamAccountNameNumberOfLastNameCharacters - ($SAMPrefixNumberOfCharacters + 1))] -join ''
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = ((($First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last)[0..($SamAccountNameNumberOfLastNameCharacters - ($SAMPrefixNumberOfCharacters + $CharactersUsedForIteration + 1))] -join '') + $i
                        $i++
                    }
                }
                else {
                    # SamLASTFirst w/ PREFIX
                    $SamAccountName = ($SAMPrefix + $Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '' + $First[0..($SamAccountNameNumberOfFirstNameCharacters - ($SAMPrefixNumberOfCharacters + 1))] -join '')
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = ($SAMPrefix + $Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '' + $First[0..($SamAccountNameNumberOfFirstNameCharacters - ($SAMPrefixNumberOfCharacters + $CharactersUsedForIteration + 1))] -join '') + $i
                        $i++
                    }
                }
            } ### End with Prefix 
        } ###   End: NOT SHARED    ###
    
        #######################
        #   SHARED  SAMACCT   #
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
            
        # Set CN to DisplayName
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
            #      Enable Remote Mailbox in Office 365       #
            ##################################################
            Enable-OnPremRemoteMailbox -DomainController $domainController -Identity $samaccountname -RemoteRoutingAddress ($samaccountname + "@" + $targetAddressSuffix) -Alias $samaccountname 
            
            ##############################################################
            #                  Set UserPrincipalName                     #
            # After Email Address Policy, Set UPN to same as PrimarySMTP #
            ##############################################################
            
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
                    $userprincipalname | ConvertTo-Shared
                } -ArgumentList  $userprincipalname | Out-Null
            }
    
            ########################################
            #     Write UPNs to Temp GUID file     # 
            ########################################
    
            $tempfile = Join-Path $GuidFolder ([Guid]::NewGuid().tostring())
            $UserPrincipalName | Set-Content $tempfile
            $tempfileRetention = Join-Path $GuidFolderRetention ([Guid]::NewGuid().tostring())
            $UserPrincipalName | Set-Content $tempfileRetention
        
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
                $GuidFolderRetention = $args[1]
                New-Item -Path $GuidFolder -Name "ALLDONE" -Type File
                New-Item -Path $GuidFolderRetention -Name "ALLDONE" -Type File
                while ((Get-ChildItem -Path $GuidFolder).count -gt 0) {
                }
                Remove-Item -Path $GuidFolder -Confirm:$False -force -verbose
                while ((Get-ChildItem -Path $GuidFolderRetention).count -gt 0) {
                }
                Remove-Item -Path $GuidFolderRetention -Confirm:$False -force -verbose
            } -ArgumentList $GuidFolder, $GuidFolderRetention
        }
    }
}    
    