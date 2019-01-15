function Clear-SFBAttribute {
    <#
    .SYNOPSIS
    Clear Attributes of On-Premises Skype users to prepare for Skype For Business Online
    Use -LogOnly first.. to show the attributes to be removed and back them up
    See the examples below

    .DESCRIPTION
    Clear Attributes of On-Premises Skype users to prepare for Skype For Business Online
    Can be tweaked to remove any attributes.
    Run this from PowerShell for Active Directory Users and Computers
    Use with caution as this removes attributes
    This is often use to prep

    The process to move from On-Premises Skype to Skype for Business Online (where there is not hybrid or transition, contact lists are NOT preserved)

    1. Remove Skype for Business Licenses from user(s)
        Install-Module Posh365 -Force -SkipPublisherCheck  (Run PowerShell as admin. this step is one-time thing)
        Connect-Cloud -tenant Contoso -AzureADver2
        Get-Content .\UpnList.txt | Set-CloudLicense -RemoveOptions    (Select-click all entries named Skype & click OK)
    2. Sync AD Connect
        Sync-ADConnect   (if prompted, select the AD Connect server name & click OK)
    3. Remove attributes with this script (run from on-premises Active Directory PowerShell as administrator)
    4. Repeat Step #2
    5. Add Skype License Back
        Get-Content .\UpnList.txt | Set-CloudLicense -AddOptions  (Select one entry named Skype & click OK)

    .PARAMETER LogOnly
    This just logs the values of the attributes that will be cleared plus Name, DistinguishedName, ObjectGuid, DisplayName, UserPrincipalName
    This is important to run prior to validate what/who you are effecting

    .PARAMETER Upn
    This is the UPN of the user to clear the attributes

    .EXAMPLE
    Get-Content .\UpnList.txt | Clear-SFBAttribute

    .EXAMPLE
    "sara@contoso.com" | Clear-SFBAttribute

    .EXAMPLE
    Get-Content .\UpnList.txt | Clear-SFBAttribute -LogOnly | Export-Csv .\AttributeBackup.csv -notypeinformation -Encoding UTF8

    .NOTES
    UpnList.txt should not have a header. For example:

    sara@contoso.com
    fred@contoso.com
    harry@contoso.com

    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Upn

    )
    Begin {

        import-module activedirectory -ErrorAction Stop -Verbose:$false
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-Error_Log.csv")

        $SelectProperties = @(
            'Name', 'DistinguishedName', 'ObjectGuid', 'DisplayName', 'UserPrincipalName'
        )
        $CalculatedProperties = @(
            @{n = "msRTCSIP-DeploymentLocator" ; e = {($_."msRTCSIP-DeploymentLocator" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-FederationEnabled" ; e = {($_."msRTCSIP-FederationEnabled" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-InternetAccessEnabled" ; e = {($_."msRTCSIP-InternetAccessEnabled" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-OptionFlags" ; e = {($_."msRTCSIP-OptionFlags" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-PrimaryHomeServer" ; e = {($_."msRTCSIP-PrimaryHomeServer" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-PrimaryUserAddress" ; e = {($_."msRTCSIP-PrimaryUserAddress" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-UserEnabled" ; e = {($_."msRTCSIP-UserEnabled" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msExchShadowProxyAddresses" ; e = {($_."msExchShadowProxyAddresses" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-UserPolicies" ; e = {($_."msRTCSIP-UserPolicies" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-UserRoutingGroupId" ; e = {($_."msRTCSIP-UserRoutingGroupId" | Where-Object {$_ -ne $null}) -join ";" }}
        )
        $Attribute = @('msRTCSIP-DeploymentLocator', 'msRTCSIP-FederationEnabled', 'msRTCSIP-InternetAccessEnabled', 'msRTCSIP-OptionFlags'
            'msRTCSIP-PrimaryHomeServer', 'msRTCSIP-PrimaryUserAddress', 'msRTCSIP-UserEnabled', 'msExchShadowProxyAddresses', 'msRTCSIP-UserPolicies'
            'msRTCSIP-UserRoutingGroupId', 'DisplayName')

        $Clear = @('msRTCSIP-DeploymentLocator', 'msRTCSIP-FederationEnabled', 'msRTCSIP-InternetAccessEnabled', 'msRTCSIP-OptionFlags'
            'msRTCSIP-PrimaryHomeServer', 'msRTCSIP-PrimaryUserAddress', 'msRTCSIP-UserEnabled', 'msExchShadowProxyAddresses', 'msRTCSIP-UserPolicies'
            'msRTCSIP-UserRoutingGroupId')

    }
    Process {
        ForEach ($CurUpn in $Upn) {
            $FilterString = "UserPrincipalName -eq '{0}'" -f $CurUpn
            $ADUser = Get-ADUser -Filter $FilterString -properties $Attribute  |  Select-Object ($SelectProperties + $CalculatedProperties)
            if (-not $LogOnly) {
                foreach ($CurClear in $Clear) {
                    Write-Verbose "Clearing Current Attribute: $CurClear"
                    Set-ADUser -identity $ADUser.ObjectGuid -clear $CurClear
                }
                $ADUser
            }
            else {
                $ADUser
            }
        }
    }

    End {

    }
}
