function Get-OktaAppGroupReport {

    Param (
        [Parameter()]
        [string] $SearchString,
            
        [Parameter()]
        [string] $Filter,

        [Parameter()]
        [string] $Id
    )
    $Url = $OKTACredential.GetNetworkCredential().username
    $Token = $OKTACredential.GetNetworkCredential().Password

    if ($SearchString -and $filter -or ($SearchString -and $Id) -or ($Filter -and $Id)) {
        Write-Warning "Choose between zero and one parameters only"
        Write-Warning "Please try again"
        break
    }

    if (-not $SearchString -and -not $id -and -not $Filter) {
        $Group = Get-OktaUserReport
    }
    else {
        if ($SearchString) {
            $Group = Get-OktaGroupReport -SearchString $SearchString
        }    
        if ($Filter) {
            $Group = Get-OktaGroupReport -Filter $Filter
        }
        if ($Id) {
            $Group = Get-OktaGroupReport -Id $Id
        }
    }

    foreach ($CurGroup in $Group) {
        $Id = $CurGroup.Id
        $GName = $CurGroup.Name
        $GDescription = $CurGroup.Description
        $AppsInGroup = Get-OktaAppReport -GroupId $Id
        foreach ($App in $AppsInGroup) {
            [pscustomobject]@{
                GroupName     = $GName
                GroupDesc     = $GDescription
                GroupId       = $CurGroup.Id
                AppName       = $App.Name
                AppStatus     = $App.Status
                AppSignOnMode = $App.SignOnMode
            }
        }
    } 
}