function Connect-CloudMFADLL {
    [CmdletBinding()]
    Param
    (
    )
    end {
        $Modules = @(Get-ChildItem -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "Microsoft.Exchange.Management.ExoPowershellModule.manifest" -Recurse )
        try {
            $ModuleName = Join-Path $modules[0].Directory.FullName "Microsoft.Exchange.Management.ExoPowershellModule.dll"
            Import-Module -FullyQualifiedName $ModuleName -Force
        }
        catch {
            Write-Host "The PowerShell module which supports MFA must be installed."  -foregroundcolor "Black" -backgroundcolor "white"
            Write-Host "We can download the module and install it now."  -foregroundcolor "Black" -backgroundcolor "white"
            Write-Host "Once installed, close the PowerShell window that will pop-up & rerun your command here."  -foregroundcolor "Black" -backgroundcolor "white"
            Write-Host "NOTE: This should only be required once. Should there be any issue with the automatic download, go to https://outlook.office365.com/ecp/ Click Hybrid then click the second Configure button. Save or Run the file depending on your browser. If saved, double click the file to run it." -foregroundcolor "Blue" -backgroundcolor "white"
            Write-Host "Simply choose `"Y`" below then click `"Install`" button when prompted."  -foregroundcolor "Black" -backgroundcolor "white"
            $YesNo = Read-Host "Download Module Now (Y/N)?"
            if ($YesNo -eq "Y") {
                & "C:\Program Files\Internet Explorer\iexplore.exe" https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application
                Return
            }
            else {
                Write-Warning "You must install the PowerShell module to continue."
                Write-Warning "Either ReRun your command and press `"Y`" or, if you would prefer to install it manually..."
                Write-Warning "go to the EAC (https://outlook.office365.com/ecp/), then click Hybrid. Click the second Configure button."
                Write-Warning "Save or run the download depending on your browser prompt. If you saved the file please run it."
                Return
            }
        }
    }
}
