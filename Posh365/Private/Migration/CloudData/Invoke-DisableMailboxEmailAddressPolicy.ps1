function Invoke-DisableMailboxEmailAddressPolicy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Choice,

        [Parameter(Mandatory)]
        $Hash
    )
    $i = 0
    $Count = $Choice.Count
    foreach ($item in $Choice) {
        $AfterSuccess = $null
        $i++
        try {
            Set-RemoteMailbox -Identity $Item.Guid -EmailAddressPolicyEnabled:$false -ErrorAction Stop
            Write-Host ('[{0} of {1}] {2} Success Disabling EAP - All emails unchanged? ' -f $i, $Count, $item.DisplayName) -ForegroundColor Green -NoNewline
            $AfterSuccess = Get-RemoteMailbox -Identity $item.Guid -ErrorAction Stop
            $AllAddressesUnchanged = $Hash[$item.Guid]['AllEmailAddresses'] -eq (@($AfterSuccess.EmailAddresses) -ne '' -join '|')
            if ($AllAddressesUnchanged) {
                Write-Host $AllAddressesUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
            }
            else {
                Write-Host $AllAddressesUnchanged -ForegroundColor Black -BackgroundColor Yellow
            }

            [PSCustomObject]@{
                Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'SUCCESS'
                Action                        = 'EAPDISABLED'
                PrimarySmtpAddressUnchanged   = $Hash[$item.Guid]['PrimarySmtpAddress'] -eq $AfterSuccess.PrimarySmtpAddress
                AllEmailsUnchanged            = $AllAddressesUnchanged
                DisplayName                   = $AfterSuccess.DisplayName
                CurrentPolicyEnabled          = $AfterSuccess.EmailAddressPolicyEnabled
                PreviousPolicyEnabled         = $Hash[$item.Guid]['EmailAddressPolicyEnabled']
                OrganizationalUnit            = $AfterSuccess.OnPremisesOrganizationalUnit
                Alias                         = $AfterSuccess.Alias
                CurrentPrimarySmtpAddress     = $AfterSuccess.PrimarySmtpAddress
                PreviousPrimarySmtpAddress    = $Hash[$item.Guid]['PrimarySmtpAddress']
                EmailCountChange              = $AfterSuccess.EmailAddresses.Count - $Hash[$item.Guid]['EmailCount']
                CurrentEmailCount             = $AfterSuccess.EmailAddresses.Count
                PreviousEmailCount            = $Hash[$item.Guid]['EmailCount']
                CurrentEmailAddresses         = @($AfterSuccess.EmailAddresses) -match 'smtp:' -join '|'
                PreviousEmailAddresses        = $Hash[$item.Guid]['EmailAddresses']
                CurrentEmailAddressesNotSmtp  = @($AfterSuccess.EmailAddresses) -notmatch 'smtp:' -join '|'
                PreviousEmailAddressesNotSmtp = $Hash[$item.Guid]['EmailAddressesNotSmtp']
                Guid                          = $AfterSuccess.Guid.ToString()
                Log                           = 'SUCCESS'
            }
        }
        catch {
            Write-Host ('[{0} of {1}] {2} Failed Disabling EAP Error: {3}' -f $i, $Count, $item.DisplayName, $_.Exception.Message) -ForegroundColor Red
            [PSCustomObject]@{
                Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'FAILED'
                Action                        = 'EAPDISABLED'
                PrimarySmtpAddressUnchanged   = 'FAILED'
                AllEmailsUnchanged            = 'FAILED'
                DisplayName                   = $Hash[$item.Guid]['DisplayName']
                CurrentPolicyEnabled          = 'FAILED'
                PreviousPolicyEnabled         = $Hash[$item.Guid]['EmailAddressPolicyEnabled']
                OrganizationalUnit            = 'FAILED'
                Alias                         = 'FAILED'
                CurrentPrimarySmtpAddress     = 'FAILED'
                PreviousPrimarySmtpAddress    = $Hash[$item.Guid]['PrimarySmtpAddress']
                EmailCountChange              = 'FAILED'
                CurrentEmailCount             = 'FAILED'
                PreviousEmailCount            = $Hash[$item.Guid]['EmailCount']
                CurrentEmailAddresses         = 'FAILED'
                PreviousEmailAddresses        = $Hash[$item.Guid]['EmailAddresses']
                CurrentEmailAddressesNotSmtp  = 'FAILED'
                PreviousEmailAddressesNotSmtp = $Hash[$item.Guid]['EmailAddressesNotSmtp']
                Guid                          = 'FAILED'
                Log                           = $_.Exception.Message
            }
        }
    }
}
