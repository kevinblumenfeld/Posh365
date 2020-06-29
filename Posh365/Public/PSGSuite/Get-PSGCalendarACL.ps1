function Get-PSGCalendarACL {
    [CmdletBinding()]
    Param (

    )
    $UserList = Get-GSUser -Filter *

    foreach ($User in $UserList) {
        $ACLList = Get-GSCalendarACL -User $User.User
        foreach ($ACL in $ACLList) {
            $Granted = $ACL.Id.replace('user:', '')
            if ($User.User -ne $Granted) {
                [PSCustomObject]@{
                    Name         = $User.Name.FullName
                    PrimaryEmail = $User.PrimaryEmail
                    User         = $ACL.User
                    CalendarId   = $ACL.CalendarId
                    Granted      = $Granted
                    Role         = $ACL.Role
                    ETag         = $ACL.ETag
                    Kind         = $ACL.Kind
                }
            }
        }
    }
}
