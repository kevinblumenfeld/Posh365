function Get-365MsolGroup { 
    <#
    .SYNOPSIS
    Export Office 365 MsolGroups
    
    .DESCRIPTION
    Export Office 365 MsolGroups
    
    .PARAMETER SpecificMsolGroups
    Provide specific MsolGroups to report on.  Otherwise, all MsolGroups will be reported.  Please review the examples provided.
    
    .PARAMETER DetailedReport
    Provides a full report of all attributes.  Otherwise, only a refined report will be given.
    
    .EXAMPLE
    Get-365MsolGroup | Export-Csv c:\scripts\All365MsolGroups.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    Get-MsolGroup -All | ? {$_.proxyaddresses -like "*contoso.com"} | Select -ExpandProperty ObjectId | Get-365MsolGroup | Export-Csv c:\scripts\365MsolGroups.csv -notypeinformation -encoding UTF8
        
    .EXAMPLE
    Get-Content "c:\scripts\ObjectIDs.txt" | Get-365MsolGroup | Export-Csv c:\scripts\365MsolGroupExport.csv -notypeinformation -encoding UTF8
    
    Example of ObjectIDs.txt
    #####################

    f1b6c9bc-53b2-4cf7-89fe-ce89944e2d75
    fdd2c37e-df09-44f9-8611-5b8cdedf698e
    24f5185a-eca4-4314-a7d7-024c2b7ebca6

    #####################

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $SpecificGroups
    )
    Begin {
        if ($DetailedReport) {
            $Selectproperties = @('CommonName', 'Description', 'DisplayName', 'EmailAddress', 'ManagedBy')

            $CalculatedProps = @(
                @{n = "DirSyncProvisioningErrors" ; e = {($_.DirSyncProvisioningErrors | ? {$_ -ne $null}) -join ";" }},
                @{n = "Errors" ; e = {($_.Errors | ? {$_ -ne $null}) -join ";" }},
                @{n = "GroupType" ; e = {($_.GroupType | ? {$_ -ne $null}) -join ";" }},
                @{n = "IsSystem" ; e = {($_.IsSystem | ? {$_ -ne $null}) -join ";" }},
                @{n = "LastDirSyncTime" ; e = {($_.LastDirSyncTime | ? {$_ -ne $null}) -join ";" }},
                @{n = "Licenses" ; e = {($_.Licenses | ? {$_ -ne $null}) -join ";" }},
                @{n = "ObjectId" ; e = {($_.ObjectId | ? {$_ -ne $null}) -join ";" }},
                @{n = "ProxyAddresses" ; e = {($_.ProxyAddresses | ? {$_ -ne $null}) -join ";" }},
                @{n = "ValidationStatus" ; e = {($_.ValidationStatus | ? {$_ -ne $null}) -join ";" }}                                             
            )
        }
        else {
            $Selectproperties = @('CommonName', 'Description', 'DisplayName', 'EmailAddress', 'ManagedBy')

            $CalculatedProps = @(
                @{n = "GroupType" ; e = {($_.GroupType | ? {$_ -ne $null}) -join ";" }},
                @{n = "LastDirSyncTime" ; e = {($_.LastDirSyncTime | ? {$_ -ne $null}) -join ";" }},
                @{n = "ProxyAddresses" ; e = {($_.ProxyAddresses | ? {$_ -ne $null}) -join ";" }}
            )
        }
    }
    Process {
        if ($SpecificGroups) {
            foreach ($CurObjectID in $SpecificGroups) {
                Get-MsolGroup -ObjectId $CurObjectID | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-MsolGroup -All | Select-Object ($Selectproperties + $CalculatedProps)
        }
    }
    End {
        
    }
}