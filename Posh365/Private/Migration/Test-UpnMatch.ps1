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
            $Mailbox = Get-Mailbox -Identity $User.UserPrincipalName
            If ($Mailbox.PrimarySmtpAddress -ne $Mailbox.PrimarySmtpAddress) {
                $Result.Add([PSCustomObject]@{
                        DisplayName        = $Mailbox.DisplayName
                        Identity           = $User.UserPrincipalName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                        BatchName          = $User.Batch
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
            $FilterString = "UserPrincipalName -eq $Change.UserPrincipalName"
            Get-ADUser -filter $FilterString | Set-ADUser -UserPrincipalName $ChangeUPN.PrimarySmtpAddress
        }
    }
}

