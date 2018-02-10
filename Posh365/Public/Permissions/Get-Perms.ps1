Function Get-Perms {
    <#
    .SYNOPSIS
     Caches certain AD Attributes into 2 Hashtables with Get-ADCache
     
     Outputs the following CSVs to a user-chosen Report Path:

     SendAsPerms.csv
     SendOnBehalfPerms.csv
      
     & optionally:

     FullAccessPerms.csv

    .EXAMPLE

    Get-Perms -ReportPath C:\Scripts\Perms
    
    .EXAMPLE

    Get-Perms -ReportPath C:\Scripts\Perms -IncludeFullAccess
        
    #>
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,
        [Parameter]
        [switch] $IncludeFullAccess
    )
    $ReportPath = $ReportPath.TrimEnd('\')
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
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) |
        Get-SendAsPerms | Select Mailbox, UPN, Granted, Granted, UPN, Permission |
        Export-csv $ReportPath + "\" + "SendAsPerms.csv" -NoTypeInformation

    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) |
        Get-SendOnBehalfPerms | Select Mailbox, UPN, Granted, Granted, UPN, Permission |
        Export-csv $ReportPath + "\" + "SendOnBehalfPerms.csv" -NoTypeInformation
        
    if ($IncludeFullAccess) {
        (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) |
            Get-FullAccessPerms | Select Mailbox, UPN, Granted, Granted, UPN, Permission |
            Export-csv $ReportPath + "\" + "FullAccessPerms.csv" -NoTypeInformation 
    }
}