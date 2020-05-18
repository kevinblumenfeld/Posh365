function Convert-CloudData {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $FilePath,

        [Parameter()]
        $SourceData,

        [Parameter()]
        $Type
    )
    if ($Type -eq 'AzureADUsers' -and ($InitialDomain = try { ((Get-AzureADDomain).where{ $_.IsInitial }).Name } catch { })) {
        Write-Host "Connected to: $InitialDomain"
    }
    elseif ($InitialDomain = try { ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName } catch { }) {
        Write-Host "Connected to: $InitialDomain"
    }
    if (-not $InitialDomain) {
        Write-Host "Halting as not connected.  Please connect and retry" -ForegroundColor Red
        break
    }
    if (-not $SourceData) {
        $SourceData = Import-Csv -Path $FilePath
    }
    if ($Type -match 'Mailboxes|MailUsers') {
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
            $x500List = $Source.EmailAddresses -split '\|' -like 'x500:*'
            foreach ($x500 in $x500List ) {
                $AddressList.Add($x500)
            }
            $TargetPrimarySmtpAddress = $Source.PrimarySmtpAddress
            if ($Source.Name) { $Name = $Source.Name } else { $Name = '' }
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
                UPNMatchesPrimary         = $Source.PrimarySmtpAddress -eq $Source.UserPrincipalName
                ExternalDirectoryObjectId = $Source.ExternalDirectoryObjectId
                MicrosoftOnlineServicesID = $Source.MicrosoftOnlineServicesID
                SourceUserPrincipalName   = $Source.UserPrincipalName
                SourcePrimarySmtpAddress  = $Source.PrimarySmtpAddress
                SourceEmailAddresses      = $Source.EmailAddresses
                SourceExchangeGuid        = $Source.ExchangeGuid
                SourceArchiveGuid         = $Source.ArchiveGuid
            }
        }
    }
    if ($Type -eq 'AzureADUsers') {
        foreach ($Source in $SourceData) {
            [PSCustomObject]@{
                DisplayName       = $Source.DisplayName
                Mailnickname      = $Source.Mailnickname
                UserPrincipalName = '{0}@{1}' -f ($Source.UserPrincipalName -split '@')[0], $InitialDomain
                ObjectId          = $Source.ObjectId
            }
        }
    }
}