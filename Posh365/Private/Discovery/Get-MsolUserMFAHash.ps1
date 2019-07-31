function Get-MsolUserMFAHash {
    param (
        [Parameter(Mandatory)]
        $MsolUserList
    )

    $MFAHash = @{ }
    foreach ($MsolUser in $MsolUserList) {
        $MFAHash[$MsolUser.ObjectID] = @{
            'MFA_State'            = $MsolUser.MFA_State
            'UserPrincipalName'    = $MsolUser.UserPrincipalName
            'IsLicensed'           = $MsolUser.IsLicensed
            'LastDirSyncTime'      = $MsolUser.LastDirSyncTime
            'BlockCredential'      = $MsolUser.BlockCredential
            'PasswordNeverExpires' = $MsolUser.PasswordNeverExpires
        }
    }
    $MFAHash
}
