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
    $AcceptedDomains = (Get-AcceptedDomain).DomainName
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

        $AddressList.Add((@($Source.EmailAddresses -split [Regex]::Escape('|') ).where{
                    $_ -like "x500:*" -or ($_ -split '@')[1] -in $AcceptedDomains
                }).foreach{ '{0}:{1}' -f ($_ -split ':')[0].ToLower(), ($_ -split ':')[1] })

        $ConstructedUPN = '{0}@{1}' -f ($Source.UserPrincipalName -split '@')[0], $InitialDomain

        if ($Source.PrimarySmtpAddress) {
            $ConstructedPrimarySmtp = '{0}@{1}' -f ($Source.PrimarySmtpAddress -split '@')[0], $InitialDomain
        }
        else {
            $ConstructedPrimarySmtp = ''
        }

        [PSCustomObject]@{
            DisplayName               = $Source.DisplayName
            Type                      = $Source.Type
            RecipientType             = $Source.RecipientType
            RecipientTypeDetails      = $Source.RecipientTypeDetails
            AzureADUPN                = '{0}@{1}' -f ($Source.UserPrincipalName -split '@')[0], $InitialDomain
            UserPrincipalName         = $ConstructedUPN
            ExternalEmailAddress      = $Source.ExternalEmailAddress
            Alias                     = $Source.Alias
            PrimarySmtpAddress        = $ConstructedPrimarySmtp
            SourceInitial             = $Source.InitialAddress
            ExchangeGuid              = $Source.ExchangeGuid
            ArchiveGuid               = $Source.ArchiveGuid
            LegacyExchangeDN          = $LegacyExchangeDN
            InitialAddress            = $TargetInitial
            EmailAddresses            = @($AddressList) -ne '' -join '|'
            ExternalDirectoryObjectId = $Source.ExternalDirectoryObjectId
            UPNPrimaryMismatch        = if ( $Source.PrimarySmtpAddress -and ($Source.PrimarySmtpAddress -split '@')[0] -ne ($Source.UserPrincipalName -split '@')[0]) {
                $Source.UserPrincipalName
            }
            else { '' }
        }
    }
}
