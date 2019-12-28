function Get-Office365EndPoints {
    [CmdletBinding(DefaultParameterSetName = "Endpoints")]
    param (
        [ValidateSet('Worldwide', 'USGovDoD', 'USGovGCCHigh', 'China', 'Germany', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Instance = 'Worldwide',

        [ValidateSet('All', 'Common', 'Exchange', 'SharePoint', 'Skype', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Services = 'Exchange',

        [Parameter(ParameterSetName = 'Menu')]
        [switch]
        $Menu
    )
    end {

        $PoshDesktop = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Posh365'
        $EndpointPath = Join-Path -Path $PoshDesktop -ChildPath '365Endpoints'
        if (-not ($null = Test-Path $EndpointPath)) {
            $ItemSplat = @{
                Type        = 'Directory'
                Force       = $true
                ErrorAction = 'SilentlyContinue'
            }
            $null = New-Item $PoshDesktop @ItemSplat
            $null = New-Item $EndpointPath @ItemSplat
        }
        switch ($PSCmdlet.ParameterSetName) {
            'Endpoints' {
                foreach ($Service in $Services) {
                    $InitialSplat = @{
                        Uri           = 'https://endpoints.office.com/endpoints/{0}?ServiceAreas={1}&clientRequestId={2}' -f $Instance, $Service, [GUID]::NewGuid().Guid
                        Method        = 'GET'
                        ErrorAction   = 'Stop'
                        WarningAction = 'SilentlyContinue'
                    }
                    $EndpointList = Invoke-RestMethod @InitialSplat
                    foreach ($Endpoint in $EndpointList) {
                        if ($Endpoint.ips) {
                            foreach ($IP in $Endpoint.ips) {
                                foreach ($Port in $Endpoint.tcpPorts.split(',')) {
                                    [PSCustomObject]@{
                                        id          = $Endpoint.id
                                        serviceArea = $Endpoint.serviceArea
                                        tcpPorts    = $Port
                                        ip          = $IP
                                        category    = $Endpoint.category
                                        required    = $Endpoint.required
                                        notes       = $Endpoint.notes
                                    }
                                }
                            }
                        }
                    }
                }
            }
            'Menu' {
                $TenantType = @('Worldwide', 'USGovDoD', 'USGovGCCHigh', 'China', 'Germany')
                $TenantChoice = ($TenantType | ForEach-Object {
                        [PSCustomObject]@{
                            Instance = $_
                        }
                    } | Out-GridView -OutputMode Single -Title "Choose tenant instance").Instance

                $ServicesType = @('All', 'Common', 'Exchange', 'SharePoint', 'Skype')
                $Services = ($ServicesType | ForEach-Object {
                        [PSCustomObject]@{
                            Service = $_
                        }
                    } | Out-GridView -OutputMode Multiple -Title "Choose one or more services").Service

                if (-not $TenantChoice -or -not $Services) {
                    Write-Warning "Please run again and choose a selection for each menu"
                    return
                }

                $VersionArray = [System.Collections.Generic.List[string]]::new()
                $VersionArray.Add('InitialList')
                $MenuRestSplat = @{
                    Uri           = 'https://endpoints.office.com/version/{0}?AllVersions=true&clientRequestId={1}' -f $TenantChoice, [GUID]::NewGuid().Guid
                    Method        = 'GET'
                    ErrorAction   = 'Stop'
                    WarningAction = 'SilentlyContinue'
                }

                $VersionList = Invoke-RestMethod @MenuRestSplat
                $VersionList.Versions | ForEach-Object { $VersionArray.Add($_) }
                $DateChoice = $VersionArray | ForEach-Object {
                    [PSCustomObject]@{
                        Choice = $_
                    }
                } | Out-GridView -OutputMode Single -Title "Choose initial list (for initial setup) or changes since particular date"

                if (-not $DateChoice) {
                    Write-Warning "Please run again and make a selection"
                    return
                }
                if ($DateChoice.Choice -eq 'InitialList') {
                    foreach ($Item in $Services) {
                        Get-Office365EndPoints -Instance $TenantChoice -Services $Item
                    }
                }
                else {
                    foreach ($Service in $Services) {
                        $ChangeSplat = @{
                            Uri           = 'https://endpoints.office.com/changes/{0}/{1}?ServiceAreas={2}&clientRequestId={3}' -f $TenantChoice, $DateChoice.Choice, $Service, [GUID]::NewGuid().Guid
                            Method        = 'GET'
                            ErrorAction   = 'Stop'
                            WarningAction = 'SilentlyContinue'
                        }
                        $ChangeList = Invoke-RestMethod @ChangeSplat
                        foreach ($Change in $ChangeList) {
                            if ($Change.Add.ips) {
                                $AddIPList = $Change.Add.ips
                                foreach ($AddIP in $AddIPList) {
                                    [PSCustomObject]@{
                                        id            = $Change.id
                                        endpointsetid = $Change.endpointsetid
                                        disposition   = $Change.disposition
                                        version       = $Change.version
                                        impact        = $Change.impact
                                        serviceArea   = $Service
                                        IPorURL       = $AddIP
                                    }
                                }
                            }
                            if ($Change.Remove.ips) {
                                $RemoveIPList = $Change.Remove.ips
                                foreach ($RemoveIP in $RemoveIPList) {
                                    [PSCustomObject]@{
                                        id            = $Change.id
                                        endpointsetid = $Change.endpointsetid
                                        disposition   = $Change.disposition
                                        version       = $Change.version
                                        impact        = $Change.impact
                                        serviceArea   = $Service
                                        IPorURL       = $RemoveIP
                                    }
                                }
                            }
                            if ($Change.Add.urls) {
                                $AddURLList = $Change.Add.Urls
                                foreach ($AddUrl in $AddUrlList) {
                                    [PSCustomObject]@{
                                        id            = $Change.id
                                        endpointsetid = $Change.endpointsetid
                                        disposition   = $Change.disposition
                                        version       = $Change.version
                                        impact        = $Change.impact
                                        serviceArea   = $Service
                                        IPorURL       = $AddUrl
                                    }
                                }
                            }
                            if ($Change.Remove.Urls) {
                                $RemoveUrlList = ($Change | Select-Object Add).Add.ips
                                foreach ($RemoveUrl in $RemoveUrlList) {
                                    [PSCustomObject]@{
                                        id            = $Change.id
                                        endpointsetid = $Change.endpointsetid
                                        disposition   = $Change.disposition
                                        version       = $Change.version
                                        impact        = $Change.impact
                                        serviceArea   = $Service
                                        IPorURL       = $RemoveUrl
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
