using namespace System.Management.Automation.Host
function Get-SourceContactHash {
    [CmdletBinding()]
    param (

    )
    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $ContactXML = Join-Path -Path $PoshPath -ChildPath ('SourceContact_{0}.xml' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))

    $Script:RestartConsole = $null
    Connect-CloudModuleImport -EXO2
    if ($RestartConsole) { return }
    $Accepted = $null
    Get-PSSession | Remove-PSSession
    Connect-ExchangeOnline

    $Accepted = Get-AcceptedDomain
    $Yes = [ChoiceDescription]::new('&Yes', 'Connect: Yes')
    $No = [ChoiceDescription]::new('&No', 'Connect: No')
    $Question = 'Is this the correct Exchange Online Tenant {0}?' -f ($Accepted.where{ $_.Default }).DomainName
    $Options = [ChoiceDescription[]]($Yes, $No)
    $YN = $host.ui.PromptForChoice($Title, $Question, $Options, 0)
    switch ($YN) {
        0 { }
        1 { return }
    }
    Get-MailContact -ResultSize Unlimited | Select-Object * | Export-Clixml -Path $ContactXML

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
