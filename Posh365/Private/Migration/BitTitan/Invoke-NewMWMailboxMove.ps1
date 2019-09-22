function Invoke-NewMWMailboxMove {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $UseTenantAddressAsSource

        # [Parameter()]
        # $TargetEmailSuffix
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
            if ($UseTenantAddressAsSource) {
                $Param.Add('ExportEmailAddress', $User.SourceTenantAddress)
            }
            else {
                $Param.Add('ExportEmailAddress', $User.SourcePrimary)
            }
            <#
            switch ($User) {
                { $_.SourceTenantAddress } { $Param.Add('ImportEmailAddress', $User.TargetTenantAddress) }
                { Default } { $Param.Add('ImportEmailAddress', '{0}@{1}' -f (($User.PrimarySmtpAddress -split '@')[0], $TargetEmailSuffix)) }
            }
            #>
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
