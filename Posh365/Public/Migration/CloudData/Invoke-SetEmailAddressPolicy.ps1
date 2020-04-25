function Invoke-SetEmailAddressPolicy {

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
        try {
            Set-RemoteMailbox -Identity $Item.Guid -EmailAddressPolicyEnabled:$false -ErrorAction Stop
            Write-Host ('[{0} of {1}] {2}' -f $i, $Count, $item.DisplayName) -ForegroundColor Green
            $AfterSuccess = Get-RemoteMailbox -Identity $item.Guid
            [PSCustomObject]@{
                Count                        = '[{0} of {1}]' -f $i, $Count
                Result                       = 'SUCCESS'
                DisplayName                  = $AfterSuccess.DisplayName
                EmailAddressPolicyEnabled    = $AfterSuccess.EmailAddressPolicyEnabled
                PreviousEAPEnabled           = $Hash[$item.Guid]['EmailAddressPolicyEnabled']
                OnPremisesOrganizationalUnit = $AfterSuccess.OnPremisesOrganizationalUnit
                Alias                        = $AfterSuccess.Alias
                PrimarySmtpAddress           = $AfterSuccess.PrimarySmtpAddress
                PreviousPrimary              = $Hash[$item.Guid]['PrimarySmtpAddress']
                EmailCount                   = $AfterSuccess.EmailAddresses.Count
                EmailAddresses               = @($AfterSuccess.EmailAddresses) -match 'smtp:' -join '|'
                EmailAddressesNotSmtp        = @($AfterSuccess.EmailAddresses) -notmatch 'smtp:' -join '|'
                Guid                         = $AfterSuccess.Guid.ToString()
                Log                          = 'SUCCESS'
            }
        }
        catch {
            Write-Host ('[{0} of {1}] {2} Error: {3}' -f $i, $Count, $item.DisplayName, $_.Exception.Message) -ForegroundColor Red
        }

    }



}
