Function Get-DGPerms {
    
    <#
    .SYNOPSIS
    By default, creates permissions reports for all DGs with SendAs Permissions.
    The combined report will be called, DGAllPermissions.csv

    If same Report Path is chosen, existing files will be overwritten.

    CSVs headers:
    "Object","UPN","Granted","GrantedUPN","Permission"

    .EXAMPLE
    Get-DGPerms -ReportPath C:\PermsReports -Verbose
    
    .EXAMPLE
    Get-DGPerms -ReportPath C:\PermsReports -PowerShell2 -ExchangeServer "ExServer01" -Verbose
    ***ONLY PS2: When running from PowerShell 2 (Exchange 2010 Server)***

    ***FIRST***: Be sure to dot-source the function with the below command (change the path):
    Get-ChildItem -Path "C:\scripts\Posh365\" -filter *.ps1 -Recurse | % { . $_.fullname }
    It is normal to see errors when running the above command, as some of the functions (that aren't needed here) do not support PS2                 
    
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,

        [Parameter()]
        [switch] $PowerShell2,
        
        [Parameter()]
        [string] $ExchangeServer
    )

    Try {
        import-module activedirectory -ErrorAction Stop
    }
    Catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $User = $env:USERNAME

    Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
        ($_.name -eq "OnPremExchage" -or $_.name -like "Session for implicit remoting module at*") -and ($_.availability -ne "Available" -and $_.State -ne "Opened")} | 
        ForEach-Object {Remove-PSSession $_.id}
    
    if ($PowerShell2) {
        Write-Warning "**************************************************************************************************"
        Write-Warning "    You have selected -PowerShell2 which indicates that you are running this from PowerShell 2    "
        Write-Warning "If you haven't already, make sure to dot-source the functions with this command (change the Path):"
        Write-Warning "      Get-ChildItem -Path `"C:\scripts\Posh365\`" -filter *.ps1 -Recurse | % { . `$_.fullname }   "
        Write-Warning "                    It is normal to see errors when running the above command                     "
        Write-Warning "**************************************************************************************************"
        if (!$ExchangeServer) {
            Write-Warning "********************************************************************************************"
            Write-Warning "               Re-Run the command specifying the -ExchangeServer parameter                  "
            Write-Warning "ex. Get-DGPerms -ReportPath C:\PermsReports -PowerShell2 -ExchangeServer `"ExServer01`""
            Write-Warning "                               Script is terminating                                        "
            Write-Warning "********************************************************************************************"
            throw
        }
        if (Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
                ($_.name -eq "OnPremExchage" -or $_.name -like "Session for implicit remoting module at*") -and ($_.availability -ne "Available" -and $_.State -ne "Opened")}) {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix -NoMessageForPS2
        }
    }
    else {
        while (!(Test-Path ($RootPath + "$($user).EXCHServer"))) {
            Select-ExchangeServer
        }
        $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")
        if (Get-PSSession -ErrorAction SilentlyContinue | Where-Object {
                ($_.name -eq "OnPremExchage" -or $_.name -like "Session for implicit remoting module at*") -and ($_.availability -ne "Available" -and $_.State -ne "Opened")}) {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix
        }
    }
    New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue

    $DomainNameHash = Get-DomainNameHash

    Write-Verbose "Importing Active Directory Users that have at least one proxy address"
    $AllADObjects = Get-ADUsersAndGroupsWithProxyAddress -DomainNameHash $DomainNameHash

    Write-Verbose "Caching hash table. LogonName as Key and Values of DisplayName & UPN"
    $ADHashDG = $AllADObjects | Get-ADHashDG

    Write-Verbose "Caching hash table. DN as Key and Values of DisplayName, UPN & LogonName"
    $ADHashDGDN = $AllADObjects | Get-ADHashDGDN

    Write-Verbose "Retrieving distinguishedname's of all Exchange Distribution Groups"
    $AllDGDNs = Get-Recipient -ResultSize Unlimited -RecipientTypeDetails 'MailUniversalDistributionGroup', 'MailUniversalSecurityGroup' | Select -ExpandProperty distinguishedname 

    Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
    $AllDGDNs | Get-DGSendAsPerms -ADHashDGDN $ADHashDGDN -ADHashDG $ADHashDG  | Select Object, PrimarySMTP, Granted, GrantedUPN, GrantedSMTP, Permission |
        Export-csv (Join-Path $ReportPath "DGSendAsPerms.csv") -NoTypeInformation
    
    $AllPermissions = $null
    $Report = $ReportPath.ToString()
    $Report = $Report.TrimEnd('\') + "\*"
    $AllPermissions = Get-ChildItem -Path $Report -Include "DGSendAsPerms.csv" -Exclude "DGAllPermissions.csv" | % {
        Import-Csv $_
    }
    
    $AllPermissions | Export-Csv (Join-Path $ReportPath "DGAllPermissions.csv") -NoTypeInformation
    Write-Verbose "Combined all CSV's into a single file named, DGAllPermissions.csv"
}