function Update-GoogleCalendarACL {
    <#
    .SYNOPSIS
    Initially, report on Calendar ACLs from a list of Calendar IDs.
    Can remove all owners and add back a single owner

    .DESCRIPTION
    Report on Calendar ACLs from a list of Calendar IDs.

    .PARAMETER PrimarySmtpAddress
    Not implemented. Don't use.

    .PARAMETER OwnersOnly
    This will output owners of the calendar only.  And remove them if Remove switch is used.

    .PARAMETER Remove
    This will remove all with permissions to the calendar.  Either all with permissions or if "OwnersOnly", then just ownders are removed

    .PARAMETER AddBackSingleOwner
    Use this switch to add back the owner in the primaryemail column

    .PARAMETER OutputPath
    Where to output the logs. Two logs are output. One with current state and one with future state

    .PARAMETER OwnedList
    Passed at the pipeline

    .EXAMPLE
    Import-Csv .\CalendarIDs.csv | Update-GoogleCalendarACL -OwnersOnly -Remove -AddBackSingleOwner -OutputPath .\

    .NOTES
    CSV should contain at minimum
    One column with for example the calendarId of the calendar that is "owned":

    calendarId
    contoso.com_0fuabehee3gtr9k20vtci3gto@group.calendar.google.com

    To add back a single owner, include the column primaryEmail in your csv.

    primaryEmail     calendarId
    joe@contoso.com  contoso.com_0fuabehee3gtr9k20vtci3gto@group.calendar.google.com


    #>

    [CmdletBinding(DefaultParameterSetName = 'USER')]
    param(

        [Parameter(Position = 0, ParameterSetName = 'USER')]
        [string[]] $PrimarySmtpAddress,

        [Parameter()]
        [switch] $OwnersOnly,

        [Parameter()]
        [switch] $Remove,

        [Parameter()]
        [switch] $AddBackSingleOwner,

        [Parameter(Mandatory = $true)]
        [String] $OutputPath,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'PIPELINE')]
        [Alias("InputObject")]
        [object[]] $OwnedList

    )
    begin {

        $LogFileName = $(Get-Date -Format yyyy-MM-dd_HH-mm-ss)
        $LogCurrent = Join-Path $OutputPath ($LogFileName + " Current State Google ACLs.csv")
        $LogFuture = Join-Path $OutputPath ($LogFileName + " Future State OWNERS Google ACLs.csv")

    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'USER' {
                foreach ($Owned in $PrimarySmtpAddress) {
                    break
                    # Add this for later to remove acls for one mailbox/calendar at a time
                }
            }
            'PIPELINE' {
                if ($MyInvocation.ExpectingInput) {
                    $OwnedList = , $OwnedList
                }

                foreach ($Owned in $OwnedList) {
                    if ($OwnersOnly) {
                        $AclList = Get-GSCalendarAcl -CalendarId $Owned.CalendarId -ErrorAction SilentlyContinue | Where-Object {
                            $_.Role -eq 'Owner' -and
                            $_.Scope.type -ne 'domain'
                        }
                    }
                    else {
                        $AclList = Get-GSCalendarAcl -CalendarId $Owned.CalendarId -ErrorAction SilentlyContinue
                    }
                    foreach ($Acl in $AclList) {
                        $ScopeType = $Acl | Select-Object @{n = 'Type'; e = { $_.Scope.Type } }
                        $ScopeValue = $Acl | Select-Object @{n = 'Value'; e = { $_.Scope.Value } }


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
                        } | Export-Csv -Path $LogCurrent -NoTypeInformation -Append -Encoding UTF8
                    }

                    if ($AddBackSingleOwner) {
                        New-GSCalendarAcl -CalendarId $Owned.CalendarId -Role owner -Value $Owned.PrimaryEmail -Type user > $null
                    }

                    $AclList = Get-GSCalendarAcl -CalendarId $Owned.CalendarId -ErrorAction SilentlyContinue | Where-Object {
                        $_.Role -eq 'Owner' -and
                        $_.Scope.type -ne 'domain'
                    }
                    foreach ($Acl in $AclList) {
                        $ScopeType = $Acl | Select-Object @{n = 'Type'; e = { $_.Scope.Type } }
                        $ScopeValue = $Acl | Select-Object @{n = 'Value'; e = { $_.Scope.Value } }


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
                        } | Export-Csv -Path $LogFuture -NoTypeInformation -Append -Encoding UTF8
                    }

                }
            }
        }
    }
    end {
        Import-Csv $LogFuture | Out-GridView -Title "Current ACL's"
    }

}
