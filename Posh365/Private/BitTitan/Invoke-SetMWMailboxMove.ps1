function Invoke-SetMWMailboxMove {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList
    )
    begin {

    }
    process {
        foreach ($User in $UserList) {
            $Param = @{
                Ticket             = $MigWizTicket
                ImportEmailAddress = $User.TargetTenantAddress
                ConnectorId        = $MWProject.Id
            }
            if ($UsePrimaryasSource) {
                $Param.Add('ExportEmailAddress', $User.SourcePrimary)
            }
            else {
                $Param.Add('ExportEmailAddress', $User.SourceTenantAddress)
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
                        'Source'      = $User.SourceTenantAddrress
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
                Write-Host "$($User.DisplayName) is missing source address" -ForegroundColor White
            }
        }
    }
}
