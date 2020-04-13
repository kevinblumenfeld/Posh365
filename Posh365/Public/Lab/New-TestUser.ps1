function New-TestUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Start,

        [Parameter()]
        $Count = 10,

        [Parameter()]
        [switch]
        $SkipAzUser,

        [Parameter()]
        [switch]
        $SkipMailboxPrefixed,

        [Parameter()]
        [switch]
        $SkipMailUser,

        [Parameter()]
        $Prefix = 'Test',

        [Parameter()]
        $Domain
        )

    if ($Domain) {
        $Dom = $Domain
    }
    else {
        $Dom = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
    }
    $GeneratedPW = [System.Web.Security.Membership]::GeneratePassword(10, 3)
    $Pass = ConvertTo-SecureString -String $GeneratedPW -AsPlainText:$true -Force
    $LicenseList = [System.Collections.Generic.List[string]]::New()
    foreach ($i in ($Start..($Start + $Count))) {
        if (-not $SkipMailUser){
            $MeuParams = @{
                PrimarySmtpAddress        = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                Name                      = '{0}{1:d3}' -f $prefix, $i
                DisplayName               = '{0}{1:d3}' -f $prefix, $i
                MicrosoftOnlineServicesID = '{0}{1:d3}@{2}' -f $prefix, $i, $Dom
                Password                  = $pass
                ExternalEmailAddress      = 'kevin@thenext.net'
            }
            $meu = New-MailUser @MeuParams
            Write-Host "[$i of $Count] MailUser :`t$($Meu.DisplayName)" -ForegroundColor Green
        }

        if (-not $SkipAzUser) {
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $pass
            $AzUserParams = @{
                DisplayName       = '{0}Az{1:d3}' -f $prefix, $i
                UserPrincipalName = '{0}Az{1:d3}@{2}' -f $prefix, $i, $Dom
                MailNickName      = '{0}Az{1:d3}' -f $prefix, $i
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
            }
            $AzUser = New-AzureADUser @AzUserParams
            Write-Host "[$i of $Count] AzureUser:`t$($AzUser.DisplayName)" -ForegroundColor DarkCyan
        }
        if (-not $SkipMailboxPrefixed) {
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $pass
            $AzUserParams = @{
                DisplayName       = '{0}Mailbox{1:d3}' -f $prefix, $i
                UserPrincipalName = '{0}Mailbox{1:d3}@{2}' -f $prefix, $i, $Dom
                MailNickName      = '{0}Mailbox{1:d3}' -f $prefix, $i
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
            }
            $AzUser = New-AzureADUser @AzUserParams
            $LicenseList.Add($AzUser.UserPrincipalName)
            Write-Host "[$i of $Count] AzureUser:`t$($AzUser.DisplayName)" -ForegroundColor DarkCyan
        }
    }
    if ($LicenseList.count -gt 1) {
        $LicenseList | Set-CloudLicense -AddOptions
    }
}
