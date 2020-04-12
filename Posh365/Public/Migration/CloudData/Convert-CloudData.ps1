function Convert-CloudData {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $FilePath,

        [Parameter()]
        $SourceData
    )

    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName

    if (-not $SourceData) {
        $SourceData = Import-Csv -Path $FilePath
    }

    foreach ($Source in $SourceData) {
        $AddressList = [System.Collections.Generic.List[string]]::New()
        if ($Source.InitialAddress) {
            $TargetInitial = '{0}@{1}' -f ($Source.InitialAddress -split '@')[0], $InitialDomain
        }
        else {
            $TargetInitial = ''
        }
        if ($Source.LegacyExchangeDN) {
            $LegacyExchangeDN = 'x500:{0}' -f $Source.LegacyExchangeDN
            $AddressList.Add($LegacyExchangeDN)
        }
        else {
            $LegacyExchangeDN = ''
        }
        $AddressList.Add((@($Source.EmailAddresses -split [Regex]::Escape('|') ).where{ $_ -like "x500:*" }))

        if ($Source.PrimarySmtpAddress) {
            $TargetPrimarySmtpAddress = '{0}@{1}' -f ($Source.PrimarySmtpAddress -split '@')[0], $InitialDomain
        }
        else {
            $TargetPrimarySmtpAddress = ''
        }
        if ($Source.Name) {$Name = $Source.Name} else {$Name = ''}
        [PSCustomObject]@{
            DisplayName               = $Source.DisplayName
            Name                      = $Name
            Type                      = $Source.Type
            RecipientType             = $Source.RecipientType
            RecipientTypeDetails      = $Source.RecipientTypeDetails
            UserPrincipalName         = '{0}@{1}' -f ($Source.UserPrincipalName -split '@')[0], $InitialDomain
            ExternalEmailAddress      = $Source.ExternalEmailAddress
            Alias                     = $Source.Alias
            PrimarySmtpAddress        = $TargetPrimarySmtpAddress
            LegacyExchangeDN          = $LegacyExchangeDN
            InitialAddress            = $TargetInitial
            EmailAddresses            = @($AddressList) -ne '' -join '|'
            UPNPrimaryMismatch        = if ( $Source.PrimarySmtpAddress -and ($Source.PrimarySmtpAddress -split '@')[0] -ne ($Source.UserPrincipalName -split '@')[0]) {
                $Source.UserPrincipalName
            }
            else { '' }
            ExternalDirectoryObjectId = $Source.ExternalDirectoryObjectId
            SourceUserPrincipalName   = $Source.UserPrincipalName
            SourcePrimarySmtpAddress  = $Source.PrimarySmtpAddress
            SourceEmailAddresses      = $Source.EmailAddresses
            SourceExchangeGuid        = $Source.ExchangeGuid
            SourceArchiveGuid         = $Source.ArchiveGuid

        }
    }
}
