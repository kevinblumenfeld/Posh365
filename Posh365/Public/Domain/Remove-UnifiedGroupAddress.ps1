
function Remove-UnifiedGroupAddress {
    <#
    .SYNOPSIS
    Remove all mailbox addresses with one more more domains/words

    .DESCRIPTION
    Remove all mailbox addresses with one more more domains/words

    .PARAMETER Domains
    List of domains or words to find in the email addresses

    .EXAMPLE
    Remove-UnifiedGroupAddress -Domains 'fabrikam.com' | Export-Csv c:\scripts\log.csv -NoTypeInformation

    .EXAMPLE
    Remove-UnifiedGroupAddress -Domains 'wingtip.com|fabrikam.com|widget.com' | Export-Csv c:\scripts\log.csv -NoTypeInformation

    .NOTES
    Connect to Exchange Online Version 2
    Connect-CloudMFA -Tenant contoso -EXO2
    #>

    param (

        [Parameter(Mandatory)]
        $Domains
    )
    end {
        $EA = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        $RemoveList = Get-UnifiedGroup -ResultSize Unlimited | Select-Object @(
            'DisplayName'
            'PrimarySmtpAddress'
            'UserPrincipalName'
            @{
                Name       = 'EmailList'
                Expression = {
                    $_.emailaddresses | Where-Object {
                        @($_ -match ([Regex]::Escape($Domains)))
                    }
                }
            }
            'ExchangeGuid'
            'Guid'
        )
        $RemoveList = $RemoveList.Where{ $_.EmailList }
        foreach ($Remove in $RemoveList) {
            try {
                Write-Host "$($Remove.DisplayName)" -ForegroundColor White
                Get-UnifiedGroup -Identity $Remove.Identity | Set-UnifiedGroup -EmailAddresses @{Remove = @($Remove.EmailList) }
                Write-Host "$($Remove.DisplayName) Removed" -ForegroundColor Green
                [PSCustomObject]@{
                    Action             = "REMOVEEMAILS"
                    DisplayName        = $Remove.DisplayName
                    PrimarySmtpAddress = $Remove.PrimarySmtpAddress
                    UserPrincipalName  = $Remove.UserPrincipalName
                    Guid               = $Remove.Guid
                    Result             = "SUCCESS"
                    Log                = "SUCCESS"
                    Remove             = @($Remove.EmailList -ne '' -Join '|')
                }
            }
            catch {
                Write-Host "$($Remove.DisplayName) $($_.Exception.Message)" -ForegroundColor Red
                [PSCustomObject]@{
                    Action             = "REMOVEEMAILS"
                    DisplayName        = $Remove.DisplayName
                    PrimarySmtpAddress = $Remove.PrimarySmtpAddress
                    UserPrincipalName  = $Remove.UserPrincipalName
                    Guid               = $Remove.Guid
                    Result             = "FAILED"
                    Log                = $_.Exception.Message
                    Remove             = @($Remove.EmailList -ne '' -Join '|')
                }
            }
        }
        $ErrorActionPreference = $EA
    }
}
