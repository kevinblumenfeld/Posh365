function Invoke-SetMailboxMoveForward {
    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant,

        [Parameter(Mandatory, ParameterSetName = 'CSV')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCSV
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                    Tenant        = $Tenant
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat | Where-Object { $_.ForwardingAddress -or $_.ForwardingSmtpAddress }
            }
            'CSV' {
                $CSVSplat = @{
                    MailboxCSV = $MailboxCSV
                }
                $UserChoice = Import-MailboxCsvDecision @CSVSplat | Where-Object { $_.ForwardingAddress -or $_.ForwardingSmtpAddress }
            }
        }
        if ($UserChoice -ne 'Quit' ) {
            foreach ($User in $UserChoice) {
                $SetSplat = @{
                    warningaction = 'silentlycontinue'
                    ErrorAction   = 'Stop'
                    Identity      = $User.UserPrincipalName
                    Confirm       = $false
                    Force         = $true
                }
                switch ($User) {
                    { $_.ForwardingAddress } { $SetSplat.Add('ForwardingAddress', $_.ForwardingAddress) }
                    { $_.ForwardingSmtpAddress } { $SetSplat.Add('ForwardingSmtpAddress', $_.ForwardingSmtpAddress) }
                    { $_.ForwardingRecipientType } { $SetSplat.Add('ForwardingRecipientType', $_.ForwardingRecipientType) }
                    { $_.DeliverToMailboxAndForward } { $SetSplat.Add('DeliverToMailboxAndForward', $_.DeliverToMailboxAndForward) }
                    Default { }
                }
                try {
                    Set-Mailbox @SetSplat
                    [PSCustomObject]@{
                        DisplayName = $User.DisplayName
                        Result      = 'SUCCESS'
                        Identity    = $User.UserPrincipalName
                        Forward     = @($User.ForwardingAddress, $User.ForwardingSmtpAddress).where{ $_ } -join '|'
                        Log         = 'SUCCESS'
                        Action      = 'SET'
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $User.DisplayName
                        Result      = 'FAILED'
                        Identity    = $User.UserPrincipalName
                        Forward     = @($User.ForwardingAddress, $User.ForwardingSmtpAddress).where{ $_ } -join '|'
                        Log         = $_.Exception.Message
                        Action      = 'SET'
                    }
                }
            }
        }
    }
}
