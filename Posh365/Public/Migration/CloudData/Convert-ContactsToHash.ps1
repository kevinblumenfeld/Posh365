function Convert-ContactsToHash {
    [CmdletBinding()]
    param (

        [Parameter()]
        $ContactXML
    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath 'Posh365' )

    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    if (-not $ContactXML) {
        $ContactXML = Join-Path -Path $PoshPath -ChildPath 'Contact.xml'
        Get-MailContact -ResultSize Unlimited | Select-Object * | Export-Clixml -Path $ContactXML
    }

    $ContactList = Import-Clixml $ContactXML
    $Hash = @{ }
    foreach ($Contact in $ContactList) {
        $Hash[($Contact.ExternalEmailAddress).Split(':')[1]] = @{
            X500        = 'X500:{0}' -f $Contact.LegacyExchangeDN
            DisplayName = $Contact.DisplayName
            Name        = $Contact.Name
        }
    }
    $OutputXml = Join-Path -Path $PoshPath -ChildPath 'ContactHash_ExternalToX500.xml'
    $Hash | Export-Clixml $OutputXml
    Write-Host "Hash has been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$OutputXml" -ForegroundColor Green
}
