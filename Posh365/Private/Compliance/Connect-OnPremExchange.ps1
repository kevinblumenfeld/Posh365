function Connect-OnPremExchange {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Server,

        [Parameter()]
        [switch]
        $Basic
    )
    [System.Management.Automation.PSCredential]$Credential = Get-Credential -Message 'Enter on-premises Exchange username and password'
    if (-not $Basic) {
        $SessionSplat = @{
            Name              = "OnPremExchange"
            ConfigurationName = 'Microsoft.Exchange'
            ConnectionUri     = 'http://{0}/PowerShell/' -f $Server
            Authentication    = 'Kerberos'
            Credential        = $Credential
        }
    }
    else {
        $SessionSplat = @{
            Name              = "OnPremExchange"
            ConfigurationName = 'Microsoft.Exchange'
            ConnectionUri     = 'http://{0}/PowerShell/' -f $Server
            Authentication    = 'Basic'
            Credential        = $Credential
            AllowRedirection  = $true
        }
    }
    write-host "Server: $Server" -ForegroundColor Yellow
    $Session = New-PSSession @SessionSplat
    $SessionModule = Import-PSSession -AllowClobber -DisableNameChecking -Session $Session
    $null = Import-Module $SessionModule -Global -DisableNameChecking -Force
    Set-ADServerSettings -ViewEntireForest:$True
    Write-Host "Connected to Exchange Server: $Server" -ForegroundColor Green
}
