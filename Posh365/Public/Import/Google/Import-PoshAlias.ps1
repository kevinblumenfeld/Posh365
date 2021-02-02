
function Import-PoshAlias {
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
    Import-PoshAlias -AddtoObjectType MailUser -CSVFilePath C:\scripts\ContosoAliases.csv | Export-Csv .\Results.csv -notypeinformation

    .EXAMPLE
    Import-PoshAlias -AddtoObjectType Mailbox -CSVFilePath C:\scripts\ContosoAliases.csv | Export-Csv .\Results.csv -notypeinformation

    .EXAMPLE
    Import-PoshAlias -AddtoObjectType ActiveDirectory -CSVFilePath C:\scripts\ContosoAliases.csv | Export-Csv .\Results.csv -notypeinformation

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
            $Found = $null
            if ($Alias.Alias -and $Alias.TargetType -eq 'User') {
                if ($Alias.Target -like '*@*') {
                    # GET ADUSER
                    try {
                        $Found = Get-ADUser -Filter "mail -eq '$($Alias.Target)'"
                        Write-Host "Success finding ADUSER $($Alias.Target) via MAIL attribute" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAIL'
                            Action     = 'GETADUSER'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed finding ADUSER $($Alias.Target) via MAIL attribute" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAIL'
                            Action     = 'GETADUSER'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }
                }
                else {
                    try {
                        $Found = Get-ADUser -Filter "SamAccountName -eq '$($Alias.Target)'"
                        Write-Host "Success finding ADUSER $($Alias.Target) via SAMACCOUNTNAME attribute" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'SAMACCOUNTNAME'
                            Action     = 'GETADUSER'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed finding ADUSER $($Alias.Target) via SAMACCOUNTNAME attribute" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'SAMACCOUNTNAME'
                            Action     = 'GETADUSER'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }
                }
                # SET ADUSER
                if ($Found) {
                    try {
                        $Found | Set-ADUser -Add @{'ProxyAddresses' = 'smtp:{0}' -f $Alias.Alias } -ErrorAction Stop
                        Write-Host "Success adding ADUSER alias $($Alias.Alias)" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'ADUSER'
                            Action     = 'SETADUSER'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed adding ADUSER alias $($Alias.Alias)" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'ADUSER'
                            Action     = 'SETADUSER'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }

                }
                if (($Found.mail -and $Alias.Target) -and ($Found.mail -eq $Alias.Target)) {
                    try {
                        $Found | Set-ADUser -Add @{'ProxyAddresses' = 'SMTP:{0}' -f $Alias.Target } -ErrorAction Stop
                        Write-Host "Success adding ADUSER PrimarySmtpAddress to proxyaddresses $($Alias.Target)" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAILMATCHESTARGET'
                            Action     = 'SETADUSER'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed adding ADUSER PrimarySmtpAddress to proxyaddresses $($Alias.Target)" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAILMATCHESTARGET'
                            Action     = 'SETADUSER'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }
                }
            }
            elseif ($Alias.Alias -and $Alias.TargetType -eq 'Group') {
                if ($Alias.Target -like '*@*') {
                    # GET ADGROUP
                    try {
                        $Found = Get-ADGroup -Filter "mail -eq '$($Alias.Target)'"
                        Write-Host "Success finding ADGroup $($Alias.Target) via MAIL attribute" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAIL'
                            Action     = 'GETADGROUP'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed finding ADGroup $($Alias.Target) via MAIL attribute" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAIL'
                            Action     = 'GETADGROUP'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }
                }
                else {
                    try {
                        $Found = Get-ADGroup -Filter "SamAccountName -eq '$($Alias.Target)'"
                        Write-Host "Success finding ADGroup $($Alias.Target) via SAMACCOUNTNAME attribute" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'SAMACCOUNTNAME'
                            Action     = 'GETADGROUP'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed finding ADGroup $($Alias.Target) via SAMACCOUNTNAME attribute" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'SAMACCOUNTNAME'
                            Action     = 'GETADGROUP'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }
                }
                # SET ADGROUP
                if ($Found) {
                    try {
                        $Found | Set-ADGroup -Add @{'ProxyAddresses' = 'smtp:{0}' -f $Alias.Alias } -ErrorAction Stop
                        Write-Host "Success adding ADGROUP alias $($Alias.Alias)" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'ADGroup'
                            Action     = 'SETADGROUP'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed adding ADGROUP alias $($Alias.Alias)" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'ADGroup'
                            Action     = 'SETADGROUP'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }
                }
                if (($Found.mail -and $Alias.Target) -and ($Found.mail -eq $Alias.Target)) {
                    try {
                        $Found | Set-ADGroup -Add @{'ProxyAddresses' = 'SMTP:{0}' -f $Alias.Target } -ErrorAction Stop
                        Write-Host "Success adding ADGROUP PrimarySmtpAddress to proxyaddresses $($Alias.Target)" -ForegroundColor Green
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAILMATCHESTARGET'
                            Action     = 'SETADGROUP'
                            Result     = 'SUCCESS'
                            Log        = 'SUCCESS'
                        }
                    }
                    catch {
                        Write-Host "Failed adding ADGROUP PrimarySmtpAddress to proxyaddresses $($Alias.Target)" -ForegroundColor Red
                        [PSCustomObject]@{
                            Alias      = $Alias.Alias
                            Target     = $Alias.Target
                            TargetType = $Alias.TargetType
                            Found      = 'MAILMATCHESTARGET'
                            Action     = 'SETADGROUP'
                            Result     = 'FAILED'
                            Log        = $_.Exception.Message
                        }
                    }
                }
            }
        }
    }
}
