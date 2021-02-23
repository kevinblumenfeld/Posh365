function Get-PSGCalendar {
    <#
    .SYNOPSIS
    Gets All users calendars in Google Workspace

    .DESCRIPTION
    Gets All users calendars in Google Workspace

    .EXAMPLE
    Get-PSGCalendar | Export-Csv .\Calendars.csv -notypeinformation

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    Param (

    )

    $UserList = Get-GSUser -filter *

    foreach ($User in $UserList) {

        $CalendarList = Get-GSCalendar -User $User.User

        foreach ($Calendar in $CalendarList) {

            [PSCustomObject]@{
                User          = $User.User
                CalendarName  = $Calendar.Summary
                AssignedUser  = $Calendar.User
                CalendarEmail = $Calendar.Id
                AccessRole    = $Calendar.AccessRole
                Hidden        = $Calendar.Hidden
                Primary       = $Calendar.Primary
            }
        }
    }
}
