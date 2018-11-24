function Get-OktaAppUserReportByUserId {
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $id
    )
    # Not Ready (or started)

    $App2UserHash = Get-OktaAppUserHash
    $AppHash = Get-OktaAppHash
    $UserHash = Get-OktaUserHash
    $App2UserHash.keys | ForEach-Object {

        $key = $_
        $User = $App2UserHash.$key
        foreach ($CurUser in $User) {

            [PSCustomObject]@{
                AppId         = $key
                AppName       = $AppHash.$key.Name
                AppLabel      = $AppHash.$key.Label
                User          = $CurUser
                UserFirstName = $UserHash.$CurUser.FirstName
                UserLastName  = $UserHash.$CurUser.LastName
                Email         = $UserHash.$CurUser.Email
            }
        }    
    }
    
}