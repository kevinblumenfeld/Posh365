function Convert-CloudData {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $SourceFilePath,

        [Parameter()]
        $SourceData
    )

    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
    $AcceptedDomains = (Get-AcceptedDomain).DomainName
    if (-not $SourceData) {
        $SourceData = Import-Csv -Path $SourceFilePath
    }

    foreach ($Source in $SourceData) {

        $TargetInitial = 'smtp:{0}@{1}' -f ($Source.InitialAddress -split '@')[0], $InitialDomain

        $AddressList = [System.Collections.Generic.List[string]]::New()
        $AddressList.Add('x500:{0}' -f $Source.LegacyExchangeDN)
        $AddressList.Add((@($Source.EmailAddresses -split [Regex]::Escape('|') ).where{
                    $_ -like "x500:*" -or ($_ -split '@')[1] -in $AcceptedDomains
                }).foreach{ '{0}:{1}' -f ($_ -split ':')[0].ToLower(), ($_ -split ':')[1] })

        [PSCustomObject]@{
            'DisplayName'          = $Source.DisplayName
            'Alias'                = $Source.Alias
            'SourceType'           = $Source.RecipientTypeDetails
            'RecipientType'        = 'MailUser'
            'RecipientTypeDetails' = 'MailUser'
            'UserPrincipalName'    = $TargetInitial
            'PrimarySmtpAddress'   = $TargetInitial
            'ExchangeGuid'         = $Source.ExchangeGuid
            'ArchiveGuid'          = $Source.ArchiveGuid
            'LegacyExchangeDN'     = 'x500:{0}' -f $Source.LegacyExchangeDN
            'InitialAddress'       = $TargetInitial
            'EmailAddresses'       = @($AddressList) -ne '' -join '|'
            'ExternalEmailAddress' = $Source.InitialAddress
        }
    }
}
