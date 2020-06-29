function Connect-OnPremExchange {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Server
    )
    $SessionSplat = @{
        Name              = $Server
        ConfigurationName = 'Microsoft.Exchange'
        ConnectionUri     = 'http://{0}/PowerShell/' -f $Server
        Authentication    = 'Kerberos'
        Credential        = $Credential
    }
    write-host "Server: $Server" -ForegroundColor Yellow
    $Session = New-PSSession @SessionSplat
    $SessionModule = Import-PSSession -AllowClobber -DisableNameChecking -Session $Session
    $null = Import-Module $SessionModule -Global -DisableNameChecking -Force
    Set-ADServerSettings -ViewEntireForest:$True
    Write-Host "Connected to Exchange Server: $Server" -ForegroundColor Green
}