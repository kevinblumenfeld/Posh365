function Get-AzureReport {
    param (
        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(Mandatory)]
        [string] $ReportPath,

        [Parameter(Mandatory)]
        [switch] $SkipLogin,

        [Parameter()]
        [switch] $SaveContext
    )


    $TenantPath = Join-Path $ReportPath $Tenant
    if (-not (Test-Path $TenantPath)) {
        New-Item -Path $TenantPath -ItemType Directory -Force > $null
    }

    if (-not $SkipLogin) {
        Login-AzureRmAccount
    }

    $Sub = Get-AzureRmSubscription

    foreach ($CurSub in $Sub) {

        $SubID = $CurSub.id

        if ($CurSub.State -ne "Disabled") {
            Get-AzureInventory -SubID $SubID -ReportPath $TenantPath
        }
    }
    if (-not $SaveContext) {
        Get-AzureRmContext  | Remove-AzureRmContext
    }
}