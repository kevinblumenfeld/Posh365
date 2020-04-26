function Invoke-SetmsExchVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Choice,

        [Parameter(Mandatory)]
        $Hash,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $VersionDecision
    )
    $i = 0
    $Count = $Choice.Count
    foreach ($item in $Choice) {
        $i++
        try {
            Set-ADUser -Identity $Item.Guid -Replace @{ msExchVersion = $Hash[$item.Guid]['msExchVersion'] } -ErrorAction Stop
            Write-Host ('[{0} of {1}] {2} Success modifying msExchVersion - PrimarySmtpAddress unchanged? ' -f $i, $Count, $item.DisplayName) -ForegroundColor Green -NoNewline
            $AfterSuccess = Get-ADUser -Identity $item.Guid -ErrorAction Stop
            $AfterSuccessRM = Get-RemoteMailbox -Identity $item.Guid -ErrorAction Stop
            $PrimaryUnchanged = $Hash[$item.Guid]['PrimarySmtpAddress'] -eq $AfterSuccess.PrimarySmtpAddress
            if ($PrimaryUnchanged) {
                Write-Host $PrimaryUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
            }
            else {
                Write-Host $PrimaryUnchanged -ForegroundColor Black -BackgroundColor Yellow
            }

            [PSCustomObject]@{
                Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'SUCCESS'
                Action                        = 'EAPDISABLED'
                PrimarySmtpAddressUnchanged   = $PrimaryUnchanged
                DisplayName                   = $AfterSuccess.DisplayName
                CurrentPolicyEnabled          = $AfterSuccess.EmailAddressPolicyEnabled
                PreviousPolicyEnabled         = $Hash[$item.Guid]['EmailAddressPolicyEnabled']
                OnPremisesOrganizationalUnit  = $AfterSuccess.OnPremisesOrganizationalUnit
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
            Write-Host ('[{0} of {1}] {2} Failed modifying msExchVersion Error: {3}' -f $i, $Count, $item.DisplayName, $_.Exception.Message) -ForegroundColor Red
            [PSCustomObject]@{
                Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'FAILED'
                Action                        = 'EAPDISABLED'
                PrimarySmtpAddressUnchanged   = 'FAILED'
                DisplayName                   = $Hash[$item.Guid]['DisplayName']
                CurrentPolicyEnabled          = 'FAILED'
                PreviousPolicyEnabled         = $Hash[$item.Guid]['EmailAddressPolicyEnabled']
                OnPremisesOrganizationalUnit  = 'FAILED'
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
