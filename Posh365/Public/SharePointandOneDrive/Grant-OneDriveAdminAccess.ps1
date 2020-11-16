function Grant-OneDriveAdminAccess {
    <#
    .SYNOPSIS
    Grant Full Access to each users OneDrive to a single Global Administrator
    
    .DESCRIPTION
    Grant Full Access to each users OneDrive to a single Global Administrator
    
    .PARAMETER GAUsername
    Username of Global Admin used to connect to SharePoint Online
    
    .EXAMPLE
    Grant-OneDriveAdminAccess -GAUserName AdminSmith | Export-PoshExcel .\GrantLog.xlsx
    
    .NOTES
    General notes
    #>
    
    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $GAUsername
    )

    try {
        $mysiteHost = (Get-SPOSite -Limit all -Template SPSMSITEHOST -ErrorAction stop).url
    }
    catch {
        Write-Host "You are not connected to SharePoint Online" -ForegroundColor Red
        continue
    }

    $UserList = (Get-SPOUser -Limit All -Site $mysiteHost).LoginName

    foreach ($User in $UserList) {
        $User = $User.Replace(".", "_").Replace("@", "_")
        $site = $mysiteHost + "personal/" + $User
        if ($site.Contains("ylo00")) {
            continue
        }
        try {
            Set-SPOUser -Site $site -LoginName $GAUsername -IsSiteCollectionAdmin:$true
            Write-Verbose "Processing $site"
            [PSCustomObject]@{
                User = $User
                Site = $site
                Log  = "Success"
            }
        }
        Catch {
            [PSCustomObject]@{
                User = $User
                Site = $site
                Log  = $_.Exception.Message
            }
        }
    }
}