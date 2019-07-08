function Import-SharePointExcelDecision {

    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant

    )
    end {

        Connect-SharePointPNP -Url $SharePointURL

        $ExcelURL = "Shared Documents\{0}" -f $ExcelFile
        $TempExcel = '{0}_{1}' -f $Tenant, $ExcelFile
        $TempExcelPath = Join-Path -Path $ENV:TEMP $TempExcel

        Get-PnPFile -Url $ExcelURL -Path $Env:TEMP -Filename $TempExcel -AsFile -Force

        if (-not (Get-Module -Name 'ImportExcel' -ListAvailable)) {
            Install-Module ImportExcel -Force -SkipPublisherCheck
        }
        $ExcelObject = Import-Excel $TempExcelPath
        $UserChoice = Get-UserDecision -DecisionObject $ExcelObject
        $UserChoice
    }
}

