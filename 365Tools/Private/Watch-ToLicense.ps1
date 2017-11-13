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
        Set-Location $GuidFolder
        write-host $GuidFolder
        $optionsToAdd = $args[0]
        $GuidFolder = $args[1]

        Connect-ToCloud Office365 -AzureADver2
        while (Test-Path $GuidFolder) {
            Test-Path $GuidFolder
            Get-ChildItem -Path $GuidFolder -File -Verbose | ForEach {
                if ($_) {
                write-host "PIPELINE:  " $GuidFolder
                write-host "PIPELINE__:" $($_.VersionInfo.filename)
                Get-Content $_.VersionInfo.filename| Set-CloudLicense -ExternalOptionsToAdd $optionsToAdd
                Remove-Item $_.VersionInfo.filename
                }
            }
        }
        Disconnect-AzureAD
        Remove-Job -Name WatchToLicense -verbose
    } -ArgumentList $optionsToAdd, $GuidFolder | Out-Null
    
    
}    
