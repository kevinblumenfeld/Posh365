function Invoke-NewCloudData {

    [CmdletBinding()]
    param (
        [Parameter()]
        $ConvertedData
    )
    $ErrorActionPreference = 'stop'

    $ConvertedList = $ConvertedData | Where-Object { $_.Type -eq 'Recipient' }
    $Count = $ConvertedData.Count
    $iUP = 0
    foreach ($Converted in $ConvertedList) {
        $iUP++
        $MeuCreated, $MeuSet = $null
        $GeneratedPW = [System.Web.Security.Membership]::GeneratePassword(16, 7)
        try {
            $NewParams = @{
                Name                      = $Converted.DisplayName
                DisplayName               = $Converted.DisplayName
                MicrosoftOnlineServicesID = $Converted.UserPrincipalName
                PrimarySMTPAddress        = $Converted.UserPrincipalName
                Alias                     = $Converted.Alias
                Password                  = ConvertTo-SecureString -String $GeneratedPW -AsPlainText:$true -Force
                ErrorAction               = 'Stop'
            }
            if ($Converted.ExternalEmailAddress) {
                $NewParams['ExternalEmailAddress'] = $Converted.ExternalEmailAddress
            }
            $MeuCreated = New-MailUser @NewParams
            Write-Host "[$iUP of $count] Success New MailUser: $($MeuCreated.DisplayName)" -ForegroundColor Green

            $SetParams = @{
                Identity       = $MeuCreated.ExternalDirectoryObjectId
                EmailAddresses = @{Add = $Converted.EmailAddresses -split [regex]::Escape('|') }
                ErrorAction    = 'Stop'
            }
            if ($Converted.RecipientType -eq 'USERMAILBOX') {
                $SetParams['ExchangeGuid'] = $Converted.ExchangeGuid
            }
            $i = 0
            while (-not ($null = Get-MailUser -Filter ('PrimarySmtpAddress -eq "{0}"' -f $Converted.UserPrincipalName) -ErrorAction SilentlyContinue) -and $i -lt 50) {
                Write-Host ('Waiting for {0}' -f $Converted.UserPrincipalName) -ForegroundColor White
                Start-Sleep -Seconds $i
                $i++
            }
            Set-MailUser @SetParams
            $MeuSet = Get-MailUser -Filter ('PrimarySmtpAddress -eq "{0}"' -f $Converted.UserPrincipalName)
            Write-Host "[$iUP of $count] Success Set MailUser: $($MeuSet.DisplayName)" -ForegroundColor Green

            [PSCustomObject]@{
                ResultNew                 = 'SUCCESS'
                ResultSet                 = 'SUCCESS'
                Name                      = $MeuSet.Name
                DisplayName               = $MeuSet.DisplayName
                SourceType                = $Converted.RecipientTypeDetails
                MicrosoftOnlineServicesID = $MeuSet.MicrosoftOnlineServicesID
                UserPrincipalName         = $MeuSet.UserPrincipalName
                PrimarySMTPAddress        = $MeuSet.PrimarySMTPAddress
                Alias                     = $MeuSet.Alias
                SourceExchangeGuid        = $Converted.ExchangeGuid
                TargetExchangeGuid        = $MeuSet.ExchangeGuid
                SourceId                  = $Converted.ExternalDirectoryObjectId
                TargetId                  = $MeuSet.ExternalDirectoryObjectId
                Password                  = $GeneratedPW
                TargetEmailAddresses      = @($MeuSet.EmailAddresses) -ne '' -join '|'
                Log                       = 'SUCCESS'
            }

        }
        catch {
            if ($MeuCreated -and -not $MeuSet) {
                [PSCustomObject]@{
                    ResultNew                 = 'SUCCESS'
                    ResultSet                 = 'FAILED'
                    Name                      = $MeuCreated.Name
                    DisplayName               = $MeuCreated.DisplayName
                    SourceType                = $Converted.RecipientTypeDetails
                    MicrosoftOnlineServicesID = $MeuCreated.MicrosoftOnlineServicesID
                    UserPrincipalName         = $MeuCreated.UserPrincipalName
                    PrimarySMTPAddress        = $MeuCreated.PrimarySMTPAddress
                    Alias                     = $MeuCreated.Alias
                    SourceExchangeGuid        = $Converted.ExchangeGuid
                    TargetExchangeGuid        = 'FAILED'
                    SourceId                  = $Converted.ExternalDirectoryObjectId
                    TargetId                  = $MeuCreated.ExternalDirectoryObjectId
                    Password                  = $GeneratedPW
                    TargetEmailAddresses      = @($MeuCreated.EmailAddresses) -ne '' -join '|'
                    Log                       = $_.Exception.Message
                }
                Write-Host "[$iUP of $count] Failed Set MailUser: $($MeuCreated.DisplayName)" -ForegroundColor Yellow
            }
            else {
                [PSCustomObject]@{
                    ResultNew                 = 'FAILED'
                    ResultSet                 = 'FAILED'
                    Name                      = $Converted.DisplayName
                    DisplayName               = $Converted.DisplayName
                    SourceType                = $Converted.RecipientTypeDetails
                    MicrosoftOnlineServicesID = $Converted.UserPrincipalName
                    UserPrincipalName         = $Converted.UserPrincipalName
                    PrimarySMTPAddress        = $Converted.PrimarySMTPAddress
                    Alias                     = $Converted.Alias
                    SourceExchangeGuid        = $Converted.ExchangeGuid
                    TargetExchangeGuid        = 'FAILED'
                    SourceId                  = $Converted.ExternalDirectoryObjectId
                    TargetId                  = 'FAILED'
                    Password                  = $GeneratedPW
                    TargetEmailAddresses      = 'FAILED'
                    Log                       = $_.Exception.Message
                }
                Write-Host "[$iUP of $count] Failed New & Set MailUser: $($Converted.DisplayName)" -ForegroundColor Red
            }
        }
        if ($MeuCreated) {
            $i = 0
            $MeuPasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $MeuPasswordProfile.ForceChangePasswordNextLogin = $true
            do {
                try {
                    Set-AzureAdUser -ObjectId $MeuCreated.ExternalDirectoryObjectId -PasswordProfile $MeuPasswordProfile -ErrorAction Stop
                    $FlagAz = $true
                }
                catch {
                    Write-Host ('Waiting for AzureAdUser: {0}' -f $MeuCreated.DisplayName) -ForegroundColor White
                }
                $i++
            } until ($FlagAz -or $i -gt 50)
        }
    }
    $ConvertedAzList = $ConvertedData | Where-Object { $_.Type -eq 'AzureADUser' }
    foreach ($ConvertedAz in $ConvertedAzList) {
        $iUP++
        try {
            $GeneratedPW = [System.Web.Security.Membership]::GeneratePassword(16, 7)
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $GeneratedPW
            $PasswordProfile.ForceChangePasswordNextLogin = $true
            $AzUserParams = @{
                DisplayName       = $ConvertedAz.DisplayName
                UserPrincipalName = $ConvertedAz.AzureADUPN
                MailNickName      = ($ConvertedAz.AzureADUPN -split '@')[0]
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
                ErrorAction       = 'Stop'
            }
            $NewAzADUser = New-AzureADUser @AzUserParams
            Write-Host "[$iUP of $count] Success New AzureADUser: $($NewAzADUser.DisplayName)" -ForegroundColor Green
            [PSCustomObject]@{
                ResultNew                 = 'SUCCESS'
                ResultSet                 = 'SUCCESS'
                Name                      = $ConvertedAz.DisplayName
                DisplayName               = $NewAzADUser.DisplayName
                SourceType                = $ConvertedAz.Type
                MicrosoftOnlineServicesID = ''
                UserPrincipalName         = $NewAzADUser.UserPrincipalName
                PrimarySMTPAddress        = ''
                Alias                     = ($ConvertedAz.AzureADUPN -split '@')[0]
                SourceExchangeGuid        = ''
                TargetExchangeGuid        = ''
                SourceId                  = $ConvertedAz.ExternalDirectoryObjectId
                TargetId                  = $NewAzADUser.ObjectId
                Password                  = $GeneratedPW
                TargetEmailAddresses      = ''
                Log                       = 'SUCCESS'
            }
        }
        catch {
            [PSCustomObject]@{
                ResultNew                 = 'FAILED'
                ResultSet                 = 'FAILED'
                Name                      = $ConvertedAz.DisplayName
                DisplayName               = $ConvertedAz.DisplayName
                SourceType                = $ConvertedAz.Type
                MicrosoftOnlineServicesID = ''
                UserPrincipalName         = $ConvertedAz.UserPrincipalName
                PrimarySMTPAddress        = ''
                Alias                     = ($ConvertedAz.AzureADUPN -split '@')[0]
                SourceExchangeGuid        = ''
                TargetExchangeGuid        = ''
                SourceId                  = $ConvertedAz.ExternalDirectoryObjectId
                TargetId                  = ''
                Password                  = $GeneratedPW
                TargetEmailAddresses      = ''
                Log                       = $_.Exception.Message
            }
            Write-Host "[$iUP of $count] Failed New AzureADUser: $($ConvertedAz.DisplayName)" -ForegroundColor Red
        }
    }
    $ErrorActionPreference = 'continue'
}
