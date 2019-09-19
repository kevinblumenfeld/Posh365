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
        $ExcelURL = "Shared Documents/{0}" -f ($ExcelFile).TrimStart('/')
        $TempExcel = '{0}.xlsx' -f [guid]::newguid().guid
        $TempExcelPath = Join-Path -Path $ENV:TEMP $TempExcel
        try {
            Get-PnPFile -Url $ExcelURL -Path $Env:TEMP -Filename $TempExcel -AsFile -Force -ErrorAction Stop
            $ExcelSplat = @{
                Path = $TempExcelPath
            }
            if ($WorksheetName) {
                $ExcelSplat.Add('WorksheetName' , $WorksheetName)
            }
            $ExcelObject = Import-Excel @ExcelSplat

        }
        catch {
            Write-Host "Error getting file from SharePoint"
            $_.Exception.Message
        }
        finally {
            Remove-Item -Path $TempExcelPath -Force -Confirm:$false -ErrorAction SilentlyContinue
        }

        $UserDecisionSplat = @{
            DecisionObject = $ExcelObject
            NoBatch        = $NoBatch
            NoConfirmation = $NoConfirmation
        }
        $UserChoice = Get-UserDecision @UserDecisionSplat
        $UserChoice
    }
}

