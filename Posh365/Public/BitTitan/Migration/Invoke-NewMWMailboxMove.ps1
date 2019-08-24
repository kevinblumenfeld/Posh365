function Invoke-NewMWMailboxMove {
    <#

    #>

    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter()]
        $TargetEmailSuffix
    )
    begin {

    }
    process {
        foreach ($User in $UserList) {
            Write-Host "USER: $($User.DisplayName)"
            $Param = @{
                Ticket             = $MWTicket
                ImportEmailAddress = $User.PrimarySmtpAddress
            }
            switch ($user.TargetPrimarySmtpAddress) {
                { $True } { $Param.Add('ExportEmailAddress', $User.TargetPrimarySmtpAddress) }
                { $False } { $Param.Add('ExportEmailAddress', '{0}@{1}' ) -f ($User.PrimarySmtpAddress -split '@')[0], $TargetEmailSuffix }
            }
            if ($Param.ExportEmailAddress) {
                try {
                    $Result = Add-MW_Mailbox @Param -WarningAction SilentlyContinue -ErrorAction Stop
                    [PSCustomObject]@{
                        'DisplayName'       = $User.DisplayName
                        'UserPrincipalName' = $User.PrimarySmtpAddress
                        'Result'            = 'SUCCESS'
                        'Log'               = $Result
                        'Action'            = 'NEW'
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName'       = $User.DisplayName
                        'UserPrincipalName' = $User.UserPrincipalName
                        'Result'            = 'FAILED'
                        'Log'               = $_.Exception.Message
                        'Action'            = 'NEW'
                    }
                }
            }
        }
    }
}
