function Import-BTSharePointExcelDecision {
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

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $WorksheetName,

        [Parameter()]
        [switch]
        $NoBatch,

        [Parameter()]
        [switch]
        $NoConfirmation
    )
    end {

        Connect-SharePointPNP -Url $SharePointURL

        $ExcelURL = "Shared Documents\{0}" -f $ExcelFile
        $TempExcel = '{0}_{1}' -f $Tenant, $ExcelFile
        $TempExcelPath = Join-Path -Path $ENV:TEMP $TempExcel

        Get-PnPFile -Url $ExcelURL -Path $Env:TEMP -Filename $TempExcel -AsFile -Force

        $ExcelSplat = @{
            Path = $TempExcelPath
        }
        if ($WorksheetName) {
            $ExcelSplat.Add('WorksheetName' , $WorksheetName)
        }
        $ExcelObject = Import-Excel @ExcelSplat
        $UserDecisionSplat = @{
            DecisionObject = $ExcelObject
            ChooseDomain   = $true
            NoConfirmation = $NoConfirmation
        }
        $UserChoice = Get-UserDecision @UserDecisionSplat
        $UserChoice
    }
}

