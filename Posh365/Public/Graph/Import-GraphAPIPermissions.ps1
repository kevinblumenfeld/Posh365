function Import-GraphAPIPermissions {
    [cmdletbinding(DefaultParameterSetName = 'PlaceHolder')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'FileSystem')]
        [Parameter(Mandatory, ParameterSetName = 'GIST')]
        [mailaddress]
        $Owner,

        [Parameter(Mandatory, ParameterSetName = 'FileSystem')]
        [string]
        [ValidateScript( { Test-Path $_ })]
        $XMLPath,

        [Parameter(Mandatory, ParameterSetName = 'GIST')]
        [string]
        $GithubUsername,

        [Parameter(Mandatory, ParameterSetName = 'GIST')]
        [string]
        $GistFilename,

        [Parameter(ParameterSetName = 'FileSystem')]
        [Parameter(ParameterSetName = 'GIST')]
        [ValidateSet('None', 1, 2)]
        $SecretDuration,

        [Parameter(Mandatory, ParameterSetName = 'FileSystem')]
        [Parameter(Mandatory, ParameterSetName = 'GIST')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'FileSystem')]
        [Parameter(Mandatory, ParameterSetName = 'GIST')]
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

    if ($PSCmdlet.ParameterSetName -eq 'FileSystem') {
        $Leaf = Get-Item -path $XMLPath -ErrorAction SilentlyContinue
        if (-not $Name) { $Name = $Leaf.BaseName }
        $Hash = Import-Clixml $XMLPath
    }
    else {
        try {
            $Tempfilepath = Join-Path -Path $Env:TEMP -ChildPath ('{0}.xml' -f [guid]::newguid().guid)
            (Get-GitHubGist -Username $GithubUserName -Filename $GistFilename).content | Set-Content -Path $Tempfilepath -ErrorAction Stop
            $Hash = Import-Clixml $Tempfilepath
        }
        catch {
            Write-Host "Error importing GIST $($_.Exception.Message)" -ForegroundColor Red
            continue
        }
        finally {
            Remove-Item -Path $Tempfilepath -Force -Confirm:$false -ErrorAction SilentlyContinue
        }

    }
    $TargetApp = New-AzureADApplication -DisplayName $Name -ReplyUrls 'https://portal.azure.com/'

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
            CustomKeyIdentifier = "{0}-{1}" -f $TargetApp.Displayname, $Date.ToString("yyyyMMddTHHmm")
        }
        New-AzureADApplicationPasswordCredential @Params
    }
    $Tenant = Get-AzureADTenantDetail
    Write-Host "Grant Admin Consent by logging in as $Owner here:" -ForegroundColor Cyan
    $ConsentURL = 'https://login.microsoftonline.com/{0}/v2.0/adminconsent?client_id={1}&state=12345&redirect_uri={2}&scope={3}&prompt=admin_consent' -f @(
        $Tenant.ObjectID, $TargetApp.AppId, 'https://portal.azure.com/', 'https://graph.microsoft.com/.default')
    Write-Host $ConsentURL -ForegroundColor White
    if ($OpenConsentInBrowser) { Start $ConsentURL }
}
