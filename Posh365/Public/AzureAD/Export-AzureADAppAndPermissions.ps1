function Export-AzureADAppAndPermissions {
    <#
    .SYNOPSIS
    Export Azure AD App name & API permissions to an xml

    .DESCRIPTION
    Export Azure AD App name & API permissions to an xml

    .PARAMETER Name
    Azure AD Application you wish to export

    .PARAMETER ServicePrincipalName
    Microsoft Service Principals. Tested with the Service Principal 'Microsoft Graph'

    .EXAMPLE
    Export-GraphAPIPermissions -Name 'TestApp' -ServicePrincipalName 'Microsoft Graph'

    .NOTES
    Output from this function will look like this:

    AzureAD App and API Permissions for TestApp, exported to:
    C:\Users\kevin.blumenfeld\Desktop\Posh365\GraphApps\kevdev\TestApp-20200712-0757.xml

    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        $Name
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
    # $ServicePrincipal = Get-AzureADServicePrincipal -filter "DisplayName eq '$ServicePrincipalName'"

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

    $App = @{
        DisplayName = $SourceApp.DisplayName
        SourceApp   = $SourceApp
        API         = @{ }
    }
    $AccessList = $SourceApp.RequiredResourceAccess
    foreach ($Access in $AccessList) {
        $ResourceList = $Access.ResourceAccess
        $App['API'][$Access.ResourceAppId] = @{
            ResourceList = [System.Collections.Generic.List[psobject]]
        }
        $RLObj = foreach ($Resource in $ResourceList) {
            [PSCustomObject]@{
                Id   = $Resource.Id
                Type = $Resource.Type
            }
        }
        $App['API'][$Access.ResourceAppId]['ResourceList'] = $RLObj
    }

    $XMLPath = (Join-Path -Path $TenantPath -ChildPath ('{0}-{1}.xml' -f $Name, [DateTime]::Now.ToString('yyyyMMdd-hhmm')) )
    $App | Export-Clixml $XMLPath -Force
    Write-Host "AzureAD App and API Permissions for TestApp $Name, exported to:" -ForegroundColor Cyan
    $XMLPath
}
