function Get-OktaAppReport {
    Param (

    )
    $AppHash = Get-OktaAppHash
    $AppHash.keys | ForEach-Object {

        $key = $_
        [pscustomobject]@{
            Id                   = $key
            Name                 = $AppHash[$key].Name
            Label                = $AppHash[$key].Label
            Status               = $AppHash[$key].Status
            Created              = $AppHash[$key].Created
            LastUpdated          = $AppHash[$key].LastUpdated
            Activated            = $AppHash[$key].Activated
            UserNameTemplate     = $AppHash[$key].UserNameTemplate
            UserNameTemplateType = $AppHash[$key].UserNameTemplateType
            CredentialScheme     = $AppHash[$key].CredentialScheme
            Features             = $AppHash[$key].Features
        }

    }
    
}