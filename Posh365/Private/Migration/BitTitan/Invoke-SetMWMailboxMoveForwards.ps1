function Invoke-SetMWMailboxMoveForward {
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [switch]
        $DeliverAndForward
    )
    end {
        $DecisionObject = Invoke-GetMWMailboxMove | Select-Object @(
            @{
                Name       = 'Source'
                Expression = 'ExportEmailAddress'
            }
            @{
                Name       = 'Target'
                Expression = 'ImportEmailAddress'
            }
            @{
                Name       = 'Categories'
                Expression = { If ($_.Categories) { $StarColor[$_.Categories] } else { "" } }
            }
            'CreateDate'
            'Id'
        ) | Out-GridView -Title "MigrationWiz Mailbox Moves" -OutputMode Multiple
        if ($DecisionObject) {
            foreach ($Object in $DecisionObject) {
                $ForwardParams = @{ }
                switch ($true) {
                    { $Object.Source } { $ForwardParams.Add('Identity', $Object.Source) }
                    { $Object.Target } { $ForwardParams.Add('ForwardingSmtpAddress', $Object.Target) }
                    { $DeliverAndForward } { $ForwardParams.Add('DeliverToMailboxAndForward', $true) }
                    Default {
                        $ForwardParams.Add('DeliverToMailboxAndForward', $false )
                        $ForwardParams.Add('ErrorAction', 'stop')
                    }
                }
                try {
                    Set-Mailbox @ForwardParams
                    [PSCustomObject]@{
                        Source                     = $Object.Source
                        Forward                    = $Object.Target
                        DeliverToMailboxAndForward = [bool]$ForwardParams.DeliverToMailboxAndForward
                        Result                     = 'SUCCESS'
                        Log                        = 'SUCCESS'
                        Action                     = 'SET'
                    }
                }
                catch {
                    [PSCustomObject]@{
                        Source                     = $Object.Source
                        Forward                    = $Object.Target
                        DeliverToMailboxAndForward = [bool]$ForwardParams.DeliverToMailboxAndForward
                        Result                     = 'FAILED'
                        Log                        = $_.Exception.Message
                        Action                     = 'SET'
                    }
                }
            }
        }
    }
}
