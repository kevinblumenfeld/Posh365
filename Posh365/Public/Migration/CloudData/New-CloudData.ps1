using namespace System.Management.Automation.Host
function New-CloudData {

    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $FilePath,

        [Parameter()]
        $SourceData
    )

    try {
        $InitialDomain = ((Get-AcceptedDomain -ErrorAction Stop).where{ $_.InitialDomain }).DomainName
        Write-Host ('{0}Currently connected to Exchange Online: ' -f [Environment]::NewLine) -ForegroundColor Cyan -NoNewline
        Write-Host ('{0}' -f $InitialDomain) -ForegroundColor Green
    }
    catch {
        Write-Host 'Not Connected to Exchange Online' -ForegroundColor Yellow
    }
    try {
        $AzDomain = ((Get-AzureADDomain -ErrorAction Stop).where{ $_.IsInitial }).Name
        Write-Host 'Currently connected to AzureAD: ' -ForegroundColor Cyan -NoNewline
        Write-Host ('{0}' -f $AzDomain) -ForegroundColor Green
    }
    catch {
        Write-Host 'Not Connected to AzureAD' -ForegroundColor Yellow
    }
    if (-not $SourceData) {
        $SourceData = Import-Csv -Path $FilePath
    }
    $Yes = [ChoiceDescription]::new('&Yes', 'Connect: Yes')
    $No = [ChoiceDescription]::new('&No', 'Connect: No')
    $Question = 'Connect to Exchange Online and AzureAD?'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $ConnectMenu = $host.ui.PromptForChoice($Title, $Question, $Options, 0)

    switch ($ConnectMenu) {
        0 {
            Get-PSSession | Remove-PSSession
            try { Disconnect-AzureAD -ErrorAction Stop } catch { }
            Connect-ExchangeOnline
            $null = Connect-AzureAD
        }
        1 {  }
    }
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
    $AzADDomain = ((Get-AzureADDomain).where{ $_.IsInitial }).Name
    if ($InitialDomain -ne $AzADDomain) {
        Write-Host "Halting script: $InitialDomain does not match $AzADDomain" -ForegroundColor Red
        return
    }
    if ($InitialDomain) {
        $Yes = [ChoiceDescription]::new('&Yes', 'Source Domain: Yes')
        $No = [ChoiceDescription]::new('&No', 'Source Domain: No')
        $Question = 'Is this the destination tenant {0}?' -f $InitialDomain
        $Options = [ChoiceDescription[]]($Yes, $No)
        $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

        switch ($Menu) {
            0 { }
            1 { return }
        }
    }
    else {
        Write-Host 'Not connected to Exchange Online' -ForegroundColor Red
        return
    }
    Invoke-NewCloudData -ConvertedData $SourceData
}
