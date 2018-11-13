function Get-OktaUserReport {
    Param (

    )
    $UserHash = Get-OktaUserHash
    $UserHash.keys | ForEach-Object {

        $key = $_
        [pscustomobject]@{
            Id               = $key
            FirstName        = $UserHash[$key].FirstName
            LastName         = $UserHash[$key].LastName
            Login            = $UserHash[$key].Login
            Email            = $UserHash[$key].Email
            Status           = $UserHash[$key].Status
            ProviderType     = $UserHash[$key].ProviderType
            ProviderName     = $UserHash[$key].ProviderName
            Created          = $UserHash[$key].Created
            Activated        = $UserHash[$key].Activated
            StatusChanged    = $UserHash[$key].StatusChanged
            LastLogin        = $UserHash[$key].LastLogin
            LastUpdated      = $UserHash[$key].LastUpdated
            PasswordChanged  = $UserHash[$key].PasswordChanged
            RecoveryQuestion = $UserHash[$key].RecoveryQuestion
        }

    }
    
}