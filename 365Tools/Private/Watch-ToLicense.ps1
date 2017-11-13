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

    $WatcherJob = Start-Job -Name WatchToLicense {
        $optionsToAdd = $args[0]
        $GuidFolder = $args[1]
        Set-Location $GuidFolder
        Connect-ToCloud Office365 -AzureADver2
        Start-Sleep -Seconds 120
        while (Test-Path $GuidFolder) {
            Get-ChildItem -Path $GuidFolder -File -Verbose | ForEach {
                if ($_ -and !($_.name -eq 'ALLDONE')) {
                    Get-Content $_.VersionInfo.filename | Set-CloudLicense -ExternalOptionsToAdd $optionsToAdd
                    Remove-Item $_.VersionInfo.filename -verbose
                }
                if ($_.name -eq "ALLDONE") {
                    $ExitOnZero = $True
                    Remove-Item $_.VersionInfo.filename -verbose
                }
            }
        }
        Disconnect-AzureAD
    } -ArgumentList $optionsToAdd, $GuidFolder | Out-Null 
    $WatcherJob | Wait-Job
    $WatcherJob | Remove-Job
}    
