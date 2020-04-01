function Invoke-NewCloudData {

    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $Path
    )

    Get-PSSession | Remove-PSSession
    Connect-ExchangeOnline
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName

    if ($InitialDomain) {
        $Yes = [ChoiceDescription]::new('&Yes', 'Import Data: Yes')
        $No = [ChoiceDescription]::new('&No', 'Import Data: No')
        $Question = 'Import the data into this tenant ---> {0} ?' -f $InitialDomain
        $Options = [ChoiceDescription[]]($Yes, $No)
        $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

        switch ($Menu) {
            0 { }
            1 { break }
        }
    }
    else {
        Write-Host 'Not connected to Exchange Online' -ForegroundColor Red
        break
    }
    $ImportList = Import-Csv -Path $Path
    foreach ($Import in $ImportList) {
        $GeneratedPW = [System.Web.Security.Membership]::GeneratePassword(16, 7)
        try {
            $NewMEUParams = @{
                Name                      = $NewName
                DisplayName               = $DisplayName
                MicrosoftOnlineServicesID = $dbUPN
                Password                  = ConvertTo-SecureString -String $GeneratedPW -AsPlainText:$true -Force
                PrimarySMTPAddress        = $dbRFA
                ExternalEmailAddress      = $dbRFA
                ErrorAction               = 'Stop'
            }
            $null = New-MailUser @NewMEUParams
            [PSCustomObject]@{

                Log = "Success"
            }
        }
        catch {
            [PSCustomObject]@{

                Log = $_.Exception.Message
            }
        }
    }
}
