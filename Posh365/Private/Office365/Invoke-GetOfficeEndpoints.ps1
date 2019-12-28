function Invoke-GetOfficeEndpoints {
    [CmdletBinding()]
    param (
        [ValidateSet('Worldwide', 'USGovDoD', 'USGovGCCHigh', 'China', 'Germany', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Instance = 'Worldwide',

        [ValidateSet('All', 'Common', 'Exchange', 'SharePoint', 'Skype', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Services = 'Exchange',

        [Parameter()]
        [switch]
        $Menu,

        [Parameter()]
        [switch]
        $IncludeURLs,

        [Parameter()]
        [switch]
        $OutputToConsole
        # Placeholder
    )
    end {
        if ($Services -match 'All') {
            $Services = @('Exchange', 'SharePoint', 'Skype')
        }
        if (-not $Menu) {
            $Service = $Services -join ','
            $InitialSplat = @{
                Uri           = 'https://endpoints.office.com/endpoints/{0}?ServiceAreas={1}&clientRequestId={2}' -f $Instance, $Service, [GUID]::NewGuid().Guid
                Method        = 'GET'
                ErrorAction   = 'Stop'
                WarningAction = 'SilentlyContinue'
            }
            $EndpointList = Invoke-RestMethod @InitialSplat
            foreach ($Endpoint in $EndpointList) {
                # IPS
                if ($Endpoint.ips) {
                    $InitialList = $Endpoint.ips
                    foreach ($Initial in $InitialList) {
                        # TCP
                        if ($Endpoint.tcpPorts) {
                            foreach ($Port in $Endpoint.tcpPorts.split(',')) {
                                [PSCustomObject]@{
                                    id          = $Endpoint.id
                                    serviceArea = $Endpoint.serviceArea
                                    tcpPorts    = $Port
                                    udpPorts    = ''
                                    ip          = $Initial
                                    url         = ''
                                    category    = $Endpoint.category
                                    required    = $Endpoint.required
                                    notes       = $Endpoint.notes
                                }
                            }
                        }
                        # UDP
                        if ($Endpoint.udpPorts) {
                            foreach ($Port in $Endpoint.udpPorts.split(',')) {
                                [PSCustomObject]@{
                                    id          = $Endpoint.id
                                    serviceArea = $Endpoint.serviceArea
                                    tcpPorts    = ''
                                    udpPorts    = $Port
                                    ip          = $Initial
                                    url         = ''
                                    category    = $Endpoint.category
                                    required    = $Endpoint.required
                                    notes       = $Endpoint.notes
                                }
                            }
                        }
                    }
                }
                # URLS
                if ($Endpoint.urls -and $IncludeURLs) {
                    $InitialList = $Endpoint.urls
                    foreach ($Initial in $InitialList) {
                        # TCP
                        if ($Endpoint.tcpPorts) {
                            foreach ($Port in $Endpoint.tcpPorts.split(',')) {
                                [PSCustomObject]@{
                                    id          = $Endpoint.id
                                    serviceArea = $Endpoint.serviceArea
                                    tcpPorts    = $Port
                                    udpPorts    = ''
                                    ip          = ''
                                    url         = $Initial
                                    category    = $Endpoint.category
                                    required    = $Endpoint.required
                                    notes       = $Endpoint.notes
                                }
                            }
                        }
                        # UDP
                        if ($Endpoint.udpPorts) {
                            foreach ($Port in $Endpoint.udpPorts.split(',')) {
                                [PSCustomObject]@{
                                    id          = $Endpoint.id
                                    serviceArea = $Endpoint.serviceArea
                                    tcpPorts    = ''
                                    udpPorts    = $Port
                                    ip          = ''
                                    url         = $Initial
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
        else {
            $TenantType = @('Worldwide', 'USGovDoD', 'USGovGCCHigh', 'China', 'Germany')
            $TenantChoice = ($TenantType | ForEach-Object {
                    [PSCustomObject]@{
                        Instance = $_
                    }
                } | Out-GridView -OutputMode Single -Title "Choose tenant instance").Instance
            if (-not $TenantChoice) {
                Write-Warning "Please run again and choose a selection for each menu"
                return
            }
            $ServicesType = @('All', 'Common', 'Exchange', 'SharePoint', 'Skype')
            $Services = ($ServicesType | ForEach-Object {
                    [PSCustomObject]@{
                        Service = $_
                    }
                } | Out-GridView -OutputMode Multiple -Title "Choose one or more services").Service
            if ($Services -match 'All') { $Services = @('Exchange', 'SharePoint', 'Skype') }
            if (-not $Services) {
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
                    Invoke-GetOfficeEndpoints -Instance $TenantChoice -Services $Item
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
                        if ($Change.Add.ips) { $ItemList = $Change.Add.ips }
                        if ($Change.Remove.ips) { $ItemList = $Change.Remove.ips }
                        if ($IncludeURLs) {
                            if ($Change.Add.urls) { $ItemList = $Change.Add.urls }
                            if ($Change.Remove.urls) { $ItemList = $Change.Remove.urls }
                        }
                        foreach ($Item in $ItemList) {
                            [PSCustomObject]@{
                                id            = $Change.id
                                endpointsetid = $Change.endpointsetid
                                disposition   = $Change.disposition
                                version       = $Change.version
                                impact        = $Change.impact
                                serviceArea   = $Service
                                item          = $Item
                            }
                        }
                    }
                }
            }
        }
    }
}
