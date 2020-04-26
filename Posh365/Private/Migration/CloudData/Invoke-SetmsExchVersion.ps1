function Invoke-SetmsExchVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Choice,

        [Parameter(Mandatory)]
        $RMHash,

        [Parameter(Mandatory)]
        $UserHash,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $VersionDecision
    )
    $i = 0
    $Count = $Choice.Count
    foreach ($item in $Choice) {
        $i++
        try {
            Set-ADUser -Identity $Item.Guid -Replace @{ msExchVersion = $VersionDecision } -ErrorAction Stop
            Write-Host ('[{0} of {1}] {2} Success modifying msExchVersion - PrimarySmtpAddress unchanged? ' -f $i, $Count, $item.DisplayName) -ForegroundColor Green -NoNewline
            $AfterSuccessAD = Get-ADUser -Identity $item.Guid -Properties DisplayName, msExchVersion -ErrorAction Stop
            $AfterSuccessRM = Get-RemoteMailbox -Identity $item.Guid -ErrorAction Stop | Select-Object *
            $PrimaryUnchanged = $RMHash[$item.Guid]['PrimarySmtpAddress'] -eq $AfterSuccessRM.PrimarySmtpAddress
            if ($PrimaryUnchanged) {
                Write-Host $PrimaryUnchanged -ForegroundColor White -BackgroundColor DarkMagenta
            }
            else {
                Write-Host $PrimaryUnchanged -ForegroundColor Black -BackgroundColor Yellow
            }

            [PSCustomObject]@{
                Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'SUCCESS'
                Action                        = "SETMSEXCHVERSION ($VersionDecision)"
                CurrentmsExchVersion          = $AfterSuccessAD.msExchVersion.ToString()
                PreviousmsExchVersion         = $UserHash[$item.Guid]['msExchVersion'].ToString()
                PrimarySmtpAddressUnchanged   = $PrimaryUnchanged
                AllAddressesUnchanged         = $RMHash[$item.Guid]['AllEmailAddresses'] -eq (@($AfterSuccessRM.EmailAddresses) -ne '' -join '|')
                DisplayName                   = $AfterSuccessAD.DisplayName
                OnPremisesOrganizationalUnit  = $AfterSuccessRM.OnPremisesOrganizationalUnit
                Alias                         = $AfterSuccessRM.Alias
                CurrentPrimarySmtpAddress     = $AfterSuccessRM.PrimarySmtpAddress
                PreviousPrimarySmtpAddress    = $RMHash[$item.Guid]['PrimarySmtpAddress']
                EmailCountChange              = $AfterSuccessRM.EmailAddresses.Count - $RMHash[$item.Guid]['EmailCount']
                CurrentEmailCount             = $AfterSuccessRM.EmailAddresses.Count
                PreviousEmailCount            = $RMHash[$item.Guid]['EmailCount']
                CurrentEmailAddresses         = @($AfterSuccessRM.EmailAddresses) -match 'smtp:' -join '|'
                PreviousEmailAddresses        = $RMHash[$item.Guid]['EmailAddresses']
                CurrentEmailAddressesNotSmtp  = @($AfterSuccessRM.EmailAddresses) -notmatch 'smtp:' -join '|'
                PreviousEmailAddressesNotSmtp = $RMHash[$item.Guid]['EmailAddressesNotSmtp']
                Guid                          = $AfterSuccessAD.ObjectGUID.ToString()
                Log                           = 'SUCCESS'
            }
        }
        catch {
            Write-Host ('[{0} of {1}] {2} Failed modifying msExchVersion Error: {3}' -f $i, $Count, $item.DisplayName, $_.Exception.Message) -ForegroundColor Red
            [PSCustomObject]@{
                Count                         = '[{0} of {1}]' -f $i, $Count
                Result                        = 'FAILED'
                Action                        = "SETMSEXCHVERSION ($VersionDecision)"
                CurrentmsExchVersion          = 'FAILED'
                PreviousmsExchVersion         = $UserHash[$item.Guid]['msExchVersion'].ToString()
                PrimarySmtpAddressUnchanged   = 'FAILED'
                AllAddressesUnchanged         = 'FAILED'
                DisplayName                   = $RMHash[$item.Guid]['DisplayName']
                OnPremisesOrganizationalUnit  = 'FAILED'
                Alias                         = 'FAILED'
                CurrentPrimarySmtpAddress     = 'FAILED'
                PreviousPrimarySmtpAddress    = $RMHash[$item.Guid]['PrimarySmtpAddress']
                EmailCountChange              = 'FAILED'
                CurrentEmailCount             = 'FAILED'
                PreviousEmailCount            = $RMHash[$item.Guid]['EmailCount']
                CurrentEmailAddresses         = 'FAILED'
                PreviousEmailAddresses        = $RMHash[$item.Guid]['EmailAddresses']
                CurrentEmailAddressesNotSmtp  = 'FAILED'
                PreviousEmailAddressesNotSmtp = $RMHash[$item.Guid]['EmailAddressesNotSmtp']
                Guid                          = 'FAILED'
                Log                           = $_.Exception.Message
            }
        }
    }
}
