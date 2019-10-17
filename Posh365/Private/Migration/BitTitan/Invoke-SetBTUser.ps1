function Invoke-SetBTUser {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList
    )
    begin {

    }
    process {
        foreach ($User in $UserList) {
            $Get = @{
                Ticket              = $BitTic
                PrimaryEmailAddress = $User.SourcePrimary
                WarningAction       = 'SilentlyContinue'
                ErrorAction         = 'Stop'
            }
            $Set = @{
                WarningAction = 'SilentlyContinue'
                ErrorAction   = 'Stop'
            }
            switch ($User) {
                { $_.FirstName } { $Set.Add('FirstName', $User.FirstName) }
                { $_.LastName } { $Set.Add('LastName', $User.LastName) }
                { $_.DisplayName } { $Set.Add('DisplayName', $User.DisplayName) }
                Default { }
            }
            if ($Get.PrimaryEmailAddress) {
                try {
                    $GetResult = Get-BT_CustomerEndUser @Get
                    Write-Host "User found`t: $($GetResult.PrimaryEmailAddress)" -ForegroundColor White
                    $Result = $GetResult | Set-BT_CustomerEndUser -Ticket $BitTic @Set
                    Write-Host "User set `t: $($GetResult.PrimaryEmailAddress)" -ForegroundColor Green
                    [PSCustomObject]@{
                        'DisplayName'        = '{0} {1}' -f $User.FirstName, $User.LastName
                        'PrimarySmtpAddress' = $Result.PrimaryEmailAddress
                        'UserPrincipalName'  = $Result.UserPrincipalName
                        'FirstName'          = $Result.FirstName
                        'LastName'           = $Result.LastName
                        'Result'             = 'SUCCESS'
                        'Log'                = 'SUCCESS'
                        'Action'             = 'SET'
                        'Updated'            = $Result.Updated.ToLocalTime()
                        'Id'                 = $Result.Id
                    }
                }
                catch {
                    [PSCustomObject]@{
                        'DisplayName'        = '{0} {1}' -f $User.FirstName, $User.LastName
                        'PrimarySmtpAddress' = $User.SourcePrimary
                        'UserPrincipalName'  = $User.UserPrincipalName
                        'FirstName'          = $User.FirstName
                        'LastName'           = $User.LastName
                        'Result'             = 'FAILED'
                        'Log'                = $_.Exception.Message
                        'Action'             = 'SET'
                        'Updated'            = ''
                        'Id'                 = ''
                    }
                }
            }
        }
    }
}
