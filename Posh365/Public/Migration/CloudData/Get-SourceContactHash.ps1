function Get-SourceContactHash {
    [CmdletBinding()]
    param (

    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath 'Posh365' )
    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }

    $ContactXML = Join-Path -Path $PoshPath -ChildPath 'SourceContact.xml'
    if (-not (Test-Path $ContactXML)) {
        Write-Host "XML ($ContactXML) needed was not found.  Creating now . . . " -ForegroundColor White
        Get-MailContact -ResultSize Unlimited | Select-Object * | Export-Clixml -Path $ContactXML
    }
    else {
        Write-Host "Found the XML created earlier here: ($ContactXML) . . . " -ForegroundColor Green
    }

    Write-Host "Using the XML to create a hashtable . . . " -ForegroundColor White
    $ContactList = Import-Clixml $ContactXML
    $Hash = @{ }
    foreach ($Contact in $ContactList) {
        $Hash[($Contact.ExternalEmailAddress).Split(':')[1]] = @{
            LegacyExchangeDN = 'X500:{0}' -f $Contact.LegacyExchangeDN
            DisplayName      = $Contact.DisplayName
            Name             = $Contact.Name
            X500             = @($Contact.EmailAddresses) -match 'x500:' -join '|'
        }
    }
    $OutputXml = Join-Path -Path $PoshPath -ChildPath 'SourceContactHash.xml'
    $Hash | Export-Clixml $OutputXml
    Write-Host "Hash has been exported as an XML file here: " -ForegroundColor Cyan -NoNewline
    Write-Host "$OutputXml" -ForegroundColor Green
}
