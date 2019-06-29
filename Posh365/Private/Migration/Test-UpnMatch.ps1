function Test-UpnMatch {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        $UserList
    )

    begin {
        $Result = [System.Collections.Generic.List[PSObject]]::New()
    }
    process {
        foreach ($User in $UserList) {
            $FilterString = "UserPrincipalName -eq '$($Change.UserPrincipalName)'"
            $ADUser = Get-ADUser -filter $FilterString
            If ($ADUser.PrimarySmtpAddress -ne $ADUser.PrimarySmtpAddress) {
                $Result.Add([PSCustomObject]@{
                        DisplayName        = $ADUser.DisplayName
                        Identity           = $User.UserPrincipalName
                        UserPrincipalName  = $ADUser.UserPrincipalName
                        PrimarySmtpAddress = $ADUser.PrimarySmtpAddress
                        BatchName          = $User.BatchName
                    })
            }
        }
    }
    end {

        $ChangeGrid = @{
            Title      = "Select the mailboxes to change UPN to match Primary SMTP and click OK?"
            OutputMode = 'Multiple'
        }

        $ChangeUPN = $Result | Out-GridView @ChangeGrid
        foreach ($Change in $ChangeUPN) {
            if ($Change.UserPrincipalName) {
                $FilterString = "UserPrincipalName -eq '$($Change.UserPrincipalName)'"
                Get-ADUser -filter $FilterString | Set-ADUser -UserPrincipalName $ChangeUPN.PrimarySmtpAddress
            }
        }
    }
}

