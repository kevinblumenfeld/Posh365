function Find-Spill {
    [CmdletBinding()]
    param ()
    do {
        $Splat = try {
            Invoke-Expression (Show-Command -NoCommonParameter -PassThru SpillFinder) -ErrorAction Stop
        }
        catch {
            Write-Host "Show-Command Error: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    } until ($Splat.count -gt 2)
    $EA = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        Connect-PoshGraph -Tenant $Splat.Tenant
        $FolderList = [System.Collections.Generic.List[string]]::New()
        $Params = @{ }
        foreach ($key in $Splat.keys) {
            if ($Splat[$key] -and $key -like '_Message_*' -or $key -eq 'Count') {
                $Params[$Key] = $Splat[$key]
            }
        }
        foreach ($key in $Splat.keys) {
            if ($Splat.keys -contains '_Folder_Root') { continue }
            if ($Splat[$key] -and $key -like '_Folder_*') {
                if ($key -eq '_Folder_RecoverableItems') { $FolderList.Add('recoverableitemsdeletions') }
                else { $FolderList.Add($key.replace('_Folder_', '')) }
            }
        }
        if ($Splat.ContainsKey('__Folder_Other')) { $FolderList.Add($Splat['__FolderOther']) }
        if (-not $FolderList) {
            if (-not $Splat['UserPrincipalName']) {
                Get-GraphUserAll | Get-GraphMailFolderAll | Get-GraphMailFolderMessageByID @Params
            }
            else {
                $Splat['UserPrincipalName'] | Get-GraphUser | Get-GraphMailFolderAll | Get-GraphMailFolderMessageByID @Params
            }
            continue
        }
        if ($Splat.ContainsKey('_Recurse')) {
            if (-not $Splat['UserPrincipalName']) {
                Get-GraphUserAll |
                Get-GraphMailFolder -WellKnownFolder $FolderList -Recurse | Get-GraphMailFolderMessageByID @Params
            }
            else {
                $Splat['UserPrincipalName'] | Get-GraphUser | Get-GraphMailFolder -WellKnownFolder $FolderList -Recurse |
                Get-GraphMailFolderMessageByID @Params
            }
        }
        elseif (-not $Splat['UserPrincipalName']) { Get-GraphUserAll | Get-GraphMailFolderMessage -FolderList $FolderList }
        else { $Splat['UserPrincipalName'] | Get-GraphUser | Get-GraphMailFolderMessage -FolderList $FolderList @Params }
    }
    catch {
        Write-Host "Graph Error: $($_.Exception.Message)" -ForegroundColor Cyan
        return
    }
    $ErrorActionPreference = $EA
}
