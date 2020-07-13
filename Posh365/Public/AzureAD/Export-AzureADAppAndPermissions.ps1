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
        $Name,

        [Parameter(Mandatory)]
        [ValidateSet('AAD Request Verification Service - PROD', 'App Studio for Microsoft Teams', 'Azure ESTS Service', 'AzureSupportCenter', 'Bing',
            'Call Recorder', 'Centralized Deployment', 'ConnectionsService', 'Connectors', 'Cortana at Work Bing Services', 'Cortana at Work Service',
            'Cortana Experience with O365', 'Cortana Runtime Service', 'Data Classification Service', 'Demeter.WorkerRole', 'Discovery Service',
            'Dynamics 365 Business Central', 'EnterpriseAgentPlatform', 'Exchange Office Graph Client for AAD - Interactive',
            'Exchange Office Graph Client for AAD - Noninteractive', 'Federated Profile Service', 'Graph Connector Service', 'Groupies Web Service',
            'IAM Supportability', 'IPSubstrate', 'MCAPI Authorization Prod', 'Microsoft App Access Panel', 'Microsoft Approval Management',
            'Microsoft Discovery Service', 'Microsoft Exchange Online Protection', 'Microsoft Flow CDS Integration Service',
            'Microsoft Flow CDS Integration Service TIP1', 'Microsoft Flow Portal', 'Microsoft Flow Service', 'Microsoft Forms', 'Microsoft Graph',
            'Microsoft Information Protection Sync Service', 'Microsoft Invoicing', 'Microsoft Office 365 Portal', 'Microsoft Office Web Apps Service',
            'Microsoft People Cards Service', 'Microsoft Service Trust', 'Microsoft Stream Mobile Native', 'Microsoft Stream Portal',
            'Microsoft Stream Service', 'Microsoft Teams', 'Microsoft Teams AadSync', 'Microsoft Teams AuditService', 'Microsoft Teams AuthSvc',
            'Microsoft Teams Bots', 'Microsoft Teams Chat Aggregator', 'Microsoft Teams Graph Service', 'Microsoft Teams Mailhook',
            'Microsoft Teams RetentionHook Service', 'Microsoft Teams Services', 'Microsoft Teams Settings Store', 'Microsoft Teams Task Service',
            'Microsoft Teams User Profile Search Service', 'Microsoft Teams VSTS', 'Microsoft Teams Web Client', 'Microsoft Teams Wiki Images Migration',
            'Microsoft To-Do', 'Microsoft Whiteboard Services', 'Microsoft.ExtensibleRealUserMonitoring', 'Microsoft.MileIQ', 'Microsoft.MileIQ.Dashboard',
            'Microsoft.MileIQ.RESTService', 'Microsoft.OfficeModernCalendar', 'Microsoft.SMIT', 'MicrosoftTeamsCortanaSkills', 'MileIQ Admin Center',
            'O365 Customer Monitoring', 'O365 Demeter', 'O365 Secure Score', 'O365 UAP Processor', 'O365SBRM Service', 'Office 365 Client Admin',
            'Office 365 Configure', 'Office 365 Exchange Online', 'Office 365 Import Service', 'Office 365 Management APIs', 'Office Change Management',
            'Office365 Zoom', 'OfficeClientService', 'OneProfile Service', 'Outlook Online Add-in App', 'Permission Service O365', 'PowerAppsService',
            'Service Encryption', 'Signup', 'Skype Presence Service', 'Skype Team Substrate connector', 'Skype Teams Calling API Service',
            'Skype Teams Firehose', 'Substrate Instant Revocation Pipeline', 'Targeted Messaging Service', 'Windows Azure Active Directory',
            'Windows Azure Service Management API')]
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

    $XMLPath = (Join-Path -Path $TenantPath -ChildPath ('{0}-{1}.xml' -f $Name, [DateTime]::Now.ToString('yyyyMMdd-hhmm')) )
    $Hash | Export-Clixml $XMLPath -Force
    Write-Host "AzureAD App and API Permissions for TestApp $Name, exported to:" -ForegroundColor Cyan
    $XMLPath
}
