function Get-OfficeEndpoints {
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
        $Dedupe,

        [Parameter()]
        [switch]
        $OutputToConsole
    )
    end {
        if ($OutputToConsole) {
            $EndpointObject = Invoke-GetOfficeEndpoints @PSBoundParameters
            if ($Dedupe) {
                $EndpointObject | Select-Object -Property * -ExcludeProperty ID -Unique
            }
            else {
                $EndpointObject
            }
        }
        # NOT OUTPUT CONSOLE
        else {
            $PoshDesktop = Join-Path ([Environment]::GetFolderPath("Desktop")) -ChildPath 'Posh365'
            $EndpointPath = Join-Path -Path $PoshDesktop -ChildPath 'Endpoints'
            $EndpointCsv = Join-Path -Path $EndpointPath -ChildPath 'Endpoints.csv'
            $EndpointXlsx = Join-Path -Path $EndpointPath -ChildPath 'Endpoints.xlsx'

            if (-not ($null = Test-Path $EndpointPath)) {
                $ItemSplat = @{
                    Type        = 'Directory'
                    Force       = $true
                    ErrorAction = 'SilentlyContinue'
                }
                $null = New-Item $PoshDesktop @ItemSplat
                $null = New-Item $EndpointPath @ItemSplat
            }

            Invoke-GetOfficeEndpoints @PSBoundParameters | Export-Csv -Path $EndpointCsv

            if ($DateChoice.Choice -eq 'InitialList') {

                $EndpointObject = Import-Csv $EndpointCsv

                if ($EndpointObject.tcpPorts) {
                    $tcp = ($EndpointObject | Select-Object tcpPorts -Unique) -match "\d" |
                    Out-GridView -OutputMode Multiple -Title 'Choose TCP Ports to include in report'
                }
                if ($EndpointObject.udpPorts) {
                    $udp = ($EndpointObject | Select-Object udpPorts -Unique) -match "\d" |
                    Out-GridView -OutputMode Multiple -Title 'Choose UDP Ports to include in report'
                }
                if ($Dedupe) {
                    $EndpointObject.where( { $_.tcpPorts -in $tcp.tcpPorts -or $_.udpPorts -in $udp.udpPorts }) |
                    Select-Object -Property * -ExcludeProperty ID -Unique | Export-Csv -Path $EndpointCsv -NoTypeInformation
                }
                else {
                    $EndpointObject.where( { $_.tcpPorts -in $tcp.tcpPorts -or $_.udpPorts -in $udp.udpPorts }) |
                    Export-Csv -Path $EndpointCsv -NoTypeInformation
                }
            }

            Write-Verbose "Creating Excel Workbook"
            $ExcelSplat = @{
                TableStyle              = 'Medium2'
                FreezeTopRowFirstColumn = $true
                AutoSize                = $true
                BoldTopRow              = $false
                ClearSheet              = $true
                ErrorAction             = 'SilentlyContinue'
            }
            Import-Csv -Path $EndpointCsv | Export-Excel @ExcelSplat -Path $EndpointXlsx
            Write-Host "Results can be found on the Desktop, in the Posh365 folder" -ForegroundColor Green
        }
    }
}
