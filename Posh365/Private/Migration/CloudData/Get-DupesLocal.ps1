function Get-DupesLocal {
    param (

        [Parameter()]
        $Prefix,

        [Parameter()]
        $Address,

        [Parameter()]
        $Hash,

        [Parameter()]
        $Recipient
    )
    Write-Host "Prefix Overlap: $($Recipient.PrimarySmtpAddress)" -ForegroundColor Red
    [PSCustomObject]@{
        Prefix                 = $Prefix
        Address                = $Address
        Type                   = $Hash[$Prefix]['RecipientTypeDetails']
        DisplayName            = $Hash[$Prefix]['DisplayName']
        PrimarySmtpAddress     = $Hash[$Prefix]['PrimarySmtpAddress']
        EmailAddresses         = @($Hash[$Prefix]['EmailAddresses']) -match [regex]::Escape(":$Prefix@") -join '|'
        DupePrefix             = $Prefix
        DupeType               = $Recipient.RecipientTypeDetails
        DupeDisplayName        = $Recipient.DisplayName
        DupePrimarySmtpAddress = $Recipient.PrimarySmtpAddress
        DupeEmailAddresses     = @($Recipient.EmailAddresses) -match [regex]::Escape(":$Prefix@") -join '|'
    }
}