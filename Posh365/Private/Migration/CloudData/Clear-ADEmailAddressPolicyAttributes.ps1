function Clear-ADEmailAddressPolicyAttributes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Choice,

        [Parameter(Mandatory)]
        $Hash,

        [Parameter()]
        $BadPolicyHash,

        [Parameter(Mandatory)]
        [string]
        $DomainController
    )
    $i = 0
    $Count = @($Choice).Count
    foreach ($Item in $Choice) {
        $ADAfter, $RMAfter = $null
        $i++
        try {
            $UserParams = @{
                Server                    = $DomainController
                Identity                  = $Item.Guid.ToString()
                ErrorAction               = 'Stop'
                Clear                     = 'msExchPoliciesIncluded', 'msExchPoliciesExcluded'
            }
            Set-ADUser @UserParams
            Write-Host ('[{0} of {1}] {2} Success clearing msExchPoliciesIncluded and msExchPoliciesExcluded - All emails unchanged? ' -f $i, $Count, $Item.DisplayName) -ForegroundColor Green -NoNewline
            $ADAfter = Get-ADUser -server $DomainController -Identity $Item.Guid.ToString() -Properties msExchPoliciesIncluded, msExchPoliciesExcluded
            $RMAfter = Get-RemoteMailbox -DomainController $DomainController -Identity $Item.Guid.ToString()

            $AllAddressesUnchanged = $Hash[$Item.Guid.ToString()]['AllEmailAddresses'] -eq (@($RMAfter.EmailAddresses) -ne '' -join '|')
            if ($AllAddressesUnchanged) {
                Write-Host $AllAddressesUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
            }
            else {
                Write-Host $AllAddressesUnchanged -ForegroundColor Black -BackgroundColor Yellow
            }

            [PSCustomObject]@{
                Num                            = '[{0} of {1}]' -f $i, $Count
                Result                         = 'SUCCESS'
                Action                         = 'EAPCLEARPOLICIES'
                PrimarySmtpAddressUnchanged    = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress'] -eq $RMAfter.PrimarySmtpAddress
                AllEmailsUnchanged             = $AllAddressesUnchanged
                DisplayName                    = $RMAfter.DisplayName
                msExchPoliciesIncluded         = $ADAfter.msExchPoliciesIncluded
                msExchPoliciesExcluded         = $ADAfter.msExchPoliciesExcluded
                PreviousmsExchPoliciesIncluded = $BadPolicyHash[$Item.Guid.ToString()]['msExchPoliciesIncluded']
                PreviousmsExchPoliciesExcluded = $BadPolicyHash[$Item.Guid.ToString()]['msExchPoliciesExcluded']
                CurrentPolicyEnabled           = $RMAfter.EmailAddressPolicyEnabled
                PreviousPolicyEnabled          = $Hash[$Item.Guid.ToString()]['EmailAddressPolicyEnabled']
                OrganizationalUnit             = $RMAfter.OnPremisesOrganizationalUnit
                Alias                          = $RMAfter.Alias
                CurrentPrimarySmtpAddress      = $RMAfter.PrimarySmtpAddress
                PreviousPrimarySmtpAddress     = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress']
                EmailCountChange               = $RMAfter.EmailAddresses.Count - $Hash[$Item.Guid.ToString()]['EmailCount']
                CurrentEmailCount              = $RMAfter.EmailAddresses.Count
                PreviousEmailCount             = $Hash[$Item.Guid.ToString()]['EmailCount']
                CurrentEmailAddresses          = @($RMAfter.EmailAddresses) -match 'smtp:' -join '|'
                PreviousEmailAddresses         = $Hash[$Item.Guid.ToString()]['EmailAddresses']
                CurrentEmailAddressesNotSmtp   = @($RMAfter.EmailAddresses) -notmatch 'smtp:' -join '|'
                PreviousEmailAddressesNotSmtp  = $Hash[$Item.Guid.ToString()]['EmailAddressesNotSmtp']
                Guid                           = $RMAfter.Guid.ToString()
                Log                            = 'SUCCESS'
            }
        }
        catch {
            Write-Host ('[{0} of {1}] {2} Failed clearing msExchPoliciesIncluded and msExchPoliciesExcluded: {3}' -f $i, $Count, $Item.DisplayName, $_.Exception.Message) -ForegroundColor Red
            [PSCustomObject]@{
                Num                            = '[{0} of {1}]' -f $i, $Count
                Result                         = 'FAILED'
                Action                         = 'EAPCLEARPOLICIES'
                PrimarySmtpAddressUnchanged    = 'FAILED'
                AllEmailsUnchanged             = 'FAILED'
                DisplayName                    = $Hash[$Item.Guid.ToString()]['DisplayName']
                msExchPoliciesIncluded         = 'FAILED'
                msExchPoliciesExcluded         = 'FAILED'
                PreviousmsExchPoliciesIncluded = $BadPolicyHash[$Item.Guid.ToString()]['msExchPoliciesIncluded']
                PreviousmsExchPoliciesExcluded = $BadPolicyHash[$Item.Guid.ToString()]['msExchPoliciesExcluded']
                CurrentPolicyEnabled           = 'FAILED'
                PreviousPolicyEnabled          = $Hash[$Item.Guid.ToString()]['EmailAddressPolicyEnabled']
                OrganizationalUnit             = 'FAILED'
                Alias                          = 'FAILED'
                CurrentPrimarySmtpAddress      = 'FAILED'
                PreviousPrimarySmtpAddress     = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress']
                EmailCountChange               = 'FAILED'
                CurrentEmailCount              = 'FAILED'
                PreviousEmailCount             = $Hash[$Item.Guid.ToString()]['EmailCount']
                CurrentEmailAddresses          = 'FAILED'
                PreviousEmailAddresses         = $Hash[$Item.Guid.ToString()]['EmailAddresses']
                CurrentEmailAddressesNotSmtp   = 'FAILED'
                PreviousEmailAddressesNotSmtp  = $Hash[$Item.Guid.ToString()]['EmailAddressesNotSmtp']
                Guid                           = 'FAILED'
                Log                            = $_.Exception.Message
            }
        }
    }
}
