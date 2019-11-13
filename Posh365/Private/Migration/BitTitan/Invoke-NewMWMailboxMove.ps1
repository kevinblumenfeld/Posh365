function Invoke-NewMWMailboxMove {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $UseTenantAddressAsSource,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $UseTargetPrimaryAsTarget
    )
    begin {

    }
    process {
        foreach ($User in $UserList) {
            $Param = @{
                Ticket      = $MigWizTicket
                ConnectorId = $MWProject.Id
            }
            if ($UseTenantAddressAsSource) {
                $Param.Add('ExportEmailAddress', $User.SourceTenantAddress)
            }
            else {
                $Param.Add('ExportEmailAddress', $User.PrimarySmtpAddress)
            }
            if ($UseTargetPrimaryAsTarget) {
                $Param.Add('ImportEmailAddress', $User.TargetPrimary)
            }
            else {
                $Param.Add('ImportEmailAddress', $User.TargetTenantAddress)
            }

            if ($Param.ExportEmailAddress) {
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
                        'Source'      = $User.SourceTenantAddress
                        'Target'      = $User.TargetTenantAddress
                        'Result'      = 'FAILED'
                        'Log'         = $_.Exception.Message
                        'Action'      = 'NEW'
                        'CreateDate'  = ''
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
                    'Log'         = 'MissingSourceAddress'
                    'Action'      = 'NEW'
                    'CreateDate'  = ''
                    'Id'          = ''
                }
            }
        }
    }
}
