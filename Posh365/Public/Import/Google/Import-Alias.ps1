
function Import-Alias {
    <#

    .SYNOPSIS
    Import Aliases (aka Secondary Email Addresses) to Exchange OnPremises Mailboxes or MailUsers) and Groups. Alternatively ActiveDirectory Users or Groups

    .DESCRIPTION
    Import Aliases (aka Secondary Email Addresses) to Exchange OnPremises Mailboxes or MailUsers) and Groups. Alternatively ActiveDirectory Users or Groups

    .PARAMETER CSVFilePath
    A list of aliases (secondary email addresses) to feed the script
    The CSV's expected headers
    Alias	Target	TargetType

    .PARAMETER AddtoObjectType
    Choose from 'MailUser', 'Mailbox', or 'ActiveDirectory'
    MailUser and Mailbox will use Set-MailUser/Mailbox respectively and Set-DistributionGroup for Groups
    ActiveDirectory will use Set-ADUser and Set-ADGroup for Groups

    .EXAMPLE
    Import-Alias -AddtoObjectType MailUser -CSVFilePath C:\scripts\ContosoAliases.csv | Export-Csv .\Results.csv -notypeinformation

    .EXAMPLE
    Import-Alias -AddtoObjectType Mailbox -CSVFilePath C:\scripts\ContosoAliases.csv | Export-Csv .\Results.csv -notypeinformation

    .EXAMPLE
    Import-Alias -AddtoObjectType ActiveDirectory -CSVFilePath C:\scripts\ContosoAliases.csv | Export-Csv .\Results.csv -notypeinformation

    .NOTES
    The CSV's expected headers
    Alias	Target	TargetType

    TargetType denotes User (Mailbox or MailUser) or Group (Distribution Group or Security Group)
    The target is the identity of the object to which you will add the alias (secondary email address).

    when adding to alias to ActiveDirectory the script will prepend smtp: to the alias and then add it.

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $CSVFilePath,

        [Parameter(Mandatory)]
        [ValidateSet('MailUser', 'Mailbox', 'ActiveDirectory')]
        [string]
        $AddtoObjectType
    )
    $AliasList = Import-Csv $CSVFilePath
    if ($AddtoObjectType -eq 'MailUser') {
        foreach ($Alias in $AliasList) {
            if ($Alias.Alias -and $Alias.TargetType -eq 'User') {
                try {
                    Set-MailUser -Identity $Alias.Target -Add @{'EmailAddresses' = $Alias.Alias } -ErrorAction Stop
                    Write-Host "Success adding alias $($Alias.Alias) to mailbox $($Alias.Target)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'SUCCESS'
                        Log        = 'SUCCESS'
                    }
                }
                catch {
                    Write-Host "Failed adding alias $($Alias.Alias) to mailbox $($Alias.Target)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'FAILED'
                        Log        = $_.Exception.Message
                    }
                }
            }
            elseif ($Alias.Alias -and $Alias.TargetType -eq 'Group') {
                try {
                    Set-DistributionGroup -Identity $Alias.Target -Add @{'EmailAddresses' = $Alias.Alias } -ErrorAction Stop
                    Write-Host "Failed adding alias $($Alias.Alias) to distribution group $($Alias.Target)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'SUCCESS'
                        Log        = 'SUCCESS'
                    }
                }
                catch {
                    Write-Host "Failed adding alias $($Alias.Alias) to distribution group $($Alias.Target)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'FAILED'
                        Log        = $_.Exception.Message
                    }
                }
            }
        }
    }
    elseif ($AddtoObjectType -eq 'Mailbox') {
        foreach ($Alias in $AliasList) {
            if ($Alias.Alias -and $Alias.TargetType -eq 'User') {
                try {
                    Set-Mailbox -Identity $Alias.Target -Add @{'EmailAddresses' = $Alias.Alias } -ErrorAction Stop
                    Write-Host "Success adding alias $($Alias.Alias) to Mailbox $($Alias.Target)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'SUCCESS'
                        Log        = 'SUCCESS'
                    }
                }
                catch {
                    Write-Host "Failed adding alias $($Alias.Alias) to Mailbox $($Alias.Target)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'FAILED'
                        Log        = $_.Exception.Message
                    }
                }
            }
            elseif ($Alias.Alias -and $Alias.TargetType -eq 'Group') {
                try {
                    Set-DistributionGroup -Identity $Alias.Target -Add @{'EmailAddresses' = $Alias.Alias } -ErrorAction Stop
                    Write-Host "Failed adding alias $($Alias.Alias) to distribution group $($Alias.Target)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'SUCCESS'
                        Log        = 'SUCCESS'
                    }
                }
                catch {
                    Write-Host "Failed adding alias $($Alias.Alias) to distribution group $($Alias.Target)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'FAILED'
                        Log        = $_.Exception.Message
                    }
                }
            }
        }
    }
    elseif ($AddtoObjectType -eq 'ActiveDirectory') {
        foreach ($Alias in $AliasList) {
            if ($Alias.Alias -and $Alias.TargetType -eq 'User') {
                try {
                    Set-ADUser -Identity $Alias.Target -Add @{'ProxyAddresses' = 'smtp:{0}' -f $Alias.Alias } -ErrorAction Stop
                    Write-Host "Success adding alias $($Alias.Alias) to ADUser $($Alias.Target)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'SUCCESS'
                        Log        = 'SUCCESS'
                    }
                }
                catch {
                    Write-Host "Failed adding alias $($Alias.Alias) to ADUser $($Alias.Target)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'FAILED'
                        Log        = $_.Exception.Message
                    }
                }
            }
            elseif ($Alias.Alias -and $Alias.TargetType -eq 'Group') {
                try {
                    Set-ADGroup -Identity $Alias.Target -Add @{'ProxyAddresses' = 'smtp:{0}' -f $Alias.Alias } -ErrorAction Stop
                    Write-Host "Failed adding alias $($Alias.Alias) to ADGroup $($Alias.Target)" -ForegroundColor Green
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'SUCCESS'
                        Log        = 'SUCCESS'
                    }
                }
                catch {
                    Write-Host "Failed adding alias $($Alias.Alias) to ADGroup $($Alias.Target)" -ForegroundColor Red
                    [PSCustomObject]@{
                        Alias      = $Alias.Alias
                        Target     = $Alias.Target
                        TargetType = $Alias.TargetType
                        Result     = 'FAILED'
                        Log        = $_.Exception.Message
                    }
                }
            }
        }
    }
}
