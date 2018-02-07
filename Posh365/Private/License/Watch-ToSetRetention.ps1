Function Watch-ToSetRetention {
    <#
    .SYNOPSIS
    
    .EXAMPLE

    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [System.IO.FileInfo] $GuidFolderRetention,        
        [Parameter()]
        [string] $RetentionPolicyToAdd
    )

    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME

    $targetAddressSuffix = Get-Content ($RootPath + "$($user).TargetAddressSuffix")

    $WatcherJob = Start-Job -Name Watch-ToSetRetention {
        $RetentionPolicyToAdd = $args[0]
        $GuidFolderUPN = $args[1]
        $targetAddressSuffix = $args[2]
        Set-Location $GuidFolderRetention
        Connect-Cloud $targetAddressSuffix -ExchangeOnline -EXOPrefix
        Start-Sleep -Seconds 120
        while (Test-Path $GuidFolderRetention) {
            Get-ChildItem -Path $GuidFolderRetention -File -Verbose -ErrorAction SilentlyContinue | ForEach {
                if ($_ -and !($_.name -eq 'ALLDONE')) {
                    Get-Content $_.VersionInfo.filename | Set-CloudMailbox -RetentionPolicy $RetentionPolicyToAdd
                    Remove-Item $_.VersionInfo.filename -verbose
                }
                if ($_.name -eq "ALLDONE" -and (Get-ChildItem -Path $GuidFolderRetention).count -eq 1) {
                    Remove-Item $_.VersionInfo.filename -verbose
                }
            }
        }
        Get-PSSession | Remove-PSSession
    } -ArgumentList $RetentionPolicyToAdd, $GuidFolderRetention, $targetAddressSuffix | Out-Null 
}    
