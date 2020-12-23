
function Import-GoogleAliasToEx {
    <#

    .SYNOPSIS
    Import Google Aliases to Exchange OnPremises Mailboxes and Groups

    .DESCRIPTION
    Import Google Aliases to Exchange OnPremises Mailboxes and Groups
    
    .EXAMPLE
    Import-GoogleAliasToEx -CSVFilePath C:\scripts\ContosoAliases.csv | Export-Csv .\Results.csv -notypeinformation
    
    .NOTES
    The CSV's expected headers
    Alias	Target	TargetType
       
    TargetType denotes User (Mailbox) or Group (Distribution Group or Security Group)

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $CSVFilePath
    )
    $AliasList = Import-Csv $CSVFilePath
    foreach ($Alias in $AliasList) {
        if ($Alias.Alias -and $Alias.TargetType -eq 'User') {
            try {
                Set-Mailbox -Identity $Alias.Target -Add @{'EmailAddresses' = $Alias.Alias } -ErrorAction Stop
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