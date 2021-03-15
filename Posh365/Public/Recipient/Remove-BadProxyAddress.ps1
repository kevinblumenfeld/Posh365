function Remove-BadProxyAddress {
    <#
    .SYNOPSIS

    This function needs to be tested prior to running in production.  This can delete a ton of addresses!!!

    Remove Proxy Addresses from Mailboxes, Groups, and Contacts from Exchange

    .DESCRIPTION
    Remove Proxy Addresses from Mailboxes, Groups, and Contacts from Exchange


    .PARAMETER CsvPath
    choose a path to an excel document with headers and content like this:

    DisplayName,	RecipientTypeDetails,	Protocol,	Domain, 	PrefixedAddress,	PrimarySmtpAddress
    Jane Klien, 	UserMailbox,	 smtp, 	AD.contoso.com,	smtp:jk@AD.contoso.com, jk@contoso.com

    This data can be found by running

    Get-DiscoveryOnPrem -Verbose

    then use the Ex_RecipientEmails tab for this data

    .EXAMPLE

    Remove-BadProxyAddress -CsvPath c:\scripts\badproxies.csv | Export-Csv c:\scripts\Results.csv -NoTypeInformation -Append

    .NOTES

    To create the trimmed list from the Ex_RecipientEmails tab data:

    $RecList = Import-Csv C:\Scripts\Ex_RecipientEmails.csv

    $trimmed = foreach ($Rec in $RecList) {

        if ($Rec.Domain -match 'fabrikam.com|AD.contoso.com' -or ($Rec.Protocol -eq 'gwise')) {
            $Rec | Select-Object *
        }
    }

    $trimmed | Export-Csv c:\scripts\BadProxies.csv -notypeinformation

    #>

    [CmdletBinding()]

    param (
        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        [string]
        $CsvPath
    )

    $RemoveList = Import-Csv $CsvPath

    foreach ($Remove in $RemoveList) {

        Write-Host ('{0} - {1} - ' -f $Remove.DisplayName, $Remove.RecipientTypeDetails) -ForegroundColor White -NoNewline

        if ($Remove.RecipientTypeDetails -like '*Mailbox') {

            try {

                Set-Mailbox -Identity $Remove.PrimarySmtpAddress -EmailAddresses @{remove = '{0}' -f $Remove.PrefixedAddress } -erroraction stop

                Write-Host  ('{0}' -f $Remove.PrefixedAddress) -ForegroundColor Green

                [PSCustomObject]@{
                    DisplayName          = $Remove.DisplayName
                    RecipientTypeDetails = $Remove.RecipientTypeDetails
                    PrefixedAddress      = $Remove.PrefixedAddress
                    Result               = 'SUCCESS'
                    Log                  = 'SUCCESS'
                }
            }
            catch {

                Write-Host  ('{0} - FAILED !' -f $Remove.PrefixedAddress) -ForegroundColor Red

                [PSCustomObject]@{
                    DisplayName          = $Remove.DisplayName
                    RecipientTypeDetails = $Remove.RecipientTypeDetails
                    PrefixedAddress      = $Remove.PrefixedAddress
                    Result               = 'FAILED'
                    Log                  = $_.Exception.Message
                }
            }
        }
        elseif ($Remove.RecipientTypeDetails -like '*Group*') {

            try {

                Set-DistributionGroup -Identity $Remove.PrimarySmtpAddress -EmailAddresses @{remove = '{0}' -f $Remove.PrefixedAddress } -erroraction stop

                Write-Host  ('{0}' -f $Remove.PrefixedAddress) -ForegroundColor Green

                [PSCustomObject]@{
                    DisplayName          = $Remove.DisplayName
                    RecipientTypeDetails = $Remove.RecipientTypeDetails
                    PrefixedAddress      = $Remove.PrefixedAddress
                    Result               = 'SUCCESS'
                    Log                  = 'SUCCESS'
                }
            }
            catch {
                Write-Host  ('{0} - FAILED !' -f $Remove.PrefixedAddress) -ForegroundColor Red

                [PSCustomObject]@{
                    DisplayName          = $Remove.DisplayName
                    RecipientTypeDetails = $Remove.RecipientTypeDetails
                    PrefixedAddress      = $Remove.PrefixedAddress
                    Result               = 'FAILED'
                    Log                  = $_.Exception.Message
                }
            }
        }
        elseif ($Remove.RecipientTypeDetails -eq 'MailContact') {

            try {

                Set-MailContact -Identity $Remove.PrimarySmtpAddress -EmailAddresses @{remove = '{0}' -f $Remove.PrefixedAddress } -erroraction stop

                Write-Host  ('{0}' -f $Remove.PrefixedAddress) -ForegroundColor Green

                [PSCustomObject]@{
                    DisplayName          = $Remove.DisplayName
                    RecipientTypeDetails = $Remove.RecipientTypeDetails
                    PrefixedAddress      = $Remove.PrefixedAddress
                    Result               = 'SUCCESS'
                    Log                  = 'SUCCESS'
                }
            }
            catch {
                Write-Host  ('{0} - FAILED !' -f $Remove.PrefixedAddress) -ForegroundColor Red

                [PSCustomObject]@{
                    DisplayName          = $Remove.DisplayName
                    RecipientTypeDetails = $Remove.RecipientTypeDetails
                    PrefixedAddress      = $Remove.PrefixedAddress
                    Result               = 'FAILED'
                    Log                  = $_.Exception.Message
                }
            }
        }
        else {
            Write-Host  ('{0} - We wont touch.' -f $Remove.RecipientTypeDetails) -ForegroundColor Yellow
        }
    }
}
