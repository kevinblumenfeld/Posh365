function Get-SendAsPerms {
    <#
    .SYNOPSIS
    Outputs Send As permissions for each mailbox that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+
    
    .EXAMPLE 
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-SendAsPerms | Export-csv .\SA.csv -NoTypeInformation
    
    If not running from Exchange Management Shell (EMS):

    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-SendAsPerms -ConnectToExchange | Export-csv .\SA.csv -NoTypeInformation

    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DistinguishedName,
        
        [parameter()]
        [switch] $ConnectToExchange
    )
    Begin {
        import-module activedirectory -ErrorAction SilentlyContinue
        if ($ConnectToExchange) {
            While (!(Get-Content ($RootPath + "$($user).EXCHServer") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
                Select-ExchangeServer
            }
            $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")
            try {
                $null = Get-Command "Get-ExchangeServer" -ErrorAction Stop | Out-Null
            }
            catch {
                Connect-Exchange -ExchangeServer $ExchangeServer -ViewEntireForest -NoPrefix
            }
        }
    }
    Process {
        ForEach ($curDN in $DistinguishedName) {
            $mailbox = $curDN
            Get-ADPermission $curDN | Where-Object {
                $_.ExtendedRights -like "*Send-As*" -and 
                ($_.IsInherited -eq $false) -and 
                !($_.User -like "NT AUTHORITY\SELF") -and 
                !($_.User.tostring().startswith('S-1-5-21-'))
            } | ForEach-Object {
                $User = $_.User
                try {
                    Get-ADGroupMember ($_.user -split "\\")[1] -Recursive -ErrorAction stop | 
                        ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Mailbox    = $ADHashDN.$mailbox.DisplayName
                            UPN        = $ADHashDN.$mailbox.UPN
                            Granted    = $ADHashDN[$_.distinguishedname].DisplayName
                            GrantedUPN = $ADHashDN[$_.distinguishedname].UPN
                            Permission = "SendAs"
                        }    
                    }
                } 
                Catch {
                    New-Object -TypeName psobject -property @{
                        Mailbox    = $ADHashDN.$mailbox.DisplayName
                        UPN        = $ADHashDN.$mailbox.UPN
                        Granted    = $ADHash."$User".DisplayName
                        GrantedUPN = $ADHash."$User".UPN
                        Permission = "SendAs"
                    }
                }
            }
        }
    }
    END {
        
    }
}
