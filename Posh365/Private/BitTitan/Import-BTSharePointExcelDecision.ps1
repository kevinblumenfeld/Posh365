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
        $TrimmedExcelFile = [regex]::matches($ExcelFile, "[^\/]*$")[0].Value
        $ExcelURL = "Shared Documents/{0}" -f ($ExcelFile).TrimStart('/')
        $TempExcel = '{0}_{1}' -f $BitTitanTicket.OrganizationId.Guid, $TrimmedExcelFile
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

