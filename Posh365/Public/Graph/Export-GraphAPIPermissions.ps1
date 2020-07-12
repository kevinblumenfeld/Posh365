function Export-GraphAPIPermissions {
    param (
        [Parameter(Mandatory)]
        $Name,

        [Parameter(Mandatory)]
        [ValidateSet('Microsoft Graph', 'Windows Azure Active Directory, Exchange, Power BI Service')]
        $ServicePrincipalName

    )

    $Tenant = Get-AzureADTenantDetail
    $PoshPath = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Posh365'
    $GraphPath = Join-Path $PoshPath -ChildPath 'GraphApps'
    $TenantPath = Join-Path $GraphPath -ChildPath $Tenant.DisplayName

    if (-not (Test-Path $TenantPath)) {
        $null = New-Item -ItemType Directory -Path $PoshPath -ErrorAction SilentlyContinue
        $null = New-Item -ItemType Directory -Path $GraphPath -ErrorAction SilentlyContinue
        $null = New-Item -ItemType Directory -Path $TenantPath -ErrorAction SilentlyContinue
    }

    $SourceApp = Get-AzureADApplication -filter "DisplayName eq '$Name'"
    $ServicePrincipal = Get-AzureADServicePrincipal -filter "DisplayName eq '$ServicePrincipalName'"

    if (-not $SourceApp) {
        Write-Host "Azure AD Application Name: $Name was not found " -ForegroundColor Red
        continue
    }
    while (@($SourceApp).count -ne 1 -and @($AppChoice).count -ne 1) {
        $AppObject = foreach ($App in $SourceApp) {
            if ($SecretDate = ($App | Get-AzureADApplicationPasswordCredential).startdate) { $OldestSecret = ($SecretDate | Sort-Object )[0] }
            else { $OldestSecret = 'No Client Secret' }
            [PSCustomObject]@{
                Name         = $App.DisplayName
                ObjectId     = $App.objectid
                AppId        = $App.AppId
                OldestSecret = $OldestSecret
            }
        }
        $AppChoice = $AppObject | Out-GridView -OutputMode Single -Title "Duplicate named apps - Please choose which app to export."
    }
    if ($AppChoice) { $SourceApp = Get-AzureADApplication -filter "DisplayName eq '$AppChoice.Name'" }

    $ResourceList = $SourceApp.RequiredResourceAccess.ResourceAccess
    $Hash = @{
        'ResourceList'         = [System.Collections.Generic.List[psobject]]
        'ServicePrincipal'     = $ServicePrincipal
        'ServicePrincipalName' = $ServicePrincipalName
    }
    $RLObj = foreach ($Resource in $ResourceList) {
        [PSCustomObject]@{
            Id   = $Resource.Id
            Type = $Resource.Type
        }
    }
    $Hash['ResourceList'] = $RLObj

    $RequiredObject = [Microsoft.Open.AzureAD.Model.RequiredResourceAccess]::new()
    $AccessObject = [System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]]::new()

    foreach ($Resource in $ResourceList) {
        $AccessObject.Add([Microsoft.Open.AzureAD.Model.ResourceAccess]@{
                Id   = $Resource.Id
                Type = $Resource.Type
            })
    }

    $RequiredObject.ResourceAppId = $ServicePrincipal.AppId
    $RequiredObject.ResourceAccess = $AccessObject

    $XMLPath = (Join-Path -Path $TenantPath -ChildPath ('{0}-{1}.xml' -f $Name, $SourceApp.objectid.split('-')[4]) )
    $Hash | Export-Clixml $XMLPath -Force
    Write-Host "Graph app, $Name, API permissions exported to:" -ForegroundColor Cyan
    $XMLPath
}
