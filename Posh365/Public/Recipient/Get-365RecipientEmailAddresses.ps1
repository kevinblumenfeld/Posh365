function Get-365RecipientEmailAddresses {
    <#
    .SYNOPSIS
    Export Office 365 Recipients Email Addresses

    .DESCRIPTION
    Export Office 365 Recipients Email Addresses one per line

    .PARAMETER SpecificRecipients
    Provide specific Recipients to report on.  Otherwise, all Recipients will be reported.  Please review the examples provided.

    .EXAMPLE
    Get-365RecipientEmailAddresses | Export-Csv c:\scripts\All365RecipientEmails.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{UserPrincipalName -like "*contoso.com" -or
        emailaddresses -like "*contoso.com" -or
        ExternalEmailAddress -like "*contoso.com" -or
        PrimarySmtpAddress -like "*contoso.com"}' | Get-365RecipientEmailAddresses | Export-Csv .\RecipientReport.csv -notypeinformation -encoding UTF8
    .EXAMPLE


    #>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $RecipientFilter
    )
    Begin {
        $Selectproperties = @(
            'RecipientTypeDetails', 'DisplayName', 'Alias', 'Identity', 'PrimarySmtpAddress'
        )

        $CalculatedProps = @(
            @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join '|' }}
        )
    }
    Process {
        if ($RecipientFilter) {
            foreach ($CurRecipientFilter in $RecipientFilter) {
                Get-Recipient -Filter $CurRecipientFilter | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-Recipient -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps) | ForEach-Object {

                $DisplayName = $_.DisplayName
                $Identity = $_.Identity
                $Alias = $_.Alias
                $PrimarySmtpAddress = $_.PrimarySmtpAddress
                $RecipientTypeDetails = $_.RecipientTypeDetails

                $_.EmailAddresses -split [regex]::Escape('|') | ForEach-Object {
                    [PSCustomObject]@{
                        DisplayName          = $DisplayName
                        Identity             = $Identity
                        Alias                = $Alias
                        PrimarySmtpAddress   = $PrimarySmtpAddress
                        RecipientTypeDetails = $RecipientTypeDetails
                        EmailAddress         = $_
                    }
                }
            }
        }
    }
    End {

    }
}