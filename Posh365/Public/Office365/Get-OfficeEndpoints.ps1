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
        $OutputToConsole
    )
    end {
        if ($OutputToConsole) {
            Invoke-GetOfficeEndpoints @PSBoundParameters
        }
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
            Invoke-GetOfficeEndpoints @PSBoundParameters | Export-Csv -Path $EndpointCsv -NoTypeInformation
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
