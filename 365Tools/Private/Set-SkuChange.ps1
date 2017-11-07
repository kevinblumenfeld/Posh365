function Set-SkuChange {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String[]] $skus,

        [Parameter(Mandatory = $false)]
        [String[]] $options,

        [Parameter(Mandatory = $false)]
        [switch] $add,

        [Parameter(Mandatory = $false)]
        [switch] $addAlready,
        
        [Parameter(Mandatory = $false)]
        [switch] $remove,        

        [Parameter(Mandatory = $false)]
        [switch] $addTheOptions,
        
        [Parameter(Mandatory = $false)]
        [switch] $removeTheOptions

    )
    $SkuFeaturesToEnable = @()
    $SkuFeaturesToDisable = @()
    $SkuOptsToDisable = @()
    $skuIdHash = @{}
    Get-AzureADSubscribedSku | Select SkuPartNumber, SkuId | ForEach-Object {
        $skuIdHash[$_.SkuPartNumber] = $_.SkuId
    }
    # Remove Sku
    if ($remove) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $license = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $skuIdHash.$sku
            $licensesToAssign.AddLicenses = @()
            $licensesToAssign.RemoveLicenses += $license.SkuId
        }
    }
    # Adding Sku to a user that does not have the Sku
    if ($add) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $license = New-Object Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $skuIdHash.$sku
            $licensesToAssign.AddLicenses += $license
        }
    }
    # Adding Sku to a user that already has the Sku (possibly partial or full)
    if ($addAlready) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $StandardLicense = Get-AzureADSubscribedSku | Where {$_.SkuId -eq $skuIdHash.$sku}
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $StandardLicense.SkuId
            $licensesToAssign.AddLicenses += $license
        }
    }
    # Add Option(s).  Adds Sku if user has yet to be unassigned it
    if ($addTheOptions) {
        foreach ($sku in $skus) {
            $SkuFeaturesToEnable = $options
            $StandardLicense = Get-AzureADSubscribedSku | Where {$_.SkuId -eq $skuIdHash.$sku}
            $SkuFeaturesToDisable = $StandardLicense.ServicePlans | ForEach-Object { $_ | Where {$_.ServicePlanName -notin $SkuFeaturesToEnable }}
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $StandardLicense.SkuId
            $license.DisabledPlans = $SkuFeaturesToDisable.ServicePlanId
            $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
            $licensesToAssign.AddLicenses += $license
            $licensesToAssign.RemoveLicenses = @()
        }
    }
    # Remove Option(s) only if user has the appropriate Sku assigned
    if ($removeTheOptions) {
        $licensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        foreach ($sku in $skus) {
            $SkuOptsToDisable = $options
            $StandardLicense = Get-AzureADSubscribedSku | Where {$_.SkuId -eq $skuIdHash.$sku}
            $SkuFeaturesToDisable = $StandardLicense.ServicePlans | ForEach-Object { $_ | Where {$_.ServicePlanName -in $SkuOptsToDisable }}
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $License.DisabledPlans = $SkuFeaturesToDisable.ServicePlanId
            $license.SkuId = $StandardLicense.SkuId
            $licensesToAssign.AddLicenses += $license
            $licensesToAssign.RemoveLicenses = @()
        }
    }
    $licensesToAssign 
}