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

        [Parameter()]
        [string] $Domain,

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
                                $_.Id -like '*@group.calendar.google.com' -and
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
                                FullNameError   = 'SUCCESS'
                                Message         = 'SUCCESS'
                                ExtendedMessage = 'SUCCESS'

                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8

                            if ($OwnersOnly) {
                                $AclList = Get-GSCalendarAcl -CalendarId $Owned.Id -ErrorAction SilentlyContinue | Where-Object {
                                    $_.Role -eq 'Owner' -and
                                    $_.Scope.type -ne 'domain'
                                }
                            }
                            else {
                                $AclList = Get-GSCalendarAcl -CalendarId $Owned.Id -ErrorAction SilentlyContinue
                            }
                            foreach ($Acl in $AclList) {
                                $ScopeType = $Acl | Select-Object @{n = 'Type'; e = {$_.Scope.Type}}
                                $ScopeValue = $Acl | Select-Object @{n = 'Value'; e = {$_.Scope.Value}}


                                if ($Remove) {
                                    $Acl | Remove-GSCalendarAcl -Confirm:$false -ErrorAction SilentlyContinue > $null
                                }

                                [PSCustomObject]@{
                                    Object     = 'ACL'
                                    Calendar   = $Owned.User
                                    User       = $Acl.User
                                    ScopeType  = $ScopeType.Type
                                    ScopeValue = $ScopeValue.Value
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
                            Result          = 'FAILED'
                            Action          = 'FINDCALENDAR'
                            User            = $Object.User
                            ETag            = 'FAILED'
                            Id              = 'FAILED'
                            Kind            = 'FAILED'
                            Summary         = 'FAILED'
                            Description     = 'FAILED'
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
        Import-Csv $Log | Out-GridView -Title "SUCCESS OR FAILURE LOG WHEN RUNNING Get-GSCalendar"
    }

}
