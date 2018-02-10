Function Get-ADCache {
    
    <#
    .SYNOPSIS
     Caches AD attributes.
     In two different hashtables, keys are:
     1. UserLogon (e.g. domain\SamAccountName)
     2. DistinguishedName
     
     This is for On-Premises Active Directory.

    .EXAMPLE

    Get-ADCache
    
    There will be no output only 2 Hashtables will be created in memory.
    
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,
        [Parameter]
        [switch] $IncludeFullAccess
    )

    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $User = $env:USERNAME

    while (!(Test-Path ($RootPath + "$($user).EXCHServer"))) {
        Select-ExchangeServer
    }
    $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")
    
    if ($exscripts) {
        write-output 'Exchange Management Shell loaded'
    }
    else {
        try {
            $null = Get-Command "Get-ExchangeServer" -ErrorAction Stop
        }
        catch {
            Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix
        }
    }
    
    New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue
    Set-Location $ReportPath

    Write-Verbose "Importing Active Directory Users that have at least one proxy address"
    $AllADUsers = Get-ADUsersWithProxyAddress
    Write-Verbose "Caching hash table. LogonName as Key and Values as DisplayName & UPN"
    $ADHash = $AllADUsers | Get-ADHash
    Write-Verbose "Caching hash table. DN as Key and Values as DisplayName, UPN & LogonName"
    $ADHashDN = $AllADUsers | Get-ADHashDN

    Write-Verbose "Retrieving distinguishedname's of all Exchange Mailboxes"
    $allMailboxes = (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) 
    Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
    $allMailboxes | Get-SendAsPerms -ADHashDN $ADHashDN  | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
        Export-csv .\SendAsPerms.csv -NoTypeInformation
}