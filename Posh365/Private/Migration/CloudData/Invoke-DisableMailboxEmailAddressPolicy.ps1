function Invoke-DisableMailboxEmailAddressPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Choice,

        [Parameter(Mandatory)]
        $Hash,

        [Parameter()]
        [switch]
        $CheckADeap,

        [Parameter(Mandatory)]
        [string]
        $DomainController
    )
    $i = 0
    $Count = @($Choice).Count
    if ($CheckADeap) {
        foreach ($item in $Choice) {
            $AllAddressesUnchanged, $ADAfter, $AfterSuccess = $null
            $i++
            try {
                Set-RemoteMailbox -DomainController $DomainController -Identity $Item.Guid.ToString() -EmailAddressPolicyEnabled:$false -ErrorAction Stop
                Write-Host ('[{0} of {1}] {2} Success Disabling EAP - All emails unchanged? ' -f $i, $Count, $item.DisplayName) -ForegroundColor Green -NoNewline
                $AfterSuccess = Get-RemoteMailbox -DomainController $DomainController -Identity $Item.Guid.ToString() -ErrorAction Stop
                $ADAfter = Get-ADUser -server $DomainController -Identity $Item.Guid.ToString() -Properties msExchPoliciesIncluded, msExchPoliciesExcluded
                $AllAddressesUnchanged = $Hash[$Item.Guid.ToString()]['AllEmailAddresses'] -eq (@($AfterSuccess.EmailAddresses) -ne '' -join '|')
                if ($AllAddressesUnchanged) {
                    Write-Host $AllAddressesUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
                }
                else {
                    Write-Host $AllAddressesUnchanged -ForegroundColor Black -BackgroundColor Yellow
                }

                [PSCustomObject]@{
                    Num                           = '[{0} of {1}]' -f $i, $Count
                    Result                        = 'SUCCESS'
                    Action                        = 'EAPDISABLED'
                    PrimarySmtpAddressUnchanged   = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress'] -eq $AfterSuccess.PrimarySmtpAddress
                    AllEmailsUnchanged            = $AllAddressesUnchanged
                    msExchPoliciesIncluded        = @($ADAfter.msExchPoliciesIncluded) -ne '' -join '|'
                    msExchPoliciesExcluded        = @($ADAfter.msExchPoliciesExcluded) -ne '' -join '|'
                    DisplayName                   = $AfterSuccess.DisplayName
                    CurrentPolicyEnabled          = $AfterSuccess.EmailAddressPolicyEnabled
                    PreviousPolicyEnabled         = $Hash[$Item.Guid.ToString()]['EmailAddressPolicyEnabled']
                    OrganizationalUnit            = $AfterSuccess.OnPremisesOrganizationalUnit
                    Alias                         = $AfterSuccess.Alias
                    CurrentPrimarySmtpAddress     = $AfterSuccess.PrimarySmtpAddress
                    PreviousPrimarySmtpAddress    = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress']
                    EmailCountChange              = $AfterSuccess.EmailAddresses.Count - $Hash[$Item.Guid.ToString()]['EmailCount']
                    CurrentEmailCount             = $AfterSuccess.EmailAddresses.Count
                    PreviousEmailCount            = $Hash[$Item.Guid.ToString()]['EmailCount']
                    CurrentEmailAddresses         = @($AfterSuccess.EmailAddresses) -match 'smtp:' -join '|'
                    PreviousEmailAddresses        = $Hash[$Item.Guid.ToString()]['EmailAddresses']
                    CurrentEmailAddressesNotSmtp  = @($AfterSuccess.EmailAddresses) -notmatch 'smtp:' -join '|'
                    PreviousEmailAddressesNotSmtp = $Hash[$Item.Guid.ToString()]['EmailAddressesNotSmtp']
                    Guid                          = $AfterSuccess.Guid.ToString()
                    Log                           = 'SUCCESS'
                }
            }
            catch {
                Write-Host ('[{0} of {1}] {2} Failed Disabling EAP Error: {3}' -f $i, $Count, $item.DisplayName, $_.Exception.Message) -ForegroundColor Red
                [PSCustomObject]@{
                    Num                           = '[{0} of {1}]' -f $i, $Count
                    Result                        = 'FAILED'
                    Action                        = 'EAPDISABLED'
                    PrimarySmtpAddressUnchanged   = 'FAILED'
                    AllEmailsUnchanged            = 'FAILED'
                    msExchPoliciesIncluded        = 'FAILED'
                    msExchPoliciesExcluded        = 'FAILED'
                    DisplayName                   = $Hash[$Item.Guid.ToString()]['DisplayName']
                    CurrentPolicyEnabled          = 'FAILED'
                    PreviousPolicyEnabled         = $Hash[$Item.Guid.ToString()]['EmailAddressPolicyEnabled']
                    OrganizationalUnit            = 'FAILED'
                    Alias                         = 'FAILED'
                    CurrentPrimarySmtpAddress     = 'FAILED'
                    PreviousPrimarySmtpAddress    = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress']
                    EmailCountChange              = 'FAILED'
                    CurrentEmailCount             = 'FAILED'
                    PreviousEmailCount            = $Hash[$Item.Guid.ToString()]['EmailCount']
                    CurrentEmailAddresses         = 'FAILED'
                    PreviousEmailAddresses        = $Hash[$Item.Guid.ToString()]['EmailAddresses']
                    CurrentEmailAddressesNotSmtp  = 'FAILED'
                    PreviousEmailAddressesNotSmtp = $Hash[$Item.Guid.ToString()]['EmailAddressesNotSmtp']
                    Guid                          = 'FAILED'
                    Log                           = $_.Exception.Message
                }
            }
        }
    }
    else {
        foreach ($item in $Choice) {
            $AllAddressesUnchanged, $AfterSuccess = $null
            $i++
            try {
                Set-RemoteMailbox -DomainController $DomainController -Identity $Item.Guid.ToString() -EmailAddressPolicyEnabled:$false -ErrorAction Stop
                Write-Host ('[{0} of {1}] {2} Success Disabling EAP - All emails unchanged? ' -f $i, $Count, $item.DisplayName) -ForegroundColor Green -NoNewline
                $AfterSuccess = Get-RemoteMailbox -DomainController $DomainController -Identity $Item.Guid.ToString() -ErrorAction Stop
                $AllAddressesUnchanged = $Hash[$Item.Guid.ToString()]['AllEmailAddresses'] -eq (@($AfterSuccess.EmailAddresses) -ne '' -join '|')
                if ($AllAddressesUnchanged) {
                    Write-Host $AllAddressesUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
                }
                else {
                    Write-Host $AllAddressesUnchanged -ForegroundColor Black -BackgroundColor Yellow
                }
                [PSCustomObject]@{
                    Num                           = '[{0} of {1}]' -f $i, $Count
                    Result                        = 'SUCCESS'
                    Action                        = 'EAPDISABLED'
                    PrimarySmtpAddressUnchanged   = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress'] -eq $AfterSuccess.PrimarySmtpAddress
                    AllEmailsUnchanged            = $AllAddressesUnchanged
                    DisplayName                   = $AfterSuccess.DisplayName
                    CurrentPolicyEnabled          = $AfterSuccess.EmailAddressPolicyEnabled
                    PreviousPolicyEnabled         = $Hash[$Item.Guid.ToString()]['EmailAddressPolicyEnabled']
                    OrganizationalUnit            = $AfterSuccess.OnPremisesOrganizationalUnit
                    Alias                         = $AfterSuccess.Alias
                    CurrentPrimarySmtpAddress     = $AfterSuccess.PrimarySmtpAddress
                    PreviousPrimarySmtpAddress    = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress']
                    EmailCountChange              = $AfterSuccess.EmailAddresses.Count - $Hash[$Item.Guid.ToString()]['EmailCount']
                    CurrentEmailCount             = $AfterSuccess.EmailAddresses.Count
                    PreviousEmailCount            = $Hash[$Item.Guid.ToString()]['EmailCount']
                    CurrentEmailAddresses         = @($AfterSuccess.EmailAddresses) -match 'smtp:' -join '|'
                    PreviousEmailAddresses        = $Hash[$Item.Guid.ToString()]['EmailAddresses']
                    CurrentEmailAddressesNotSmtp  = @($AfterSuccess.EmailAddresses) -notmatch 'smtp:' -join '|'
                    PreviousEmailAddressesNotSmtp = $Hash[$Item.Guid.ToString()]['EmailAddressesNotSmtp']
                    Guid                          = $AfterSuccess.Guid.ToString()
                    Log                           = 'SUCCESS'
                }
            }
            catch {
                Write-Host ('[{0} of {1}] {2} Failed Disabling EAP Error: {3}' -f $i, $Count, $item.DisplayName, $_.Exception.Message) -ForegroundColor Red
                [PSCustomObject]@{
                    Num                           = '[{0} of {1}]' -f $i, $Count
                    Result                        = 'FAILED'
                    Action                        = 'EAPDISABLED'
                    PrimarySmtpAddressUnchanged   = 'FAILED'
                    AllEmailsUnchanged            = 'FAILED'
                    DisplayName                   = $Hash[$Item.Guid.ToString()]['DisplayName']
                    CurrentPolicyEnabled          = 'FAILED'
                    PreviousPolicyEnabled         = $Hash[$Item.Guid.ToString()]['EmailAddressPolicyEnabled']
                    OrganizationalUnit            = 'FAILED'
                    Alias                         = 'FAILED'
                    CurrentPrimarySmtpAddress     = 'FAILED'
                    PreviousPrimarySmtpAddress    = $Hash[$Item.Guid.ToString()]['PrimarySmtpAddress']
                    EmailCountChange              = 'FAILED'
                    CurrentEmailCount             = 'FAILED'
                    PreviousEmailCount            = $Hash[$Item.Guid.ToString()]['EmailCount']
                    CurrentEmailAddresses         = 'FAILED'
                    PreviousEmailAddresses        = $Hash[$Item.Guid.ToString()]['EmailAddresses']
                    CurrentEmailAddressesNotSmtp  = 'FAILED'
                    PreviousEmailAddressesNotSmtp = $Hash[$Item.Guid.ToString()]['EmailAddressesNotSmtp']
                    Guid                          = 'FAILED'
                    Log                           = $_.Exception.Message
                }
            }
        }
    }
}
