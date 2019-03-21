function Remove-GoogleCalendarACL {

    [CmdletBinding(DefaultParameterSetName = 'USER')]
    param(

        [Parameter(Position = 0, ParameterSetName = 'USER')]
        [string[]]
        $PrimarySmtpAddress,

        [Parameter(Mandatory = $true)]
        [String] $OutputPath,

        [Parameter()]
        [switch] $OwnersOnly,

        [Parameter()]
        [switch] $Remove,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'PIPELINE')]
        [Alias("InputObject")]
        [object[]]
        $User

    )
    begin {

        $LogFileName = $(Get-Date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-Remove_Google_Calendar_ACLs-Log.csv")

    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'USER' {
                foreach ($Object in $PrimarySmtpAddress) {
                    break
                    # Add this for later to remove acls for one mailbox/calendar at a time
                }
            }
            'PIPELINE' {
                if ($MyInvocation.ExpectingInput) {
                    $User = , $User
                }

                foreach ($Object in $User) {
                    try {
                        if ($OwnersOnly) {
                            $OwnedCalList = Get-GSCalendar -User $Object.User -ErrorAction Stop |
                                Where-Object {
                                $_.AccessRole -eq 'Owner' -and
                                $_.Primary -ne 'True'
                            }
                        }
                        else {
                            $OwnedCalList = Get-GSCalendar -User $Object.User -ErrorAction Stop
                        }


                        foreach ($Owned in $OwnedCalList) {
                            Write-Verbose ("SUCCESS: Found user {0} calendar {1} " -f $Object.User, $Owned.Id)
                            [PSCustomObject]@{
                                Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result          = 'SUCCESS'
                                Action          = 'FINDCALENDAR'
                                User            = $Owned.User
                                ETag            = $Owned.ETag
                                Id              = $Owned.Id
                                Kind            = $Owned.Kind
                                Summary         = $Owned.Summary
                                Description     = $Owned.Description
                                Owner           = 'SUCCESS'
                                FullNameError   = 'SUCCESS'
                                Message         = 'SUCCESS'
                                ExtendedMessage = 'SUCCEES'

                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8

                            if ($OwnersOnly) {
                                $AclList = (Get-GSCalendarAcl -CalendarId $Owned.Id -ErrorAction SilentlyContinue | Where-Object {
                                        $_.Role -eq 'Owner' -and
                                        $_.Scope.Value -ne $_.User -and
                                        $_.Scope.Value -notmatch 'calendar.google.com'
                                    })
                            }
                            else {
                                $AclList = Get-GSCalendarAcl -CalendarId $Owned.Id -ErrorAction SilentlyContinue
                            }
                            foreach ($Acl in $AclList) {
                                $Owner = $Acl | Select-Object @{n = 'Owner'; e = {$_.Scope.Value}}


                                if ($Remove) {
                                    $Acl | Remove-GSCalendarAcl -Confirm:$false -Verbose
                                }

                                [PSCustomObject]@{
                                    Calendar   = $Owned.User
                                    User       = $Acl.User
                                    Owner      = $Owner.Owner
                                    Summary    = $Owned.Summary
                                    CalendarId = $Acl.CalendarId
                                    ETag       = $Acl.ETag
                                    Id         = $Acl.Id
                                    Kind       = $Acl.Kind
                                    Role       = $Acl.Role
                                }

                            }
                        }
                    }
                    catch {
                        Write-Verbose ("FAILED: to find user {0}" -f $Object.User)
                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'SUCCESS'
                            Action          = 'FINDCALENDAR'
                            User            = $Object.User
                            ETag            = 'FAILED'
                            Id              = 'FAILED'
                            Kind            = 'FAILED'
                            Summary         = 'FAILED'
                            Description     = 'FAILED'
                            Owner           = 'FAILED'
                            FullNameError   = $_.Exception.GetType().fullname
                            Message         = $_.CategoryInfo.Reason
                            ExtendedMessage = $_.Exception.Message

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                }
            }
        }
    }
    end {

    }

}