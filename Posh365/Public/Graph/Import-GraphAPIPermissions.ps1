function Import-GraphAPIPermissions {
    param (
        [Parameter()]
        [mailaddress]
        $Owner,

        [Parameter()]
        [string]
        [ValidateScript( { Test-Path $_ })]
        $XMLPath,

        [Parameter(Mandatory)]
        [ValidateSet('None', 1, 2)]
        $SecretDuration,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $OpenConsentInBrowser
    )

    $AppOwner = Get-AzureADUser -ObjectId $Owner -ErrorAction SilentlyContinue
    if (-not ($AppOwner)) {
        Write-Host "Owner $Owner, not found. Halting script" -ForegroundColor Red
        continue
    }
    $ExistingApp = Get-AzureADApplication -filter "DisplayName eq '$Name'"
    if ($ExistingApp) {
        Write-Host "Azure AD Application Name: $Name already exists" -ForegroundColor Red
        Write-Host "Choose a name with the -Name parameter" -ForegroundColor Cyan
        continue
    }
    $Leaf = Get-Item -path $XMLPath
    if (-not $Name) { $Name = $Leaf.BaseName }

    $TargetApp = New-AzureADApplication -DisplayName $Name -ReplyUrls 'https://portal.azure.com/'
    $Hash = Import-Clixml $XMLPath

    $RequiredObject = [Microsoft.Open.AzureAD.Model.RequiredResourceAccess]::new()
    $AccessObject = [System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]]::new()

    $ResourceList = $Hash['ResourceList']
    foreach ($Resource in $ResourceList) {
        $AccessObject.Add([Microsoft.Open.AzureAD.Model.ResourceAccess]@{
                Id   = $Resource.Id
                Type = $Resource.Type
            })
    }

    $ServicePrincipal = Get-AzureADServicePrincipal -filter ("DisplayName eq '{0}'" -f $Hash['ServicePrincipalName'])
    $RequiredObject.ResourceAppId = $ServicePrincipal.AppId
    $RequiredObject.ResourceAccess = $AccessObject

    Set-AzureADApplication -ObjectId $TargetApp.ObjectId -RequiredResourceAccess $RequiredObject
    Add-AzureADApplicationOwner -ObjectId $TargetApp.ObjectId -RefObjectId $AppOwner.ObjectId
    if ($SecretDuration -ne 'None') {
        $Date = Get-Date
        $Params = @{
            ObjectId            = $TargetApp.ObjectId
            EndDate             = $Date.AddYears($SecretDuration)
            CustomKeyIdentifier = "{0}-{1}" -f $TargetApp.name, $Date.ToString("yyyyMMddTHHmm")
        }
        New-AzureADApplicationPasswordCredential @Params
    }
    $Tenant = Get-AzureADTenantDetail
    Write-Host "Grant Admin Consent by logging in as $Owner here:" -ForegroundColor Cyan
    $ConsentURL = 'https://login.microsoftonline.com/{0}/v2.0/adminconsent?client_id={1}&state=12345&redirect_uri={2}&scope={3}&prompt=admin_consent' -f @(
        $Tenant.ObjectID, $Target.AppId, 'https://portal.azure.com/', 'https://graph.microsoft.com/.default')
    Write-Host $ConsentURL -ForegroundColor White
    if ($OpenConsentInBrowser) { Start $ConsentURL }
}
