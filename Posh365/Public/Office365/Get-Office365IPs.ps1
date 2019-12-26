function Get-Office365IPs {
    [CmdletBinding(DefaultParameterSetName = "Endpoint")]
    param (
        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [ValidateSet('Worldwide', 'USGovDoD', 'USGovGCCHigh', 'China', 'Germany', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Instance = 'Worldwide',

        [ValidateSet('All', 'Common', 'Exchange', 'SharePoint', 'Skype', IgnoreCase = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Services = 'Exchange',

        [Parameter(ParameterSetName = 'Full')]
        [switch]
        $Full,

        [Parameter(ParameterSetName = 'Picker')]
        [switch]
        $VersionPicker
    )
    end {

        $PoshPath = Join-Path -Path $Env:USERPROFILE -ChildPath '.Posh365'
        $TenantPath = Join-Path -Path $PoshPath -ChildPath $Tenant
        $EndpointPath = Join-Path -Path $TenantPath -ChildPath '365Endpoint'
        $Historical = Join-Path -Path $EndpointPath -ChildPath 'Historical'
        $EndpointXml = Join-Path -Path $EndpointPath -ChildPath ('{0}EndPoint.xml' -f $Instance)
        if (-not ($null = Test-Path $Historical)) {
            $ItemSplat = @{
                Type        = 'Directory'
                Force       = $true
                ErrorAction = 'SilentlyContinue'
            }
            $null = New-Item $PoshPath @ItemSplat
            $null = New-Item $TenantPath @ItemSplat
            $null = New-Item $EndpointPath @ItemSplat
            $null = New-Item $Historical @ItemSplat
        }
        $PSCmdlet.ParameterSetName
        switch ($PSCmdlet.ParameterSetName) {
            'Endpoint' {
                $endpointSetsParams = @{
                    Uri           = 'https://endpoints.office.com/version/{0}?clientRequestId={1}' -f $Instance, [GUID]::NewGuid().Guid
                    Method        = 'GET'
                    ErrorAction   = 'Stop'
                    WarningAction = 'SilentlyContinue'
                }
                $MicrosoftVersion = (Invoke-RestMethod @endpointSetsParams).latest

                if (Test-Path $EndpointXml) {
                    $OurVersion = (Import-Clixml $EndpointXml).latest
                }
                else {
                    [PSCustomObject]@{
                        instance = $Instance
                        latest   = '0000000000'
                    } | Export-Clixml -path $EndpointXml
                    $OurVersion = (Import-Clixml $EndpointXml).latest
                    try {
                        Copy-Item -path $EndpointXml -Destination (Join-Path -Path $Historical -ChildPath ($OurVersion + '.xml')) -Force
                        Remove-Item -Path $EndpointXml -Force
                    }
                    catch {

                    }
                }
                if ($MicrosoftVersion -gt $OurVersion) {
                    Write-Verbose "New Version Found"
                    Write-Verbose ("Our Version: {0}" -f $OurVersion)
                    Write-Verbose ("Microsoft Version Version: {0}" -f $MicrosoftVersion)
                    [PSCustomObject]@{
                        instance = $Instance
                        latest   = $MicrosoftVersion
                    } | Export-Clixml -path $EndpointXml -Force
                    foreach ($Service in $Services) {
                        $NewMicrosoftData = @{
                            Uri           = 'https://endpoints.office.com/changes/{0}/{1}?ServiceAreas={2}&clientRequestId={3}' -f $Instance, $OurVersion, $Service, [GUID]::NewGuid().Guid
                            Method        = 'GET'
                            ErrorAction   = 'Stop'
                            WarningAction = 'SilentlyContinue'
                        }
                        Invoke-RestMethod @NewMicrosoftData
                    }
                }
            }
            'Full' {
                foreach ($Service in $Services) {
                    $NewMicrosoftData = @{
                        Uri           = 'https://endpoints.office.com/endpoints/{0}?ServiceAreas={1}&clientRequestId={2}' -f $Instance, $Service, [GUID]::NewGuid().Guid
                        Method        = 'GET'
                        ErrorAction   = 'Stop'
                        WarningAction = 'SilentlyContinue'
                    }
                    Invoke-RestMethod @NewMicrosoftData

                }
            }
            'Picker' {
                $Choice = Get-ChildItem -Path $Historical -filter *.xml | ForEach-Object {
                    Import-Clixml $_.FullName | ForEach-Object {
                        [PSCustomObject]@{
                            Latest = $_.Latest
                        }
                    }
                } | Out-GridView -OutputMode Single
                foreach ($Service in $Services) {
                    $NewMicrosoftData = @{
                        Uri           = 'https://endpoints.office.com/changes/{0}/{1}?ServiceAreas={2}&clientRequestId={3}' -f $Instance, $Choice.Latest, $Service, [GUID]::NewGuid().Guid
                        Method        = 'GET'
                        ErrorAction   = 'Stop'
                        WarningAction = 'SilentlyContinue'
                    }
                    Invoke-RestMethod @NewMicrosoftData
                }
            }
        }
    }
}
