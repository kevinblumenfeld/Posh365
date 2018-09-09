function Get-OneDriveReport {
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
    }

    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
    $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")

    $ReportPath = '.\'
    $FileTime = ("OneDriveUsage" + $(get-date -Format _yyyy-MM-dd_HH-mm-ss) + ".csv")
    $CSVPath = Join-Path $ReportPath $FileTime

    $user = (Get-SPOUser -Limit all -Site $mysiteHost).LoginName

    foreach ($curUser in $user) {
        $curUserConverted = $curUser.Replace(".", "_").Replace("@", "_")
        write-host "CurUser: "$CurUser
        get-msoluser -UserPrincipalName $CurUser
        $site = $mysiteHost + "personal/" + $curUserConverted
        if ($site.Contains("ylo00")) {
            continue
        }
        Write-Verbose "Processing $site"
        Get-SPOWeb -UsernameString $UsernameString -Url $site -PwdSecureString $PwdSecureString -CSVPath $CSVPath
    }
}