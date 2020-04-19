function Convert-ContactsToHash {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $MailContactXML
    )

    $ContactList = Import-Clixml $MailContactXML
    $Hash = @{ }
    foreach ($Contact in $ContactList) {
        $Hash[$Contact.PrimarySmtpAddress] = 'X500:{0}' -f $Contact.LegacyExchangeDN
    }
    $OutputXml = Join-Path -Path (Split-Path $MailContactXML) -ChildPath 'PrimarySmtpToX500Hash.xml'
    Write-Host "Hash has been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$OutputXml" -ForegroundColor Green
    $Hash | Export-Clixml $OutputXml
}
