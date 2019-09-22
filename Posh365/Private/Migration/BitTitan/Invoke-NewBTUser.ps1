function Invoke-NewBTUser {
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
                Ticket              = $BitTic
                PrimaryEmailAddress = $User.SourcePrimary
            }
            switch ($User) {
                { $_.FirstName } { $Param.Add('FirstName', $User.FirstName) }
                { $_.LastName } { $Param.Add('LastName', $User.LastName) }
                { $_.DisplayName } { $Param.Add('DisplayName', $User.DisplayName) }
                { $_.UserPrincipalName } { $Param.Add('UserPrincipalName', $User.UserPrincipalName) }
                Default { }
            }
            if ($Param.PrimaryEmailAddress) {
                try {
                    $Result = Add-BT_CustomerEndUser @Param -WarningAction SilentlyContinue -ErrorAction Stop
                    [PSCustomObject]@{
                        'DisplayName'        = '{0} {1}' -f $_.FirstName, $_.LastName
                        'PrimarySmtpAddress' = $Result.PrimaryEmailAddress
                        'UserPrincipalName'  = $Result.UserPrincipalName
                        'Result'             = 'SUCCESS'
                        'Log'                = 'SUCCESS'
                        'Action'             = 'NEW'
                        'CreateDate'         = $Result.Created.ToLocalTime()
                        'Id'                 = $Result.Id
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName'        = '{0} {1}' -f $_.FirstName, $_.LastName
                        'PrimarySmtpAddress' = $Result.PrimaryEmailAddress
                        'UserPrincipalName'  = $Result.UserPrincipalName
                        'Result'             = 'FAILED'
                        'Log'                = $_.Exception.Message
                        'Action'             = 'NEW'
                        'CreateDate'         = ''
                        'Id'                 = ''
                    }
                }
            }
        }
    }
}
