function Grant-OneDriveAdminAccess {
    param(
        [parameter(Position = 0, Mandatory = $true)]
        [string] $Tenant
    )

    try {
        $mysiteHost = (Get-SPOSite -Limit all -Template SPSMSITEHOST -ErrorAction stop).url
    }
    catch {
        Write-Host "You are not connected to SharePoint Online"
        Write-Host "We will now attempt to connect to SharePoint Online"
        Write-Host "If you require MFA, please connect prior with this command:"
        Write-Host "Connect-Cloud YourTenant -Sharepoint -MFA"
        Connect-Cloud $Tenant -SharePoint
        $mysiteHost = (Get-SPOSite -Limit all -Template SPSMSITEHOST).url
        Write-Verbose "MySiteHost: " $mysiteHost
    }

    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
    $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")

    $ReportPath = '.\'
    $ErrorFileTime = ("GrantOneDriveAdminAccess_Log_ERROR_" + $(get-date -Format _yyyy-MM-dd_HH-mm-ss) + ".csv")
    $ErrorCSVPath = Join-Path $ReportPath $ErrorFileTime
    $FileTime = ("GrantOneDriveAdminAccess_Log_" + $(get-date -Format _yyyy-MM-dd_HH-mm-ss) + ".csv")
    $CSVPath = Join-Path $ReportPath $FileTime

    $user = (Get-SPOUser -Limit All -Site $mysiteHost).LoginName

    foreach ($curUser in $user) {
        $curUser = $curUser.Replace(".", "_").Replace("@", "_")
        $site = $mysiteHost + "personal/" + $curUser
        if ($site.Contains("ylo00")) {
            continue
        }
        try {
            Set-SPOUser -Site $site -LoginName $UsernameString -IsSiteCollectionAdmin:$true
            Write-Verbose "Processing $site"
            [PSCustomObject]@{
                User    = $curUser
                Site    = $site
                Success = "Success"
            } | Export-Csv $CSVPath -Append -NoTypeInformation -Encoding UTF8
        }
        Catch {
            [PSCustomObject]@{
                User  = $curUser
                Site  = $site
                Error = $_.Exception.Message
            } | Export-Csv $ErrorCSVPath -Append -NoTypeInformation -Encoding UTF8
        }
    }
}