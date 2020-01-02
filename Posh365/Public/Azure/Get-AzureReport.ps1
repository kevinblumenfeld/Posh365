function Get-DiscoveryAzure {
    param (
        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter(Mandatory)]
        [string] $ReportPath,

        [Parameter()]
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

        $SubId = $CurSub.Id
        $SubName = $CurSub.Name

        if ($CurSub.State -ne "Disabled") {
            Get-AzureInventory -SubId $SubId -SubName $SubName -ReportPath $TenantPath
        }
    }
    if (-not $SaveContext) {
        Get-AzureRmContext | Remove-AzureRmContext
    }
}
