function Get-OneDriveReport {
    <#
    .SYNOPSIS
    Report on OneDrive usage, storage available, storage used, percentage used, bytes used
    
    .DESCRIPTION
    Report on OneDrive usage, storage available, storage used, percentage used, bytes used
    
    .PARAMETER Tenant
    You must use Connect-Cloud without MFA as the creds are retrieved from where Connect-Cloud stores them (by TENANT)
    Connect-Cloud -Tenant CONTOSO -SharePoint
    
    .EXAMPLE
    Connect-Cloud -Tenant CONTOSO -SharePoint
    Get-OneDriveReport -Verbose | Export-PoshExcel .\OneDriveUsage.xlsx
    
    .NOTES
    if user is not assigned OneDrive license you may see the following message in the LOG column in the output :
        "Exception calling "ExecuteQuery" with "0" argument(s). The remote server returned an error: (401) Unauthorized."
    #>
    
    param(
        [parameter(Mandatory)]
        [string] $Tenant
    )

    try {
        $mysiteHost = (Get-SPOSite -Limit all -Template SPSMSITEHOST -ErrorAction stop).url
    }
    catch {
        Write-Host "You are not connected to SharePoint Online" -ForegroundColor Red
        continue
    }

    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $PwdSecureString = Get-Content ($KeyPath + "$($Tenant).cred") | ConvertTo-SecureString
    $UsernameString = Get-Content ($KeyPath + "$($Tenant).ucred")

    $UserList = Get-SPOUser -Limit All -Site $mysiteHost

    foreach ($User in $UserList) {

        $User = ($User.LoginName).Replace(".", "_").Replace("@", "_")
        Write-Verbose "User: $User"
        $site = $mysiteHost + "personal/" + $User
        if ($site.Contains("ylo00")) {
            continue
        }
        Write-Verbose "Processing: $site"
        $Params = @{
            UsernameString  = $UsernameString
            Url             = $site
            PwdSecureString = $PwdSecureString
            curUser         = $User
            Display         = $User.DisplayName
        }
        Get-SPOWeb @Params
    }
}
