function Add-MemMobileAppAssignmentiOS {
    [CmdletBinding(DefaultParameterSetName = 'Placeholder')]
    param (
        [Parameter(ParameterSetName = 'PSGroupId')]
        [Parameter(ParameterSetName = 'PSAppId')]
        [Parameter(ParameterSetName = 'PSAppName')]
        $GroupId,

        [Parameter(ParameterSetName = 'PSGroupName')]
        [Parameter(ParameterSetName = 'PSAppId')]
        [Parameter(ParameterSetName = 'PSAppName')]
        $GroupName,

        [Parameter(ValueFromPipeline, ParameterSetName = 'PSAppId')]
        $AppId,

        [Parameter(ParameterSetName = 'PSAppName')]
        $AppName,

        [Parameter()]
        $VPNId = $null,

        [Parameter()]
        [switch]
        $UninstallOnDeviceRemoval,

        [Parameter(Mandatory)]
        [ValidateSet('Required', 'Available', 'AvailableWithoutEnrollment', 'Uninstall')]
        $intent
    )
    # begin {
    #     if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
    #     $PSFun = @($PSCmdlet.ParameterSetName) -ne '' -join ','
    #     Write-Host "$PSFun" -ForegroundColor Green
    #     if ($GroupName) {
    #         $GroupId = Get-GraphGroup -Name $GroupName | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty Id
    #         if (-not $GroupId) { Write-Host "GroupID: $GroupId" -ForegroundColor yellow ; break }
    #         Write-Host "GroupID: $GroupId" -ForegroundColor Cyan
    #     }
    # }
    # process {
    #     foreach ($Name in $AppName) {
    #         switch ($PSCmdlet.ParameterSetName) {
    #             'PSAppName' {
    #                 $AppId = Get-MemMobileAppData -Name $Name | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty Id
    #                 if ($AppId.count -gt 1) {
    #                     "Write-host"
    #                 }
    #                 Write-Host "AppID: $AppId" -ForegroundColor Cyan
    #                 if (-not $AppId) { return }
    #             }
    #         }
    #         $RestSplat = @{
    #             Uri     = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/{0}/assign' -f $AppId
    #             Headers = @{ "Authorization" = "Bearer $Token" }
    #             Method  = 'POST'
    #             Body    = [PSCustomObject]@{
    #                 assignments = @{
    #                     target   = @{
    #                         '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
    #                         groupId       = $GroupId
    #                     }
    #                     intent   = $intent
    #                     settings = @{
    #                         '@odata.type'            = '#microsoft.graph.iosStoreAppAssignmentSettings'
    #                         vpnConfigurationId       = $VpnId
    #                         uninstallOnDeviceRemoval = $UninstallOnDeviceRemoval
    #                     }
    #                 }
    #             } | ConvertTo-Json
    #         }
    #         Invoke-RestMethod @RestSplat
    #     }
    # }
}
# {
#     "mobileAppAssignments": [
#     {
#         "@odata.type": "#microsoft.graph.mobileAppAssignment",
#         "intent": "Uninstall",
#         "settings": {
#             "@odata.type": "#microsoft.graph.iosStoreAppAssignmentSettings",
#             "uninstallOnDeviceRemoval": null,
#             "vpnConfigurationId": null
#         },
#         "target": {
#             "@odata.type": "#microsoft.graph.groupAssignmentTarget",
#             "groupId": "208aad39-43eb-40cb-b137-b3bd8e3f5fba"
#         }
#     },
#     {
#         "@odata.type": "#microsoft.graph.mobileAppAssignment",
#         "intent": "AvailableWithoutEnrollment",
#         "settings": {
#             "@odata.type": "#microsoft.graph.iosStoreAppAssignmentSettings",
#             "uninstallOnDeviceRemoval": false,
#             "vpnConfigurationId": null
#         },
#         "target": {
#             "@odata.type": "#microsoft.graph.groupAssignmentTarget",
#             "groupId": "3183abdb-5f47-4cca-bbf3-ff1c54f25609"
#         }
#     },
#     {
#         "@odata.type": "#microsoft.graph.mobileAppAssignment",
#         "intent": "AvailableWithoutEnrollment",
#         "settings": {
#             "@odata.type": "#microsoft.graph.iosStoreAppAssignmentSettings",
#             "uninstallOnDeviceRemoval": true,
#             "vpnConfigurationId": null
#         },
#         "target": {
#             "@odata.type": "#microsoft.graph.groupAssignmentTarget",
#             "groupId": "ed3f3297-8ab1-4baf-bbbc-aec547f6a8e9"
#         }
#     },
#     {
#         "@odata.type": "#microsoft.graph.mobileAppAssignment",
#         "intent": "Available",
#         "settings": {
#             "@odata.type": "#microsoft.graph.iosStoreAppAssignmentSettings",
#             "uninstallOnDeviceRemoval": false,
#             "vpnConfigurationId": null
#         },
#         "target": {
#             "@odata.type": "#microsoft.graph.groupAssignmentTarget",
#             "groupId": "9758e1d8-297e-42a0-b7d8-ab857fbfbffb"
#         }
#     },
#     {
#         "@odata.type": "#microsoft.graph.mobileAppAssignment",
#         "intent": "Available",
#         "settings": null,
#         "target": {
#             "@odata.type": "microsoft.graph.exclusionGroupAssignmentTarget",
#             "groupId": "0fea8e74-f721-4690-ae65-7527334b9bb8"
#         }
#     }
#     ]
# }

# Invoke-WebRequest -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/47a67d3a-d67f-4e2b-a4d7-8f628d750bb8/assign" `
#     -Method "POST" `
#     -Headers @{
#     "x-ms-client-session-id" = "4ee29a17f4b746c0a959c40686eb941b"
#     "X-Content-Type-Options" = "nosniff"
#     "Accept-Language"        = "en"
#     "Authorization"          = "Bearer xyz"
#     "x-ms-effective-locale"  = "en.en-us"
#     "Accept"                 = "*/*"
#     "Referer"                = ""
#     "x-ms-client-request-id" = "19364d3a-1c57-47b0-a06b-4279194d76f8"
#     "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36 Edg/87.0.664.47"
#     "client-request-id"      = "19364d3a-1c57-47b0-a06b-4279194d76f8"
# } `
#     -ContentType "application/json" `
#     -Body "{`"mobileAppAssignments`":[{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"208aad39-43eb-40cb-b137-b3bd8e3f5fba`"},`"intent`":`"Uninstall`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":null}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"f55f3673-bc01-485e-8021-960f271a5367`"},`"intent`":`"Required`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":false}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"3183abdb-5f47-4cca-bbf3-ff1c54f25609`"},`"intent`":`"AvailableWithoutEnrollment`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":false}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"ed3f3297-8ab1-4baf-bbbc-aec547f6a8e9`"},`"intent`":`"AvailableWithoutEnrollment`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":true}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"9758e1d8-297e-42a0-b7d8-ab857fbfbffb`"},`"intent`":`"Available`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":false}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"microsoft.graph.exclusionGroupAssignmentTarget`",`"groupId`":`"0fea8e74-f721-4690-ae65-7527334b9bb8`"},`"intent`":`"Available`",`"settings`":null},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"microsoft.graph.exclusionGroupAssignmentTarget`",`"groupId`":`"208aad39-43eb-40cb-b137-b3bd8e3f5fba`"},`"intent`":`"Required`",`"settings`":null}]}"