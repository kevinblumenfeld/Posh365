Add-Type -AssemblyName System.Web
function New-TestUser {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Start
    Parameter description

    .PARAMETER OU
    Parameter description

    .PARAMETER Count
    Parameter description

    .PARAMETER MailContact
    Parameter description

    .PARAMETER AzUser
    Parameter description

    .PARAMETER CloudOnlyMailbox
    Parameter description

    .PARAMETER RemoteMailbox
    Parameter description

    .PARAMETER MailboxOnPrem
    Parameter description

    .PARAMETER MailUser
    Parameter description

    .PARAMETER Prefix
    Parameter description

    .PARAMETER Domain
    Parameter description

    .PARAMETER SecondaryAddressCount
    Parameter description

    .PARAMETER SecondaryAddressPrefix
    Parameter description

    .PARAMETER Password
    Parameter description

    .PARAMETER PasswordLength
    Parameter description

    .PARAMETER UseEmailAddressPolicy
    Parameter description

    .PARAMETER AddAdditionalEmails
    Parameter description

    .EXAMPLE
    New-TestUser -Start 20 -AddAdditionalEmails -SecondaryAddressCount 2 -SecondaryAddressPrefix smtp

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Start,

        [Parameter()]
        $OU,

        [Parameter()]
        $Count = 1,

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
        $MailboxOnPrem,

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
        $Password,

        [Parameter()]
        $PasswordLength = 10,

        [Parameter()]
        [switch]
        $UseEmailAddressPolicy,

        [Parameter()]
        [switch]
        $AddAdditionalEmails
    )

    if ($Domain) { $Dom = $Domain }
    else { $Dom = ((Get-AcceptedDomain) | Where-Object { $_.InitialDomain }).DomainName }

    if (-not $Password) {
        $Password = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, 3)
    }
    $ConPass = ConvertTo-SecureString -String $Password -Force -AsPlainText


    $LicenseList = [System.Collections.Generic.List[string]]::New()
    $SubTotal = $Start + $Count
    if ($Count -eq 0) { $Total = $SubTotal }
    else { $Total = $SubTotal - 1 }
    foreach ($i in ($Start..($Total))) {
        $NewOnPrem, $NewMC, $NewMEU, $NewAz, $NewRM = $null
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
                Password                  = $ConPass
                ExternalEmailAddress      = 'kevin@thenext.net'
            }
            $NewMEU = New-MailUser @MeuParams
            Write-Host "[$i of $Total] MailUser :`t$($NewMEU.DisplayName)" -ForegroundColor Green
            if ($SecondaryAddressCount -and $NewMEU) {
                foreach ($Secondary in (1..$SecondaryAddressCount)) {
                    $CalculatedAddress = ('{0}:{1}{2:d3}{3}@{4}' -f $SecondaryAddressPrefix, $prefix, $i, (Get-Random -Minimum 100 -Maximum 999), $Dom)
                    $NewMEU | Set-MailUser -EmailAddresses @{Add = $CalculatedAddress }
                    Write-Host "[$i of $Total] Secondary $Secondary :`t$CalculatedAddress" -ForegroundColor Cyan
                }
            }
        }
        if ($AzUser) {
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $ConPass
            $UPN = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
            $AzUserParams = @{
                DisplayName       = '{0}{1:d3}' -f $prefix, $i
                UserPrincipalName = $UPN
                MailNickName      = '{0}{1:d3}' -f $prefix, $i
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
            }
            New-AzureADUser @AzUserParams > $null
            Write-Host "[$i of $Total] AzureADUser:`t$UPN" -ForegroundColor DarkCyan
        }
        if ($RemoteMailbox) {
            if (-not $Domain) {
                Write-Host "Please rerun with -Domain parameter" -ForegroundColor Red
                break
            }
            $UPN = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
            $RMParams = @{
                DisplayName        = '{0}{1:d3}' -f $prefix, $i
                Name               = '{0}{1:d3}' -f $prefix, $i
                UserPrincipalName  = $UPN
                PrimarySMTPAddress = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                SamAccountName     = '{0}{1:d3}' -f $prefix, $i
                Alias              = '{0}{1:d3}' -f $prefix, $i
                Password           = $ConPass
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
        if ($MailboxOnPrem) {
            if (-not $Domain) {
                Write-Host "Please rerun with -Domain parameter" -ForegroundColor Red
                continue
            }
            $UPN = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
            $OnPremParams = @{
                DisplayName       = '{0}{1:d3}' -f $prefix, $i
                Name              = '{0}{1:d3}' -f $prefix, $i
                UserPrincipalName = $UPN
                SamAccountName    = '{0}{1:d3}' -f $prefix, $i
                Alias             = '{0}{1:d3}' -f $prefix, $i
                Password          = $ConPass
            }
            if ($OU) {
                $OnPremParams['OrganizationalUnit'] = $OU
            }
            if (-not $UseEmailAddressPolicy) {
                $OnPremParams['PrimarySMTPAddress'] = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
            }
            $NewOnPrem = New-Mailbox @OnPremParams
            Write-Host "[$i of $Total] MailboxOnPremises:`t$($NewOnPrem.DisplayName)" -ForegroundColor DarkCyan
            if ($SecondaryAddressCount -and $NewOnPrem) {
                foreach ($Secondary in (1..$SecondaryAddressCount)) {
                    $CalculatedAddress = ('{0}:{1}{2:d3}{3}@{4}' -f $SecondaryAddressPrefix, $prefix, $i, (Get-Random -Minimum 100 -Maximum 999), $Dom)
                    $NewOnPrem | Set-Mailbox -EmailAddresses @{Add = $CalculatedAddress }
                    Write-Host "[$i of $Total] Secondary $Secondary :`t$CalculatedAddress" -ForegroundColor Cyan
                }
            }
        }
        if ($CloudOnlyMailbox) {
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $ConPass
            $UPN = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
            $AzUserParams = @{
                DisplayName       = '{0}{1:d3}' -f $prefix, $i
                UserPrincipalName = $UPN
                MailNickName      = '{0}{1:d3}' -f $prefix, $i
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
            }
            New-AzureADUser @AzUserParams > $null
            $LicenseList.Add($UPN)
            Write-Host "[$i of $Total] AzureADUserToBeLicensed:`t$UPN" -ForegroundColor DarkCyan
        }
    }
    if (@($LicenseList).count -gt 0) {
        $LicenseList | Set-CloudLicense -AddOptions
    }
    if ($AddAdditionalEmails) {
        $i = 0
        $RecipientList = Get-Recipient -ResultSize Unlimited | Select-Object DisplayName, RecipientTypeDetails, PrimarySmtpAddress | Out-GridView -Title "Add email addresses" -OutputMode Multiple
        $Total = @($RecipientList).count
        foreach ($Recipient in $RecipientList) {
            $i++
            if ($Recipient.RecipientTypeDetails -like '*Mailbox') {
                foreach ($Secondary in (1..$SecondaryAddressCount)) {
                    $CalculatedAddress = ('{0}:{1}{2:d3}{3}@{4}' -f $SecondaryAddressPrefix, $prefix, $i, (Get-Random -Minimum 100 -Maximum 999), $Dom)
                    Set-Mailbox -Identity $Recipient.PrimarySmtpAddress -EmailAddresses @{Add = $CalculatedAddress }
                    Write-Host "[$i of $Total] Secondary $Secondary :`t$CalculatedAddress" -ForegroundColor Cyan
                }
            }
            if ($Recipient.RecipientTypeDetails -eq 'MailUser') {
                foreach ($Secondary in (1..$SecondaryAddressCount)) {
                    $CalculatedAddress = ('{0}:{1}{2:d3}{3}@{4}' -f $SecondaryAddressPrefix, $prefix, $i, (Get-Random -Minimum 100 -Maximum 999), $Dom)
                    Set-MailUser -Identity $Recipient.PrimarySmtpAddress -EmailAddresses @{Add = $CalculatedAddress }
                    Write-Host "[$i of $Total] Secondary $Secondary :`t$CalculatedAddress" -ForegroundColor Cyan
                }
            }
        }
    }
}
