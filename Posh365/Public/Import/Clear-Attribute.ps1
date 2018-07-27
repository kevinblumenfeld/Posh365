function Clear-Attribute { 
    <#
    
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row

    )
    Begin {
       
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-Error_Log.csv")
        
        $Selectproperties = @(
            'Name', 'DistinguishedName', 'ObjectGUID', 'DisplayName'
        )
        $CalculatedProperties = @(
            @{n = "msRTCSIP-DeploymentLocator" ; e = {($_."CurRow.msRTCSIP-DeploymentLocator" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-FederationEnabled" ; e = {($_."msRTCSIP-FederationEnabled" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-InternetAccessEnabled" ; e = {($_."msRTCSIP-InternetAccessEnabled" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-OptionFlags" ; e = {($_."msRTCSIP-OptionFlags" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-PrimaryHomeServer" ; e = {($_."msRTCSIP-PrimaryHomeServer" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-PrimaryUserAddress" ; e = {($_."msRTCSIP-PrimaryUserAddress" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msRTCSIP-UserEnabled" ; e = {($_."msRTCSIP-UserEnabled" | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "msExchShadowProxyAddresses" ; e = {($_."msExchShadowProxyAddresses" | Where-Object {$_ -ne $null}) -join ";" }}
        )
        $Attribute = 'msRTCSIP-DeploymentLocator','msRTCSIP-FederationEnabled','msRTCSIP-InternetAccessEnabled','msRTCSIP-OptionFlags','msRTCSIP-PrimaryHomeServer','msRTCSIP-PrimaryUserAddress','msRTCSIP-UserEnabled','msExchShadowProxyAddresses'
 
    }
    Process {
        ForEach ($CurRow in $Row) {
            $ADUser = Get-ADUser -Filter "DisplayName -eq '$CurRow'" -properties $Attribute  |  Select-Object ($Selectproperties + $CalculatedProperties)
            if (-not $LogOnly) {
                foreach ($CurAttribute in $Attribute) {
                    Write-Verbose "Clearing Current Attribute: $CurAttribute"
                    Set-ADUser -identity $ADUser.ObjectGUID -clear $CurAttribute
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
