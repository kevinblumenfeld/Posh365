Function New-HybridMailbox {
    <#
    .SYNOPSIS
    Designed to create and manage users in Hybrid Office 365 environment.
    On-Premises Exchange server is required.  
    
    .DESCRIPTION
    Designed to create and manage users in Hybrid Office 365 environment.
    On-Premises Exchange server is required.  
        
    The UserPrincipalName is created by copying the Primary SMTP Address (as created by the On-Premises Exchange Email Address Policies).
    Alternatively use the -PrimarySMTPAddress parameter)
    Can be run from any machine on the domain that has the module for ActiveDirectory installed.
    The script will prompt once for the names of a Domain Controller, Exchange Server and the Azure AD Connect server.
    The script will also prompt once for DisplayName & SamAccountName Format.
    All of these prompts will only occur once per machine (per user).
    Should you wish to change any/all options just run: Select-Options
    The script stores & encrypts both your Exchange/AD & Office 365 password.  
    You should be prompted only once unless your password changes or a time-out occurs.

    By default, the script creates an new Active Directory User & corresponding mailbox in Exchange Online.

    You will be prompted for the OU where to place the user(s).  
    By default, you will be presented to choose from all OUs with the word "user" or "resource" in it.
    To add additional search criteria, use:  -OUSearch "SomeOtherSearchCriteria"
    You will also be prompted for which license options the user should receive.

    If using the "UserToCopy" parameter, the new user will receive all the attributes (Enabled, StreetAddress, City, State, PostalCode & Group Memberships).
    The script enables the option: User must change password at next logon.  Unless this switch is used: -DontForceUserToChangePasswordAtLogon

    Whichever Retention Policy is set to "Default", will be the retention policy that
    the Exchange Online Mailbox will receive - unless this switch is used:  -SpecifyRetentionPolicy
    If -SpecifyRetentionPolicy is used, the script will prompt for which Retention Policy to assign the user(s).

    ** The script will also take CSV input. The minimum parameters are FirstName & LastName **
    **                           See examples below                                          **
        
    .PARAMETER UserToCopy
    Parameter description
    
    .PARAMETER Shared
    Parameter description
    
    .PARAMETER New
    Parameter description
    
    .PARAMETER FirstName
    Parameter description
    
    .PARAMETER LastName
    Parameter description
    
    .PARAMETER SpecifyRetentionPolicy
    Parameter description
    
    .PARAMETER PrimarySMTPAddress
    Parameter description
    
    .PARAMETER SecondarySMTPAddress
    Parameter description
    
    .PARAMETER DontForceUserToChangePasswordAtLogon
    Parameter description
    
    .PARAMETER SharedMailboxEmailAlias
    Parameter description
    
    .PARAMETER DisplayName
    Parameter description
    
    .PARAMETER OfficePhone
    Parameter description
    
    .PARAMETER MobilePhone
    Parameter description
    
    .PARAMETER Description
    Parameter description
    
    .PARAMETER StreetAddress
    Parameter description
    
    .PARAMETER City
    Parameter description
    
    .PARAMETER State
    Parameter description
    
    .PARAMETER Zip
    Parameter description
    
    .PARAMETER SAMPrefix
    Parameter description
    
    .PARAMETER NoMail
    Parameter description
    
    .PARAMETER Country
    Parameter description
    
    .PARAMETER Office
    Parameter description
    
    .PARAMETER Title
    Parameter description
    
    .PARAMETER Department
    Parameter description
    
    .PARAMETER Company
    Parameter description
    
    .PARAMETER OUSearch
    Parameter description
    
    .EXAMPLE
    Import-Csv C:\data\theTEST.csv | New-HybridMailbox

    Example of CSV (illustrated without commas):

    FirstName LastName Description          OfficePhone
    John      Smith    Warehouse            (404)555-1212
    Sally     James    Manager of LA Branch (213)444-2312
    Jeff      Williams Jeff's Description   (404)312-8989
    Jamie     Yothers  Acting CEO           (212)492-6578

    .EXAMPLE
    New-HybridMailbox -FirstName John -LastName Smith

    .EXAMPLE
    New-HybridMailbox -UserToCopy "FredJones@contoso.com" -FirstName Jonathan -LastName Smithson

    .EXAMPLE
    New-HybridMailbox -FirstName Jon -LastName Smith -OfficePhone "(404)555-1212" -MobilePhone "(404)333-5252" -DescriptiADdedon "Hired Feb 12, 2018"
    
    .EXAMPLE
    New-HybridMailbox -FirstName Jon -LastName Smith -StreetAddress "123 Main St" -City "New York" -State "NY" -Zip "10080" -Country "US"
    
    .EXAMPLE
    New-HybridMailbox -FirstName Jon -LastName Smith -Office "Manhattan" -Title "Vice President of Finance" -Department "Finance" -Company "Contoso, Inc."
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [string] $UserToCopy,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]   
        [switch] $Shared,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [switch] $New,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $FirstName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $LastName,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]
        [switch] $SpecifyRetentionPolicy,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]
        [string] $PrimarySMTPAddress,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]
        [string] $SecondarySMTPAddress,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]
        [switch] $DontForceUserToChangePasswordAtLogon,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]
        [ValidateScript( {if ($_ -notlike "* *") {Return $True} else {Write-Host "Please choose an SharedMailboxEmailAlias without spaces"}})]
        [string] $SharedMailboxEmailAlias,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]
        [string] $DisplayName,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $OfficePhone,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $MobilePhone,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]
        [string] $Description,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $StreetAddress,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $City,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $State,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $Zip,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $SAMPrefix,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "UPN")]
        [switch] $NoMail,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $Country,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $Office,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $Title,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $Department,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [string] $Company,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Copy")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "New")]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Shared")]        
        [string] $OUSearch = "Resource"
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
        Try {
            import-module activedirectory -ErrorAction Stop -Verbose:$false
        }
        Catch {
            Write-Host "This module depends on the ActiveDirectory module."
            Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
            throw
        }
        $password_ss = Read-Host "Enter a Password for the User(s) " -AsSecureString
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
        }
        else {
            While (!(Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
                Select-SamAccountNameNumberOfLastNameCharacters -SamAccountNameCharacters $SamAccountNameCharacters
            }
            [int]$SamAccountNameNumberOfLastNameCharacters = Get-Content ($RootPath + "$($user).SamAccountNameNumberOfLastNameCharacters")
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
            try {
                $RetentionPolicyToAdd = ((Get-CloudRetentionPolicy -erroraction stop).name | Out-GridView -OutputMode Single -Title "Choose a single Retention Policy and Click OK")
            }
            Catch {
                Write-Output "Error running the command Get-CloudRetentionPolicy."
                Write-Output "Please make sure you are connected to Exchange Online with the Prefix, Cloud, and try again"
                Break
            }
        }
    
        $OUSearch2 = "User"
        $ou = (Get-ADOrganizationalUnit -Server $domainController -filter * -SearchBase (Get-ADDomain -Server $domainController).distinguishedname -Properties canonicalname | 
                where {$_.canonicalname -match $OUSearch -or $_.canonicalname -match $OUSearch2
            } | Select canonicalname, distinguishedname| sort canonicalname | 
                Out-GridView -OutputMode Single -Title "Choose the OU in which to create the new user, then click OK").distinguishedname
        if (!$NoMail) {
            $GuidFolder = Join-Path $env:TEMP ([Guid]::NewGuid().tostring())
            New-Item -Path $GuidFolder -ItemType Directory
            [string[]]$optionsToAdd = (Get-CloudSkuTable -all | Out-GridView -Title "Choose License Options, with Control + Click" -PassThru)
            Watch-ToLicense -GuidFolder $GuidFolder -optionsToAdd $optionsToAdd
            If ($SpecifyRetentionPolicy) {
                $GuidFolderRetention = Join-Path $env:TEMP ([Guid]::NewGuid().tostring())
                New-Item -Path $GuidFolderRetention -ItemType Directory
                Watch-ToSetRetention -GuidFolderRetention $GuidFolderRetention -RetentionPolicyToAdd $RetentionPolicyToAdd
            }
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
    
        ###############################################
        #     NOT SHARED  DisplayName & SamAccount    #
        ###############################################
        if (!$Shared) {
    
            $DisplayName = $ExecutionContext.InvokeCommand.ExpandString($DisplayNameFormat)

            ##############################################
            #              SamAccountName                #
            ##############################################
            if (!$SAMPrefix) {
                if ($SamAccountNameOrder -eq "SamFirstFirst") {
                    # SamFIRSTFirst
                    $SamAccountName = (($First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last)[0..($SamAccountNameCharacters - 1)] -join ''
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = $SamAccountName = ((($First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last)[0..($SamAccountNameCharacters - ($CharactersUsedForIteration + 1))] -join '') + $i
                        $i++
                    }
                }
                else {
                    # SamLASTFirst
                    $SamAccountName = (($Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '') + $First)[0..($SamAccountNameCharacters - 1)] -join ''
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = ((($Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '') + $First)[0..($SamAccountNameCharacters - ($CharactersUsedForIteration + 1))] -join '') + $i
                        $i++
                    }
                }
            }
    
            else {
                [int]$SAMPrefixNumberOfCharacters = ([string]$SAMPrefix).Length
                if ($SamAccountNameOrder -eq "SamFirstFirst") {
                    # SamFIRSTFirst WITH PREFIX
                    $SamAccountName = ($SAMPrefix + (($First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last))[0..($SamAccountNameCharacters - 1)] -join ''
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = $SamAccountName = ($SAMPrefix + (($First[0..($SamAccountNameNumberOfFirstNameCharacters - 1)] -join '') + $Last))[0..($SamAccountNameCharacters - ($CharactersUsedForIteration + 1))] -join '' + $i
                        $i++
                    }
                }
                else {
                    # SamLASTFirst WITH PREFIX
                    $SamAccountName = ($SAMPrefix + (($Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '') + $First))[0..($SamAccountNameCharacters - 1)] -join ''
                    $i = 2
                    while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                        $CharactersUsedForIteration = ([string]$i).Length
                        $SamAccountName = (($SAMPrefix + (($Last[0..($SamAccountNameNumberOfLastNameCharacters - 1)] -join '') + $First))[0..($SamAccountNameCharacters - ($CharactersUsedForIteration + 1))] -join '') + $i
                        $i++
                    }
                }
            } ### End with Prefix 
        } ###   End: NOT SHARED DISPLAYNAME AND SAMACCOUNTNAME    ###
    
        #############################
        #  SHARED  SamAccountName   #
        #############################
    
        Else {
            $LastName = $LastName.replace(" ", "")
    
            $SamAccountName = $LastName[0..($SamAccountNameCharacters - 1)] -join ''
            $i = 2
            while (Get-ADUser -Server $domainController -LDAPfilter "(samaccountname=$samaccountname)") {
                $CharactersUsedForIteration = ([string]$i).Length
                $SamAccountName = ($LastName[0..($SamAccountNameCharacters - ($CharactersUsedForIteration + 1))] -join '') + $i
                $i++
            }
    
        } # End: SHARED SAMACCOUNTNAME
    
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

        if (!$DontForceUserToChangePasswordAtLogon) {
            New-ADUser @params -Server $domainController -ChangePasswordAtLogon:$true -Enabled:$true
        }
        else {
            New-ADUser @params -Server $domainController -ChangePasswordAtLogon:$false -Enabled:$true
        }

        if ($UserToCopy) {
            $groupMembership | Add-ADGroupMember -Server $domainController -Members $samaccountname
        }

        if ($PrimarySMTPAddress) {
            $PrimaryProxy = ("SMTP:" + $PrimarySMTPAddress)
            $SIP = ("SIP:" + $PrimarySMTPAddress)
            $Target = ("smtp:" + $samaccountname + "@" + $targetAddressSuffix)
            Set-ADUser -Identity $SamAccountName -Add @{proxyaddresses = $PrimaryProxy}
            Set-ADUser -Identity $SamAccountName -Add @{proxyaddresses = $SIP}
            Set-ADUser -Identity $SamAccountName -Add @{proxyaddresses = $Target}
        } 
        
        if ($SecondarySMTPAddress) {
            $SecondaryProxy = ("smtp:" + $SecondarySMTPAddress)
            Set-ADUser -Identity $SamAccountName -Add @{proxyaddresses = $SecondaryProxy}
        }

        # Purge old jobs
        Get-Job | where {$_.State -ne 'Running'}| Remove-Job
    
        if (!$NoMail) {
    
            ##################################################
            #      Enable Remote Mailbox in Office 365       #
            ##################################################
            if ($PrimarySMTPAddress) {
                Enable-OnPremRemoteMailbox -DomainController $domainController -Identity $samaccountname -PrimarySmtpAddress $PrimarySMTPAddress -RemoteRoutingAddress ($samaccountname + "@" + $targetAddressSuffix) -Alias $samaccountname 
            }
            else {
                Enable-OnPremRemoteMailbox -DomainController $domainController -Identity $samaccountname -RemoteRoutingAddress ($samaccountname + "@" + $targetAddressSuffix) -Alias $samaccountname 
            }
            
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
                    ConvertTo-Shared -UserToConvert $userprincipalname
                } -ArgumentList  $userprincipalname | Out-Null
            }
    
            ########################################
            #     Write UPNs to Temp GUID file     # 
            ########################################
    
            $tempfile = Join-Path $GuidFolder ([Guid]::NewGuid().tostring())
            $UserPrincipalName | Set-Content $tempfile
            If ($SpecifyRetentionPolicy) {
                $tempfileRetention = Join-Path $GuidFolderRetention ([Guid]::NewGuid().tostring())
                $UserPrincipalName | Set-Content $tempfileRetention
            }
        
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
        Sync-ADConnect -Sleep 5
    
        ########################################
        # Stop the Licensing Watcher Function  #
        ########################################
        if (!$NoMail) {
            Start-Job -Name DeleteGuidFolder {
                $GuidFolder = $args[0]
                New-Item -Path $GuidFolder -Name "ALLDONE" -Type File
                while ((Get-ChildItem -Path $GuidFolder).count -gt 0) {
                    Start-Sleep -Seconds 5
                }
                Remove-Item -Path $GuidFolder -Confirm:$False -force -verbose
            } -ArgumentList $GuidFolder
            if ($RetentionPolicyToAdd) {
                Start-Job -Name DeleteGuidFolderRetention {
                    $GuidFolderRetention = $args[0]
                    New-Item -Path $GuidFolderRetention -Name "ALLDONE" -Type File
                    while ((Get-ChildItem -Path $GuidFolderRetention).count -gt 0) {
                    }
                    Remove-Item -Path $GuidFolderRetention -Confirm:$False -force -verbose
                } -ArgumentList  $GuidFolderRetention
            }
        }
    }
}    
