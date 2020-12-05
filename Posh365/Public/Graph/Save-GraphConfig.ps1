function Save-GraphConfig {
    # CAN DELETE
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter()]
        [string]
        $TenantId,

        [Parameter()]
        [string]
        $ApplicationId,

        [Parameter()]
        [string]
        $Secret,

        [Parameter()]
        [string]
        $App,

        [Parameter()]
        [switch]
        $PromptForDelegatedCredentials
    )
    if ($App) { $Tenant = '{0}-{1}' -f $Tenant, $App }
    $PoshPath = Join-Path -Path $Env:USERPROFILE -ChildPath '.Posh365/Credentials/Graph'
    $ItemSplat = @{
        Type        = 'Directory'
        Force       = $true
        ErrorAction = 'SilentlyContinue'
    }
    if (-not (Test-Path $PoshPath)) { New-Item $PoshPath @ItemSplat }
    $TenantPath = Join-Path -Path $PoshPath -ChildPath $Tenant
    if (-not (Test-Path $TenantPath)) { $null = New-Item $TenantPath @ItemSplat }

    try {
        if ($Secret) {
            $TenantSecret = $Secret | ConvertTo-SecureString -AsPlainText -Force
            $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Tenant)
            [PSCustomObject]@{
                Cred     = [PSCredential]::new($TenantId, $TenantSecret)
                ClientId = $ApplicationId
            } | Export-Clixml -Path $TenantConfig
        }
    }
    catch { Write-Host "Unable to export application credentials $($Exception.Message)" -ForegroundColor Red }
    try {
        if ($PromptForDelegatedCredentials) {
            $TenantCred = Join-Path -Path $TenantPath -ChildPath ('{0}Cred.xml' -f $Tenant)
            Get-Credential -Message "Type your administrator username and password" | Export-Clixml -Path $TenantCred
        }
    }
    catch { Write-Host "Unable to export delegated credentials $($Exception.Message)" -ForegroundColor Red }
}
