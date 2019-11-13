function Invoke-SetMWMailboxMove {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $SwapSourcePrimaryWithSourceTenant,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $SwapSourceTenantWithSourcePrimary
    )
    begin {

    }
    process {
        foreach ($User in $UserList) {
            $GetParam = @{
                Ticket      = $MigWizTicket
                ConnectorId = $MWProject.Id
            }
            $SetParam = @{ }
            switch ($true) {
                $SwapSourcePrimaryWithSourceTenant {
                    $GetParam.Add('ExportEmailAddress', $User.PrimarySmtpAddress)
                    $SetParam.Add('ExportEmailAddress', $User.SourceTenantAddress)
                }
                $SwapSourceTenantWithSourcePrimary {
                    $GetParam.Add('ExportEmailAddress', $User.SourceTenantAddress)
                    $SetParam.Add('ExportEmailAddress', $User.PrimarySmtpAddress)
                }
                Default { }
            }
            if ($GetParam.ExportEmailAddress) {
                try {
                    $GetMailbox = Get-MW_Mailbox @GetParam -WarningAction SilentlyContinue -ErrorAction Stop -RetrieveAll:$true
                    [PSCustomObject]@{
                        'DisplayName' = $User.DisplayName
                        'Source'      = $GetMailbox.ExportEmailAddress
                        'Target'      = $GetMailbox.ImportEmailAddress
                        'Result'      = 'SUCCESS'
                        'Log'         = 'SUCCESS'
                        'Action'      = 'GET'
                        'CreateDate'  = $GetMailbox.CreateDate
                        'UpdateDate'  = $GetMailbox.UpdateDate
                        'Id'          = $GetMailbox.Id
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName' = $User.DisplayName
                        'Source'      = $User.SourceTenantAddress
                        'Target'      = $User.TargetTenantAddress
                        'Result'      = 'FAILED'
                        'Log'         = $_.Exception.Message
                        'Action'      = 'GET'
                        'CreateDate'  = ''
                        'UpdateDate'  = ''
                        'Id'          = ''
                    }
                }
                try {
                    $SetParam.Add('Ticket', $MigWizTicket)
                    $SetParam.Add('ConnectorId', $MWProject.Id)
                    $SetParam.Add('Mailbox', $GetMailbox)
                    $SetMailbox = Set-MW_Mailbox @SetParam -WarningAction SilentlyContinue -ErrorAction Stop
                    [PSCustomObject]@{
                        'DisplayName' = $User.DisplayName
                        'Source'      = $SetMailbox.ExportEmailAddress
                        'Target'      = $SetMailbox.ImportEmailAddress
                        'Result'      = 'SUCCESS'
                        'Log'         = 'SUCCESS'
                        'Action'      = 'SET'
                        'CreateDate'  = $SetMailbox.CreateDate
                        'UpdateDate'  = $SetMailbox.UpdateDate
                        'Id'          = $SetMailbox.Id
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName' = $User.DisplayName
                        'Source'      = $User.SourceTenantAddress
                        'Target'      = $User.TargetTenantAddress
                        'Result'      = 'FAILED'
                        'Log'         = $_.Exception.Message
                        'Action'      = 'SET'
                        'CreateDate'  = ''
                        'UpdateDate'  = ''
                        'Id'          = ''
                    }
                }
            }
            else {
                [PSCustomObject]@{
                    'DisplayName' = $User.DisplayName
                    'Source'      = $User.SourceTenantAddress
                    'Target'      = $User.TargetTenantAddress
                    'Result'      = 'FAILED'
                    'Log'         = 'MissingSourcePrimary'
                    'Action'      = 'SET'
                    'CreateDate'  = ''
                    'UpdateDate'  = ''
                    'Id'          = ''
                }
            }
        }
    }
}
