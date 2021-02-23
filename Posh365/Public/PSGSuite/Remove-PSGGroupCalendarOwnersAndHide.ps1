function Remove-PSGGroupCalendarOwnersAndHide {
    <#

    .SYNOPSIS
    If owner of a Group Calendar (those ending in @*.calendar.google.com)...

    1. Remove as Owner from Calendar, if not chosen by client in PrimaryOwnerFilePath

    2. Add as Editor to Calendar

    3. Hide Calendar if #1 and #2 does not work

    .DESCRIPTION
    If owner of a Group Calendar (those ending in @*.calendar.google.com)...

    1. Remove as Owner from Calendar, if not chosen by client in PrimaryOwnerFilePath

    2. Add as Editor to Calendar

    3. Hide Calendar if #1 and #2 does not work


    .PARAMETER PrimaryOwnerFilePath
    List of the client decisions of Calendar Owners

    Requires the following headers in the PrimaryOwnerACL.csv file:
        CalendarName
        AssignedUser
        CalendarEmail
        AccessRole
        PrimaryOwnerEmail

    .PARAMETER AllCalendarACLFilePath
    All Calendar Permissions

    Requires the following headers in the AllCalendarACL.csv file:
        User
        CalendarName
        AssignedUser
        CalendarEmail
        AccessRole
        Hidden
        Primary

    .EXAMPLE

    Get-PSGCalendar | Export-Csv .\AllCalendarPerms.csv -notypeinformation

    Remove-PSGGroupCalendarOwnersAndHide -PrimaryOwnerFilePath .\ClientFile.csv -AllCalendarACLFilePath .\AllCalendarPerms.csv | Export-Csv .\CalPermLog.csv -append -NoTypeInformation

    .NOTES

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        $PrimaryOwnerFilePath,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        $CalendarPermissionFilePath

    )

    $PrimaryHash = @{ }

    $PrimaryList = Import-Csv $PrimaryOwnerFilePath

    foreach ($Primary in $PrimaryList) {

        if ($Primary.PrimaryOwnerEmail -like "*@*") {

            $PrimaryHash[$Primary.CalendarEmail] = $Primary.PrimaryOwnerEmail
        }
    }

    $PermissionList = Import-Csv $CalendarPermissionFilePath

    foreach ($Permission in $PermissionList) {

        Write-Host "$($Permission.CalendarEmail) ROLE: $($Permission.AccessRole)" -foregroundcolor Cyan

        if ($Permission.CalendarEmail -like "*@*.calendar.google.com" -and $Permission.AccessRole -eq 'Owner') {

            Write-Host "OneOwner: $($PrimaryHash[$Permission.CalendarEmail])" -foregroundcolor Cyan
            Write-Host "AssignedUser: $($Permission.AssignedUser)" -foregroundcolor Cyan

            if ($PrimaryHash[$Permission.CalendarEmail] -and ($PrimaryHash[$Permission.CalendarEmail] -ne $Permission.AssignedUser)) {

                try {

                    $ACL = $null
                    $ACL = Get-GSCalendarAcl -CalendarId $Permission.CalendarEmail | Where-Object {
                        ($_.ID).split(':')[1] -eq $Permission.AssignedUser
                    }

                    $null = $ACL | Remove-GSCalendarAcl -ErrorAction 'Stop' -Confirm:$false

                    Write-Host "Removed $($Permission.AssignedUser) as owner from Calendar $($Permission.CalendarEmail)" -ForegroundColor Green

                    [PSCustomObject]@{
                        CalendarEmail = $Permission.CalendarEmail
                        CalendarName  = $Permission.CalendarName
                        RemovedUser   = $Permission.AssignedUser
                        AccessRole    = $Permission.AccessRole
                        Step          = 'REMOVEASOWNER'
                        Result        = 'SUCCESS'
                        Log           = 'SUCCESS'
                    }

                    try {

                        $NewSplat = @{
                            CalendarId  = $Permission.CalendarEmail
                            Role        = 'writer'
                            Value       = $Permission.AssignedUser
                            Type        = 'user'
                            ErrorAction = 'Stop'
                        }

                        $null = New-GSCalendarAcl @NewSplat

                        Write-Host "Added $($Permission.AssignedUser) as Editor to Calendar $($Permission.CalendarEmail)" -ForegroundColor Green

                        [PSCustomObject]@{
                            CalendarEmail = $Permission.CalendarEmail
                            CalendarName  = $Permission.CalendarName
                            RemovedUser   = $Permission.AssignedUser
                            AccessRole    = $Permission.AccessRole
                            Step          = 'ADDASEDITOR'
                            Result        = 'SUCCESS'
                            Log           = 'SUCCESS'

                        }

                        try {

                            $UpSplat = @{
                                User        = $Permission.AssignedUser
                                CalendarId  = $Permission.CalendarEmail
                                Hidden      = $true
                                ErrorAction = 'Stop'
                            }

                            $null = Update-GSCalendarSubscription @UpSplat

                            Write-Host "Hidden from user $($Permission.AssignedUser) the Calendar $($Permission.CalendarEmail)" -ForegroundColor Green

                            [PSCustomObject]@{
                                CalendarEmail = $Permission.CalendarEmail
                                CalendarName  = $Permission.CalendarName
                                RemovedUser   = $Permission.AssignedUser
                                AccessRole    = $Permission.AccessRole
                                Step          = 'HIDEFROMUSER'
                                Result        = 'SUCCESS'
                                Log           = 'SUCCESS'
                            }

                        }
                        catch {

                            Write-Host "Failed to hide from user $($Permission.AssignedUser) the Calendar $($Permission.CalendarEmail)" -ForegroundColor Red

                            [PSCustomObject]@{
                                CalendarEmail = $Permission.CalendarEmail
                                CalendarName  = $Permission.CalendarName
                                RemovedUser   = $Permission.AssignedUser
                                AccessRole    = $Permission.AccessRole
                                Step          = 'HIDEFROMUSER'
                                Result        = 'FAILED'
                                Log           = $_.Exception.Message
                            }

                        }
                    }
                    catch {

                        Write-Host "Failed to add $($Permission.AssignedUser) as Editor to Calendar $($Permission.CalendarEmail)" -ForegroundColor Red

                        [PSCustomObject]@{
                            CalendarEmail = $Permission.CalendarEmail
                            CalendarName  = $Permission.CalendarName
                            RemovedUser   = $Permission.AssignedUser
                            AccessRole    = $Permission.AccessRole
                            Step          = 'ADDASEDITOR'
                            Result        = 'FAILED'
                            Log           = $_.Exception.Message
                        }

                    }

                }
                catch {

                    Write-Host "Failed to remove $($Permission.AssignedUser) as owner from Calendar $($Permission.CalendarEmail)" -ForegroundColor Red

                    [PSCustomObject]@{
                        CalendarEmail = $Permission.CalendarEmail
                        CalendarName  = $Permission.CalendarName
                        RemovedUser   = $Permission.AssignedUser
                        AccessRole    = $Permission.AccessRole
                        Step          = 'REMOVEASOWNER'
                        Result        = 'FAILED'
                        Log           = $_.Exception.Message
                    }

                }
            }
        }
    }
}