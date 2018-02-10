Function Get-MailboxPerms {
    
    <#
    .SYNOPSIS


    .EXAMPLE

    
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,
        [Parameter()]
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

    Write-Output "Importing Active Directory Users that have at least one proxy address"
    $AllADUsers = Get-ADUsersWithProxyAddress
    Write-Output "Caching hash table. LogonName as Key and Values as DisplayName & UPN"
    $ADHash = $AllADUsers | Get-ADHash
    Write-Output "Caching hash table. DN as Key and Values as DisplayName, UPN & LogonName"
    $ADHashDN = $AllADUsers | Get-ADHashDN
    Write-Output "Caching hash table. CN as Key and Values as DisplayName, UPN & LogonName"
    $ADHashCN = $AllADUsers | Get-ADHashCN

    Write-Output "Retrieving distinguishedname's of all Exchange Mailboxes"
    $allMailboxes = (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname)

    Write-Output "Getting SendAs permissions for each mailbox and writing to file"
    $allMailboxes | Get-SendAsPerms -ADHashDN $ADHashDN -ADHash $ADHash  | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
        Export-csv .\SendAsPerms.csv -NoTypeInformation

    Write-Output "Getting SendOnBehalf permissions for each mailbox and writing to file"
    $allMailboxes | Get-SendOnBehalfPerms -ADHashDN $ADHashCN | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
        Export-csv .\SendOnBehalfPerms.csv -NoTypeInformation
    
    if ($IncludeFullAccess) {
        Write-Output "Getting FullAccess permissions for each mailbox and writing to file"
        $allMailboxes | Get-FullAccessPerms -ADHashDN $ADHashDN -ADHash $ADHash  | Select Mailbox, UPN, Granted, GrantedUPN, Permission |
            Export-csv .\FullAccessPerms.csv -NoTypeInformation
    }
}