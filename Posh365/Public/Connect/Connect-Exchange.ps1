using namespace System.Management.Automation.Host
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
        [switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [switch]
        $DontViewEntireForest,

        [Parameter()]
        [switch]
        $PromptConfirm
    )

    $CredFile = Join-Path $Env:USERPROFILE ConnectExchange.xml
    if ($DeleteExchangeCreds) {
        if (Test-Path $CredFile) {
            Write-Host "Deleting encrypted credential file: $Credfile"
            Remove-Item $CredFile -Force -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "No Credential file found to be deleted: Not found=> $CredFile"
        }
        
        return
    }
    if ($PromptConfirm) {
        while (-not $Server ) {
            Write-Host "Enter the name of the Exchange Server. Example: ExServer01.domain.com" -ForegroundColor Cyan
            $Server = Read-Host "Exchange Server Name"
        }
        while (-not $ConfirmExServer) {
            $Yes = [ChoiceDescription]::new('&Yes', 'ExServer: Yes')
            $No = [ChoiceDescription]::new('&No', 'ExServer: No')
            $Options = [ChoiceDescription[]]($Yes, $No)
            $Title = 'Specified Exchange Server: {0}' -f $Server
            $Question = 'Is this correct?'
            $YN = $host.ui.PromptForChoice($Title, $Question, $Options, 1)
            switch ($YN) {
                0 { $ConfirmExServer = $true }
                1 {
                    Write-Host "`r`nEnter the name of the Exchange Server. Example: ExServer01.domain.com" -ForegroundColor Cyan
                    $Server = Read-Host "Exchange Server Name"
                }
            }
        }
    }
    if (-not ($null = Test-Path $CredFile)) {
        [System.Management.Automation.PSCredential]$Credential = Get-Credential -Message 'Enter on-premises Exchange username and password'
        [System.Management.Automation.PSCredential]$Credential | Export-Clixml -Path $CredFile
        [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
    }
    else {
        [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
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
