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
        while ($GuidFolder) {
            Get-ChildItem -Path $GuidFolder -File -Verbose | ForEach {
                write-host "PIPELINE:  " $GuidFolder
                Get-Content $_ | Set-CloudLicense -ExternalOptionsToAdd $optionsToAdd
                Remove-Item $_ -verbose
            }
        }
        Disconnect-AzureAD
        Remove-Job -Name WatchToLicense -verbose
    } -ArgumentList $optionsToAdd, $GuidFolder | Out-Null
    
    
}    
