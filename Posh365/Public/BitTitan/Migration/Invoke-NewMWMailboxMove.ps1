function Invoke-NewMWMailboxMove {
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
            $Param = @{
                Ticket             = $MigWizTicket
                ExportEmailAddress = $User.PrimarySmtpAddress
                ConnectorId        = $MWProject.Id
            }
            switch ($User) {
                { $_.TargetPrimarySmtpAddress } { $Param.Add('ImportEmailAddress', $User.TargetPrimarySmtpAddress) }
                Default { $Param.Add('ImportEmailAddress', '{0}@{1}' -f (($User.PrimarySmtpAddress -split '@')[0], $TargetEmailSuffix)) }
            }
            if ($Param.ImportEmailAddress) {
                try {
                    $Result = Add-MW_Mailbox @Param -WarningAction SilentlyContinue -ErrorAction Stop
                    [PSCustomObject]@{
                        'DisplayName' = $User.DisplayName
                        'Source'      = $Result.ExportEmailAddress
                        'Target'      = $Result.ImportEmailAddress
                        'Result'      = 'SUCCESS'
                        'Log'         = 'SUCCESS'
                        'Action'      = 'NEW'
                        'CreateDate'  = $Result.CreateDate
                        'Id'          = $Result.Id
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName' = $User.DisplayName
                        'Source'      = $User.PrimarySmtpAddress
                        'Target'      = $Param.ImportEmailAddress
                        'Result'      = 'FAILED'
                        'Log'         = $_.Exception.Message
                        'Action'      = 'NEW'
                        'CreateDate'  = ''
                        'Id'          = ''
                    }
                }
            }
        }
    }
}
