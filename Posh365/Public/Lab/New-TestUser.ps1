Add-Type -AssemblyName System.Web
function New-TestUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Start,

        [Parameter()]
        $OU,

        [Parameter()]
        $Count = 10,

        [Parameter()]
        [switch]
        $MailContact,

        [Parameter()]
        [switch]
        $AzUser,

        [Parameter()]
        [switch]
        $CloudOnlyMailbox,

        [Parameter()]
        [switch]
        $RemoteMailbox,

        [Parameter()]
        [switch]
        $MailUser,

        [Parameter()]
        $Prefix = 'Test',

        [Parameter()]
        $Domain,

        [Parameter()]
        [int]
        $SecondaryAddressCount,

        [Parameter()]
        [ValidateSet('smtp', 'x500')]
        $SecondaryAddressPrefix,

        [Parameter()]
        $PasswordLength = 10
    )

    if ($Domain) { $Dom = $Domain }
    else { $Dom = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName }

    $GeneratedPW = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, 3)
    $Pass = ConvertTo-SecureString -String $GeneratedPW -AsPlainText:$true -Force
    $LicenseList = [System.Collections.Generic.List[string]]::New()
    $Total = $Start + $Count
    foreach ($i in ($Start..($Total))) {
        $NewMC, $NewMEU, $NewAz, $NewRM = $null
        if ($MailContact) {
            $ContactParams = @{
                ExternalEmailAddress = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                Name                 = '{0}{1:d3}' -f $prefix, $i
                DisplayName          = '{0}{1:d3}' -f $prefix, $i
                Alias                = '{0}{1:d3}' -f $prefix, $i
            }
            if ($OU) {
                $ContactParams['OrganizationalUnit'] = $OU
            }
            $NewMC = New-MailContact @ContactParams
            Write-Host "[$i of $Total] MailContact :`t$($NewMC.DisplayName)" -ForegroundColor Green
            if ($SecondaryAddressCount -and $NewMC) {
                foreach ($Secondary in (1..$SecondaryAddressCount)) {
                    $CalculatedAddress = ('{0}:{1}{2:d3}{3}@{4}' -f $SecondaryAddressPrefix, $prefix, $i, (Get-Random -Minimum 100 -Maximum 999), $Dom)
                    $NewMC | Set-MailContact -EmailAddresses @{Add = $CalculatedAddress }
                    Write-Host "[$i of $Total] Secondary $Secondary :`t$CalculatedAddress" -ForegroundColor Cyan
                }
            }
        }
        if ($MailUser) {
            $MeuParams = @{
                PrimarySmtpAddress        = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                Name                      = '{0}{1:d3}' -f $prefix, $i
                DisplayName               = '{0}{1:d3}' -f $prefix, $i
                MicrosoftOnlineServicesID = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                Password                  = $pass
                ExternalEmailAddress      = 'kevin@thenext.net'
            }
            $NewMEU = New-MailUser @MeuParams
            Write-Host "[$i of $Total] MailUser :`t$($NewMEU.DisplayName)" -ForegroundColor Green
        }

        if ($AzUser) {
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $pass
            $AzUserParams = @{
                DisplayName       = '{0}{1:d3}' -f $prefix, $i
                UserPrincipalName = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                MailNickName      = '{0}{1:d3}' -f $prefix, $i
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
            }
            $NewAz = New-AzureADUser @AzUserParams
            Write-Host "[$i of $Total] AzureUser:`t$($NewAz.DisplayName)" -ForegroundColor DarkCyan
        }

        if ($RemoteMailbox) {
            $RMParams = @{
                DisplayName        = '{0}{1:d3}' -f $prefix, $i
                Name               = '{0}{1:d3}' -f $prefix, $i
                UserPrincipalName  = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                PrimarySMTPAddress = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                SamAccountName     = '{0}{1:d3}' -f $prefix, $i
                Alias              = '{0}{1:d3}' -f $prefix, $i
                Password           = $Pass
            }
            if ($OU) {
                $RMParams['OnPremisesOrganizationalUnit'] = $OU
            }
            $NewRM = New-RemoteMailbox @RMParams
            Write-Host "[$i of $Total] RemoteMailbox:`t$($NewRM.DisplayName)" -ForegroundColor DarkCyan
            if ($SecondaryAddressCount -and $NewRM) {
                foreach ($Secondary in (1..$SecondaryAddressCount)) {
                    $CalculatedAddress = ('{0}:{1}{2:d3}{3}@{4}' -f $SecondaryAddressPrefix, $prefix, $i, (Get-Random -Minimum 100 -Maximum 999), $Dom)
                    $NewRM | Set-RemoteMailbox -EmailAddresses @{Add = $CalculatedAddress }
                    Write-Host "[$i of $Total] Secondary $Secondary :`t$CalculatedAddress" -ForegroundColor Cyan
                }
            }
        }
        if ($CloudOnlyMailbox) {
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $pass
            $AzUserParams = @{
                DisplayName       = '{0}{1:d3}' -f $prefix, $i
                UserPrincipalName = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                MailNickName      = '{0}{1:d3}' -f $prefix, $i
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
            }
            $AzUser = New-AzureADUser @AzUserParams
            $LicenseList.Add($AzUser.UserPrincipalName)
            Write-Host "[$i of $Total] AzureUser:`t$($AzUser.DisplayName)" -ForegroundColor DarkCyan
        }
    }
    if ($LicenseList.count -gt 1) {
        $LicenseList | Set-CloudLicense -AddOptions
    }
}
