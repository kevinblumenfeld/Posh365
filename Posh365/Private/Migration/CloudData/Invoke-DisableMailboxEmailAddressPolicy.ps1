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
        $i++
        try {
            Set-RemoteMailbox -Identity $Item.Guid -EmailAddressPolicyEnabled:$false -ErrorAction Stop
            Write-Host ('[{0} of {1}] {2} Primary Unchanged? ' -f $i, $Count, $item.DisplayName) -ForegroundColor Green -NoNewline
            $AfterSuccess = Get-RemoteMailbox -Identity $item.Guid -ErrorAction Stop
            $PrimaryUnchanged = $Hash[$item.Guid]['PrimarySmtpAddress'] -eq $AfterSuccess.PrimarySmtpAddress
            if ($PrimaryUnchanged) {
                Write-Host $PrimaryUnchanged -ForegroundColor Black -BackgroundColor Green
            }
            else {
                Write-Host $PrimaryUnchanged -ForegroundColor White -BackgroundColor Red
            }

            [PSCustomObject]@{
                Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'SUCCESS'
                PrimarySmtpAddressUnchanged   = $PrimaryUnchanged
                DisplayName                   = $AfterSuccess.DisplayName
                EmailAddressPolicyEnabled     = $AfterSuccess.EmailAddressPolicyEnabled
                PreviousEAPEnabled            = $Hash[$item.Guid]['EmailAddressPolicyEnabled']
                OnPremisesOrganizationalUnit  = $AfterSuccess.OnPremisesOrganizationalUnit
                Alias                         = $AfterSuccess.Alias
                PrimarySmtpAddress            = $AfterSuccess.PrimarySmtpAddress
                PreviousPrimary               = $Hash[$item.Guid]['PrimarySmtpAddress']
                EmailCount                    = $AfterSuccess.EmailAddresses.Count
                PreviousEmailCount            = $Hash[$item.Guid]['EmailCount']
                EmailAddresses                = @($AfterSuccess.EmailAddresses) -match 'smtp:' -join '|'
                PreviousEmailAddresses        = $Hash[$item.Guid]['EmailAddresses']
                EmailAddressesNotSmtp         = @($AfterSuccess.EmailAddresses) -notmatch 'smtp:' -join '|'
                PreviousEmailAddressesNotSmtp = $Hash[$item.Guid]['EmailAddressesNotSmtp']
                Guid                          = $AfterSuccess.Guid.ToString()
                Log                           = 'SUCCESS'
            }
        }
        catch {
            Write-Host ('[{0} of {1}] {2} Error: {3}' -f $i, $Count, $item.DisplayName, $_.Exception.Message) -ForegroundColor Red
            [PSCustomObject]@{
               Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'FAILED'
                PrimarySmtpAddressUnchanged   = 'FAILED'
                DisplayName                   = $Hash[$item.Guid]['DisplayName']
                EmailAddressPolicyEnabled     = 'FAILED'
                PreviousEAPEnabled            = $Hash[$item.Guid]['EmailAddressPolicyEnabled']
                OnPremisesOrganizationalUnit  = 'FAILED'
                Alias                         = 'FAILED'
                PrimarySmtpAddress            = 'FAILED'
                PreviousPrimary               = $Hash[$item.Guid]['PrimarySmtpAddress']
                EmailCount                    = 'FAILED'
                PreviousEmailCount            = $Hash[$item.Guid]['EmailCount']
                EmailAddresses                = 'FAILED'
                PreviousEmailAddresses        = $Hash[$item.Guid]['EmailAddresses']
                EmailAddressesNotSmtp         = 'FAILED'
                PreviousEmailAddressesNotSmtp = $Hash[$item.Guid]['EmailAddressesNotSmtp']
                Guid                          = 'FAILED'
                Log                          = $_.Exception.Message
            }
        }
    }
}
