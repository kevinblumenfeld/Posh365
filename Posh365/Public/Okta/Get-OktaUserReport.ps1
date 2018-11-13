function Get-OktaUserReport {
    Param (

    )

    $User = Get-OktaUser

    foreach ($CurUser in $User) {

        $Id = $CurUser.Id
        $ProfileDetails = ($CurUser).Profile
        $CredDetails = ($CurUser).Credentials

        [PSCustomObject]@{
            FirstName        = $ProfileDetails.FirstName
            LastName         = $ProfileDetails.LastName
            Login            = $ProfileDetails.Login
            Email            = $ProfileDetails.Email
            Id               = $Id
            Status           = $CurUser.Status
            Created          = $CurUser.Created
            Activated        = $CurUser.Activated
            StatusChanged    = $CurUser.StatusChanged
            LastLogin        = $CurUser.LastLogin
            LastUpdated      = $CurUser.LastUpdated
            PasswordChanged  = $CurUser.PasswordChanged
            ProviderType     = $CredDetails.Provider.Type
            ProviderName     = $CredDetails.Provider.Name
            RecoveryQuestion = $CredDetails.RecoveryQuestion.Question
        }

    }
    
}