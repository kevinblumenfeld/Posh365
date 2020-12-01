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
    begin {
        if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
        $PSFun = @($PSCmdlet.ParameterSetName) -ne '' -join ','
        Write-Host "$PSFun" -ForegroundColor Green
        if ($GroupName) {
            $GroupId = Get-GraphGroup -Name $GroupName | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty Id
            if (-not $GroupId) { Write-Host "GroupID: $GroupId" -ForegroundColor yellow ; break }
            Write-Host "GroupID: $GroupId" -ForegroundColor Cyan
        }
    }
    process {
        foreach ($Name in $AppName) {
            switch ($PSCmdlet.ParameterSetName) {
                'PSAppName' {
                    $AppId = Get-MemMobileAppData -Name $Name | Select-Object -ExpandProperty Value | Select-Object -ExpandProperty Id
                    if ($AppId.count -gt 1) {
                        "Write-host"
                    }
                    Write-Host "AppID: $AppId" -ForegroundColor Cyan
                    if (-not $AppId) { return }
                }
            }
            $RestSplat = @{
                Uri     = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/{0}/assign' -f $AppId
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'POST'
                Body    = [PSCustomObject]@{
                    assignments = @{
                        target   = @{
                            '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                            groupId       = $GroupId
                        }
                        intent   = $intent
                        settings = @{
                            '@odata.type'            = '#microsoft.graph.iosStoreAppAssignmentSettings'
                            vpnConfigurationId       = $VpnId
                            uninstallOnDeviceRemoval = $UninstallOnDeviceRemoval
                        }
                    }
                } | ConvertTo-Json
            }
            Invoke-RestMethod @RestSplat
        }
    }
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
#     "Authorization"          = "Bearer eyJ0eXAiOiJKV1QiLCJub25jZSI6IlA5alBmeXljM1dvUVBTSW01aTNJV185UVYtbXRaS0JhVEtfeXQtbVBUaHciLCJhbGciOiJSUzI1NiIsIng1dCI6ImtnMkxZczJUMENUaklmajRydDZKSXluZW4zOCIsImtpZCI6ImtnMkxZczJUMENUaklmajRydDZKSXluZW4zOCJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20vIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNDQ1MTdhNWUtM2MxNS00N2I2LTkyZDUtODcxN2M5ZjRmZTNmLyIsImlhdCI6MTYwNjc5MDk2MywibmJmIjoxNjA2NzkwOTYzLCJleHAiOjE2MDY3OTQ4NjEsImFjY3QiOjAsImFjciI6IjEiLCJhY3JzIjpbInVybjp1c2VyOnJlZ2lzdGVyc2VjdXJpdHlpbmZvIiwidXJuOm1pY3Jvc29mdDpyZXExIiwidXJuOm1pY3Jvc29mdDpyZXEyIiwidXJuOm1pY3Jvc29mdDpyZXEzIiwiYzEiLCJjMiIsImMzIiwiYzQiLCJjNSIsImM2IiwiYzciLCJjOCIsImM5IiwiYzEwIiwiYzExIiwiYzEyIiwiYzEzIiwiYzE0IiwiYzE1IiwiYzE2IiwiYzE3IiwiYzE4IiwiYzE5IiwiYzIwIiwiYzIxIiwiYzIyIiwiYzIzIiwiYzI0IiwiYzI1Il0sImFpbyI6IkUyUmdZRWcveGhUL1IvbEttVXU5elFFbVhmVStOamQxRWYrU250OVJuRUY1SlJuN293QT0iLCJhbXIiOlsicHdkIl0sImFwcF9kaXNwbGF5bmFtZSI6Ik1pY3Jvc29mdCBJbnR1bmUgcG9ydGFsIGV4dGVuc2lvbiIsImFwcGlkIjoiNTkyNmZjOGUtMzA0ZS00ZjU5LThiZWQtNThjYTk3Y2MzOWE0IiwiYXBwaWRhY3IiOiIyIiwiY29udHJvbHMiOlsiY2FfZW5mIl0sImZhbWlseV9uYW1lIjoiQmx1bWVuZmVsZCIsImdpdmVuX25hbWUiOiJLZXZpbiIsImlkdHlwIjoidXNlciIsImlwYWRkciI6Ijc1LjEzMS4xODEuMTE0IiwibmFtZSI6IktldmluIEJsdW1lbmZlbGQiLCJvaWQiOiI2NWY1ODE3YS04MzkzLTQzODYtYjhjNS1iMjdmMDc0ZWE4NjYiLCJwbGF0ZiI6IjMiLCJwdWlkIjoiMTAwMzIwMDBFNUZCNkREQyIsInJoIjoiMC5BQUFBWG5wUlJCVTh0a2VTMVljWHlmVC1QNDc4SmxsT01GbFBpLTFZeXBmTU9hUjJBSUUuIiwic2NwIjoiQ2xvdWRQQy5SZWFkLkFsbCBEZXZpY2VNYW5hZ2VtZW50QXBwcy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRDb25maWd1cmF0aW9uLlJlYWRXcml0ZS5BbGwgRGV2aWNlTWFuYWdlbWVudE1hbmFnZWREZXZpY2VzLlByaXZpbGVnZWRPcGVyYXRpb25zLkFsbCBEZXZpY2VNYW5hZ2VtZW50TWFuYWdlZERldmljZXMuUmVhZFdyaXRlLkFsbCBEZXZpY2VNYW5hZ2VtZW50UkJBQy5SZWFkV3JpdGUuQWxsIERldmljZU1hbmFnZW1lbnRTZXJ2aWNlQ29uZmlndXJhdGlvbi5SZWFkV3JpdGUuQWxsIERpcmVjdG9yeS5BY2Nlc3NBc1VzZXIuQWxsIGVtYWlsIG9wZW5pZCBwcm9maWxlIFNpdGVzLlJlYWQuQWxsIiwic3ViIjoiUkgwQ21ETGpYOGlhbUxfbEcwNmFRWnpxTlJQSS16M1dJUm1hdFR0Tzl3USIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJOQSIsInRpZCI6IjQ0NTE3YTVlLTNjMTUtNDdiNi05MmQ1LTg3MTdjOWY0ZmUzZiIsInVuaXF1ZV9uYW1lIjoiYWRtaW5AZGV2a2V2aW4ub25taWNyb3NvZnQuY29tIiwidXBuIjoiYWRtaW5AZGV2a2V2aW4ub25taWNyb3NvZnQuY29tIiwidXRpIjoiZG1FcUYwV29sRXEzRUhOQXBXWnlBUSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc19zdCI6eyJzdWIiOiJPcnNORmwzSnNtQ05GMUE1d19FWlpjQUd0a25rdE9WeV9ZbUxkcExZMTh3In0sInhtc190Y2R0IjoxNjAwNzkwNzY0fQ.jZLgdiDFmyFrIaglUVMMGsXwliJRSiiK9xrPKmnElA2xA7eD14RF3j2PvRGvw54lkLYqXWE8dhV9yRUwGQKvCA1uJ2qSFe0T5Uh9604TVxLVNjmw2TI29AyeF41FX38PLn6pPZHbZRX-dAvstKPHBmry7cNCdamwSs3ytINayBmrKRbzulvSJ1XcTZcoq5nkWTz3mKT2fiynMy23986VvgGlKQF1vJwt0vD6qqiBMPi_-91FCo8H-7XHM365eR42On9diS1Wl8shCPCX543CY10PaTAGVDBk1ynxVI8mwTBH_aeNe39pJrrMR72IQvPSjdc21Om_5yF9jdYdg2gl3Q"
#     "x-ms-effective-locale"  = "en.en-us"
#     "Accept"                 = "*/*"
#     "Referer"                = ""
#     "x-ms-client-request-id" = "19364d3a-1c57-47b0-a06b-4279194d76f8"
#     "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36 Edg/87.0.664.47"
#     "client-request-id"      = "19364d3a-1c57-47b0-a06b-4279194d76f8"
# } `
#     -ContentType "application/json" `
#     -Body "{`"mobileAppAssignments`":[{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"208aad39-43eb-40cb-b137-b3bd8e3f5fba`"},`"intent`":`"Uninstall`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":null}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"f55f3673-bc01-485e-8021-960f271a5367`"},`"intent`":`"Required`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":false}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"3183abdb-5f47-4cca-bbf3-ff1c54f25609`"},`"intent`":`"AvailableWithoutEnrollment`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":false}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"ed3f3297-8ab1-4baf-bbbc-aec547f6a8e9`"},`"intent`":`"AvailableWithoutEnrollment`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":true}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"#microsoft.graph.groupAssignmentTarget`",`"groupId`":`"9758e1d8-297e-42a0-b7d8-ab857fbfbffb`"},`"intent`":`"Available`",`"settings`":{`"@odata.type`":`"#microsoft.graph.iosStoreAppAssignmentSettings`",`"vpnConfigurationId`":null,`"uninstallOnDeviceRemoval`":false}},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"microsoft.graph.exclusionGroupAssignmentTarget`",`"groupId`":`"0fea8e74-f721-4690-ae65-7527334b9bb8`"},`"intent`":`"Available`",`"settings`":null},{`"@odata.type`":`"#microsoft.graph.mobileAppAssignment`",`"target`":{`"@odata.type`":`"microsoft.graph.exclusionGroupAssignmentTarget`",`"groupId`":`"208aad39-43eb-40cb-b137-b3bd8e3f5fba`"},`"intent`":`"Required`",`"settings`":null}]}"