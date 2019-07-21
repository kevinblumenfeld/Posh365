function Connect-Exchange {

    <#
    .SYNOPSIS
    Connects to On-Premises Microsoft Exchange Server

    .DESCRIPTION
    Connects to On-Premises Microsoft Exchange Server

    .PARAMETER Server
    The Exchange Server name to connect to

    .PARAMETER DeleteExchangeCreds
    Deletes the saved/encrypted credentials, previously saved by this script.
    Helpful when incorrect credentials were entered previously.

    .PARAMETER DontViewEntireForest
    If select will not scope to entire forest

    .EXAMPLE
    Connect-Exchange -Server EXCH01

    #>

    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $Server,

        [Parameter()]
        [Switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [Switch]
        $DontViewEntireForest
    )

    $CredFile = Join-Path $Env:USERPROFILE ConnectExchange.xml
    if ($DeleteExchangeCreds) { Remove-Item $CredFile -Force }

    if (-not ($null = Test-Path $CredFile)) {
        [System.Management.Automation.PSCredential]$Credential = Get-Credential -Message 'Enter on-premises Exchange username and password'
        [System.Management.Automation.PSCredential]$Credential | Export-CliXml -Path $CredFile
        [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
    }
    else {
        [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
    }
    $SessionSplat = @{
        Name              = "OnPremExchange"
        ConfigurationName = 'Microsoft.Exchange'
        ConnectionUri     = ("http://" + $Server + "/PowerShell/")
        Authentication    = 'Kerberos'
        Credential        = $Credential
    }
    $Session = New-PSSession @SessionSplat
    $SessionModule = Import-PSSession -AllowClobber -DisableNameChecking -Session $Session
    $null = Import-Module $SessionModule -Global -DisableNameChecking -Force
    if (-not $DontViewEntireForest) {
        Set-ADServerSettings -ViewEntireForest:$True
    }
    Write-Host "Connected to Exchange Server: $Server" -ForegroundColor Green
}
