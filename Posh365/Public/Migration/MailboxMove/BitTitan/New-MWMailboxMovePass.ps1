function New-MWMailboxMovePass {
    [CmdletBinding()]
    param (

    )
    end {
        $MailboxChoice = Invoke-GetMWMailboxMove | Invoke-NewMWMailboxStatsandNoStats | Out-GridView -Title "Choose the users for whom to begin a Migration Move Pass" -OutputMode Multiple
        [int]$NumberofDays = Get-NumberOfDaysDecision
        if ($NumberofDays) {
            $ItemTypes = Get-MwItemType
        }
        if ($ItemTypes) {
            $ContinueDecision = Get-ContinueDecision
            if ($ContinueDecision -and $MailboxChoice) {
                $Value = [MigrationProxy.WebApi.MailboxItemTypes]::Mail
                # $Total = $Value -bor [MigrationProxy.WebApi.MailboxItemTypes]::Calendar
                $PassHash = @{
                    ItemTypes    = $Value
                    NumberofDays = $NumberofDays
                }
                $MailboxChoice | Invoke-NewMWMailboxMovePass @PassHash | Out-GridView -Title "Results of New Mailbox Move Pass"
            }
        }
    }
}
