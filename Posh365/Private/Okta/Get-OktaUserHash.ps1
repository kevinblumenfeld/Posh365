function Get-OktaUserHash {

    $UserHash = @{}

    $User = Get-OktaUser

    foreach ($CurUser in $User) {

        $Id = $CurUser.Id
        $ProfileDetails = ($CurUser).Profile
        $CredDetails = ($CurUser).Credentials

        $UserHash[$Id] = @{
            FirstName        = $ProfileDetails.FirstName
            LastName         = $ProfileDetails.LastName
            Login            = $ProfileDetails.Login
            Email            = $ProfileDetails.Email
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

    $UserHash
}