function Import-AzureADAppAndPermissions {
    <#
    .SYNOPSIS
    Import Azure AD App name & API permissions from filesystem or GIST-based xml

    .DESCRIPTION
    Import Azure AD App name & API permissions from filesystem or GIST-based xml

    .PARAMETER Owner
    The owner of the application. For convenience, should be the owner
    that can grant admin consent of the requested API permissions

    .PARAMETER XMLPath
    Filesystem path to the XML created by Export-AzureADAppAndPermissions
    Choose this or the Github paramters to grab the xml from a GIST

    .PARAMETER GithubUsername
    Github username where the GIST you wish to import lives

    .PARAMETER GistFilename
    filename of GIST, example: Test.xml
    This is the most recently created file named, Test.xml, for example.
    If there is more than one filename bypassed

    .PARAMETER SecretDuration
    How many years the secret should live.
    Current Options are 1, 2, and None
    1 year, 2 years or None (no secret created)

    .PARAMETER Name
    Name of the App to create in the target AzureAD tenant.
    If left blank, will use source tenant app name (plus timestamp of export)

    .PARAMETER OpenConsentInBrowser
    Will open the admin consent page where the admin can login to the
    target Azure AD tenant and "grant admin consent" for those APIs that require it

    .EXAMPLE
    Import-AzureADAppAndPermissions -Owner admin@thesourceonline.onmicrosoft.com -GithubUsername kevinblumenfeld `
                                    -GistFilename test.xml -Name NewApp09 -SecretDuration 1 -OpenConsentInBrowser

    .EXAMPLE
    Import-AzureADAppAndPermissions -Owner admin@thesourceonline.onmicrosoft.com `
                                    -XMLPath C:\Users\kevin\Desktop\Posh365\GraphApps\kevdev\TestApp-20200712-0757.xml`
                                    -Name NewApp01 -SecretDuration 1 -OpenConsentInBrowser

    .NOTES
    If SecretDuration is choosen the Secret will be include with the one object this function produces

    Example:

    ApplicationId : adecd1ee-abcd-4c66-bcf1-4bfb0b610818
    TenantId      : f8f6d77c-abcd-4a11-ae04-39bfaff70e00
    ObjectId      : c57f335d-abcd-492e-bc90-6cd1a85eecd6
    Secret        : pA00W2xLLabcdZLL5g8dS85HiXAjuI1UFKnwdsAlpAk=


    #>

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

        [Parameter(ParameterSetName = 'FileSystem')]
        [Parameter(ParameterSetName = 'GIST')]
        [Parameter(ParameterSetName = 'ConnectPoshGraph')]
        [switch]
        $ExportToConnectPoshGraphDelegated,

        [Parameter(ParameterSetName = 'FileSystem')]
        [Parameter(ParameterSetName = 'GIST')]
        [Parameter(ParameterSetName = 'ConnectPoshGraph')]
        [switch]
        $ExportToConnectPoshGraphApplication,

        [Parameter(ParameterSetName = 'FileSystem')]
        [Parameter(ParameterSetName = 'GIST')]
        [switch]
        $OpenConsentInBrowser
    )

    try {
        $AppOwner = Get-AzureADUser -ObjectId $Owner -ErrorAction Stop
        Write-Host "Owner $Owner, found" -ForegroundColor Green
    }
    catch {
        Write-Host "Owner $Owner, not found. Halting script" -ForegroundColor Red
    }
    try {
        $null = Get-AzureADApplication -filter "DisplayName eq '$Name'" -ErrorAction Stop
    }
    catch {
        Write-Host "Azure AD Application Name: $Name already exists" -ForegroundColor Red
        Write-Host "Choose a new name with the -Name parameter" -ForegroundColor Cyan
    }

    if ($PSCmdlet.ParameterSetName -eq 'FileSystem') { $App = Import-Clixml $XMLPath }
    else {
        try {
            $Tempfilepath = Join-Path -Path $Env:TEMP -ChildPath ('{0}.xml' -f [guid]::newguid().guid)
            (Get-GitHubGist -Username $GithubUserName -Filename $GistFilename)[0].content | Set-Content -Path $Tempfilepath -ErrorAction Stop
            $App = Import-Clixml $Tempfilepath
        }
        catch {
            Write-Host "Error importing GIST $($_.Exception.Message)" -ForegroundColor Red
            continue
        }
        finally {
            Remove-Item -Path $Tempfilepath -Force -Confirm:$false -ErrorAction SilentlyContinue
        }

    }
    $Tenant = Get-AzureADTenantDetail
    try {
        $NewAppSplat = @{
            DisplayName = $Name
            ReplyUrls   = $App['SourceApp'].ReplyUrls
            ErrorAction = 'Stop'
        }
        $TargetApp = New-AzureADApplication @NewAppSplat
    }
    catch {
        Write-Host "Unable to create new application:  $($_.Exception.Message)" -ForegroundColor Red
    }

    $Output = [ordered]@{ }
    $Output['DisplayName'] = $Name
    $Output['ApplicationId'] = $TargetApp.AppId
    $Output['TenantId'] = $Tenant.ObjectID
    $Output['ObjectId'] = $TargetApp.ObjectId
    $Output['Owner'] = $Owner

    $RequiredList = [System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.RequiredResourceAccess]]::new()
    foreach ($ResourceAppId in $App['API'].keys) {
        $RequiredObject = [Microsoft.Open.AzureAD.Model.RequiredResourceAccess]::new()
        $AccessObject = [System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]]::new()
        foreach ($ResourceAccess in $App['API'][$ResourceAppId]['ResourceList']) {
            $AccessObject.Add([Microsoft.Open.AzureAD.Model.ResourceAccess]@{
                    Id   = $ResourceAccess.Id
                    Type = $ResourceAccess.Type
                })
        }
        $RequiredObject.ResourceAppId = $ResourceAppId
        $RequiredObject.ResourceAccess = $AccessObject
        $RequiredList.Add($RequiredObject)
    }
    Set-AzureADApplication -ObjectId $TargetApp.ObjectId -RequiredResourceAccess $RequiredList
    $SetSplat = @{ }
    Foreach ($AppOptions in $App['SourceApp'].psobject.properties.name) {
        if ($App['SourceApp'].$AppOptions) {
            $SetSplat[$AppOptions] = $App['SourceApp'].$AppOptions
        }
    }

    Add-AzureADApplicationOwner -ObjectId $TargetApp.ObjectId -RefObjectId $AppOwner.ObjectId

    if ($SecretDuration -ne 'None') {
        $Date = Get-Date
        $Params = @{
            ObjectId            = $TargetApp.ObjectId
            EndDate             = $Date.AddYears($SecretDuration)
            CustomKeyIdentifier = "{0}-{1}" -f $TargetApp.Displayname, $Date.ToString("yyyyMMddTHHmm")
        }
        $SecretResult = New-AzureADApplicationPasswordCredential @Params
        $Output['Secret'] = $SecretResult.value
    }

    Write-Host "Grant Admin Consent by logging in as $Owner here:`r`n" -ForegroundColor Cyan
    $ConsentURL = 'https://login.microsoftonline.com/{0}/v2.0/adminconsent?client_id={1}&state=12345&redirect_uri={2}&scope={3}&prompt=admin_consent' -f @(
        $Tenant.ObjectID, $TargetApp.AppId, 'https://portal.azure.com/', 'https://graph.microsoft.com/.default')

    Write-Host "$ConsentURL" -ForegroundColor White
    [PSCustomObject]$Output
    if ($ExportToConnectPoshGraphDelegated) {
        $SaveSplat = @{
            Tenant        = $Name
            Secret        = $Output['Secret']
            ApplicationId = $Output['ApplicationId']
            TenantId      = $Output['TenantId']
        }
        if ($ExportToConnectPoshGraphDelegated) { $SaveSplat['PromptForDelegatedCredentials'] = $true }
        Save-GraphConfig @SaveSplat
        Write-Host "To connect with Graph use: " -ForegroundColor Cyan
        Write-Host "                    Connect-PoshGraph -Tenant $Name" -ForegroundColor Green
    }
    if ($OpenConsentInBrowser) { Start $ConsentURL }
}
