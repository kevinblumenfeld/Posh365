Function Watch-ToLicense {
    <#
    .SYNOPSIS
    
    .EXAMPLE

    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [System.IO.FileInfo] $GuidFolder,        
        [Parameter()]
        [string[]] $optionsToAdd
    )

    Start-Job -Name WatchToLicense {
        $optionsToAdd = $args[0]
        $GuidFolder = $args[1]
        Set-Location $GuidFolder
        Connect-ToCloud Office365 -AzureADver2
        while (Test-Path $GuidFolder) {
            Get-ChildItem -Path $GuidFolder -File -Verbose | ForEach {
                if ($_ -and !($_.name -eq 'ALLDONE'))  {
                    Get-Content $_.VersionInfo.filename | Set-CloudLicense -ExternalOptionsToAdd $optionsToAdd
                    Remove-Item $_.VersionInfo.filename -verbose
                }
                    if ($_.name -eq "ALLDONE") {
                        WRITE-HOST "EXITONZERO"
                        $ExitOnZero = $True
                        Remove-Item $_.VersionInfo.filename -verbose
                    }
                    if ((Get-ChildItem -Path $GuidFolder).count -gt 0 -and $ExitOnZero) {
                        WRITE-HOST "SHOULD EXIT HERE"
                        Stop-Job WatchToLicense
                        Remove-Job WatchToLicense
                        Exit
                    }
            }
        }
        Disconnect-AzureAD
    } -ArgumentList $optionsToAdd, $GuidFolder | Out-Null 
}    
