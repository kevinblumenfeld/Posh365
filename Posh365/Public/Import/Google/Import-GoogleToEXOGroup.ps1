
function Import-GoogleToEXOGroup {
    <#
    .SYNOPSIS
    Import CSV of Google Groups into Office 365 as Distribution Groups

    .DESCRIPTION
    Import CSV of Google Groups into Office 365 as Distribution Groups

    .PARAMETER CsvLogPath
    The full path and file name of the log ex. c:\scripts\AddGroupsLog.csv (use csv for best results)

    .PARAMETER Group
    Google Group(s) and respective attributes

    .PARAMETER DontAddOwnersToManagedBy
    Google Group "Owners" will not be added Office 365's "ManagedBy"

    .PARAMETER DontAddManagersToManagedBy
    Google Group "Managers" will not be added Office 365's "ManagedBy"

    .PARAMETER DontCopyManagedByToMember
    Unless you use this switch, all in "ManagedBy" will become members of the Distribution Group

    .PARAMETER INVITED_CAN_JOIN_TranslatesTo
    If Google Group's "whoCanJoin" attribute contains the option INVITED_CAN_JOIN,
    the default behavior sets, "MemberJoinRestriction" to 'ApprovalRequired'.

    Use this parameter to override with either 'Open' or 'Closed'

    .PARAMETER CAN_REQUEST_TO_JOIN_TranslatesTo
    If Google Group's "whoCanJoin" attribute contains the option CAN_REQUEST_TO_JOIN,
    the default behavior sets, "MemberJoinRestriction" to 'ApprovalRequired'.

    Use this parameter to override with either 'Open' or 'Closed'

    .EXAMPLE
    Import-Csv C:\scripts\GoogleGroups.csv | Import-GoogleToEXOGroup | Export-Csv ./results.csv -nti -append

    .NOTES
    Choosing both -DontAddOwnersToManagedBy & -DontAddManagersToManagedBy results in
    the ManagedBy field being populated with the account that runs this script.

    The same is true if the Google Group has both no managers and no owners

    #>

    [CmdletBinding()]
    Param
    (

        [Parameter(Mandatory, ValueFromPipeline)]
        $Group,

        [Parameter()]
        [switch] $DontAddOwnersToManagedBy,

        [Parameter()]
        [switch] $SecurityGroup,

        [Parameter()]
        [switch] $DontAddManagersToManagedBy,

        [Parameter()]
        [switch] $DontCopyManagedByToMember,

        [Parameter()]
        [ValidateSet('Open', 'Closed')]
        [string] $INVITED_CAN_JOIN_TranslatesTo,

        [Parameter()]
        [ValidateSet('Open', 'Closed')]
        [string] $CAN_REQUEST_TO_JOIN_TranslatesTo,

        [Parameter()]
        [ValidateSet('MemberJoinRestrictionTo_Closed', 'MemberJoinRestrictionTo_ApprovalRequired', 'MemberJoinRestrictionTo_Open')]
        [string] $NONE_CAN_ADD_members_Overrides
    )
    begin {
        $MUHash = [System.Collections.Generic.Hashset[string]]::new()

        $MailUserList = Get-MailUser -ResultSize Unlimited

        foreach ($MailUser in $MailUserList) {

            $MUHash.Add($MailUser.PrimarySmtpAddress) > $null
        }

    }
    process {
        foreach ($CurGroup in $Group) {

            $Alias = ($CurGroup.Email.split('@'))[0]

            $ManagedBy = [System.Collections.Generic.Hashset[string]]::new()

            if (-not $DontAddManagersToManagedBy -and -not [string]::IsNullOrWhiteSpace($CurGroup.Managers)) {

                ########################
                #
                # Managers --> ManagedBy
                #
                ########################

                $CurGroup.Managers.split('|') | ForEach-Object {

                    if ($MUHash.Contains($_)) {

                        $ManagedBy.Add($_) > $null
                    }
                    else {

                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'FAILED'
                            Action          = 'FINDING_MANAGER_FOR_MANAGEDBY'
                            Object          = 'GROUP'
                            Name            = $CurGroup.Name
                            Email           = $CurGroup.Email
                            Message         = if ($_) { $_ } else { 'NO_DATA' }
                            ExtendedMessage = 'FAILED'
                        }
                    }
                }
            }

            if (-not $DontAddOwnersToManagedBy -and -not [string]::IsNullOrWhiteSpace($CurGroup.Owners)) {

                ########################
                #
                # Owners --> ManagedBy
                #
                ########################

                $CurGroup.Owners.split('|') | ForEach-Object {

                    if ($MUHash.Contains($_)) {

                        $ManagedBy.Add($_) > $null
                    }
                    else {

                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'FAILED'
                            Action          = 'FINDING_OWNER_FOR_MANAGEDBY'
                            Object          = 'GROUP'
                            Name            = $CurGroup.Name
                            Email           = $CurGroup.Email
                            Message         = if ($_) { $_ } else { 'NO_DATA' }
                            ExtendedMessage = 'FAILED'
                        }
                    }
                }

                # whoCanJoin
                if (-not $SecurityGroup) {

                    $MemberJoinRestriction = switch ($CurGroup.whoCanJoin) {
                        'ALL_IN_DOMAIN_CAN_JOIN' { 'Open' }
                        'ANYONE_CAN_JOIN' { 'Open' }
                        'CAN_REQUEST_TO_JOIN' {
                            if ($CAN_REQUEST_TO_JOIN_TranslatesTo) {
                                $CAN_REQUEST_TO_JOIN_TranslatesTo
                            }
                            else {
                                'ApprovalRequired'
                            }
                        }
                        'INVITED_CAN_JOIN' {
                            if ($INVITED_CAN_JOIN_TranslatesTo) {
                                $INVITED_CAN_JOIN_TranslatesTo
                            }
                            else {
                                'ApprovalRequired'
                            }
                        }
                    }
                }

                # When "whoCanAdd" is "NONE_CAN_ADD" this overrides any "MemberJoinRestriction"
                if ($NONE_CAN_ADD_members_Overrides -or -not $SecurityGroup) {

                    $MemberJoinRestriction = switch ($NONE_CAN_ADD_members_Overrides) {
                        'MemberJoinRestrictionTo_Closed' { 'Closed' }
                        'MemberJoinRestrictionTo_ApprovalRequired' { 'ApprovalRequired' }
                        'MemberJoinRestrictionTo_Open' { 'Open' }
                    }
                }
                # whoCanLeave
                if (-not $SecurityGroup) {

                    $MemberDepartRestriction = switch ($CurGroup.whoCanLeaveGroup) {
                        'ALL_MEMBERS_CAN_LEAVE' { 'Open' }
                        'ALL_MANAGERS_CAN_LEAVE' { 'Closed' }
                        'NONE_CAN_LEAVE' { 'Closed' }
                        Default { 'Open' }
                    }
                }

                $NewHash = @{
                    Name                    = $CurGroup.Name
                    DisplayName             = $CurGroup.Name
                    Alias                   = $Alias
                    PrimarySmtpAddress      = $CurGroup.Email
                    MemberJoinRestriction   = $MemberJoinRestriction
                    MemberDepartRestriction = $MemberDepartRestriction
                    Notes                   = $CurGroup.Description
                }

                if ($ManagedBy.count -ge 1) {

                    $NewHash['ManagedBy'] = $ManagedBy
                }
                # Are Owners and/or Managers copied to the Group's Membership?
                if ($DontCopyManagedByToMember) {

                    $NewHash['CopyOwnerToMember'] = $false
                }
                else {

                    $NewHash['CopyOwnerToMember'] = $true
                }

                $SetHash = @{

                    Identity = $CurGroup.Email
                }

                if ($CurGroup.includeInGlobalAddressList) {

                    $SetHash['HiddenFromAddressListsEnabled'] = -not [bool]::Parse($CurGroup.includeInGlobalAddressList)
                }

                # messageModerationLevel (A moderator approves messages sent to recipient before delivered)

                if ($CurGroup.messageModerationLevel -eq 'MODERATE_ALL_MESSAGES') {

                    ########################
                    #
                    # Owners --> ModeratedBy
                    #
                    ########################

                    $ModeratedBy = [System.Collections.Generic.Hashset[string]]::new()

                    $CurGroup.Owners.split('|') | ForEach-Object {

                        if ($MUHash.Contains($_)) {

                            $ModeratedBy.Add($_) > $null
                        }
                        else {

                            [PSCustomObject]@{
                                Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result          = 'FAILED'
                                Action          = 'FINDING_OWNER_FOR_MODERATEDBY'
                                Object          = 'GROUP'
                                Name            = $CurGroup.Name
                                Email           = $CurGroup.Email
                                Message         = if ($_) { $_ } else { 'NO_DATA' }
                                ExtendedMessage = 'FAILED'
                            }
                        }
                    }
                    $CurGroup.Managers.split('|') | ForEach-Object {

                        if ($MUHash.Contains($_)) {

                            $ModeratedBy.Add($_) > $null
                        }
                        else {

                            [PSCustomObject]@{
                                Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result          = 'FAILED'
                                Action          = 'FINDING_MANAGER_FOR_MODERATEDBY'
                                Object          = 'GROUP'
                                Name            = $CurGroup.Name
                                Email           = $CurGroup.Email
                                Message         = if ($_) { $_ } else { 'NO_DATA' }
                                ExtendedMessage = 'FAILED'
                            }
                        }
                    }
                }

                switch ($CurGroup.messageModerationLevel) {
                    'MODERATE_NONE' { $SetHash['ModerationEnabled'] = $false }
                    'MODERATE_ALL_MESSAGES' {
                        $SetHash['ModerationEnabled'] = $true
                        if ($ModeratedBy.count -ge 1) {
                            $SetHash['ModeratedBy'] = $ModeratedBy
                        }
                    }
                    'MODERATE_NON_MEMBERS' {
                        $SetHash['ModerationEnabled'] = $true
                        $SetHash['BypassModerationFromSendersOrMembers'] = $CurGroup.Email

                    }
                }

                switch ($CurGroup.sendMessageDenyNotification) {
                    'TRUE' { $SetHash['SendModerationNotifications'] = 'ALWAYS' }
                    'FALSE' { $SetHash['SendModerationNotifications'] = 'NEVER' }
                    Default { $SetHash['SendModerationNotifications'] = 'NEVER' }
                }

                # whoCanPostMessage (who can email the DL)
                switch ($CurGroup.whoCanPostMessage) {
                    'ANYONE_CAN_POST' { $SetHash['RequireSenderAuthenticationEnabled'] = $false }
                    'ALL_IN_DOMAIN_CAN_POST' { $SetHash['RequireSenderAuthenticationEnabled'] = $true }
                    'ALL_MANAGERS_CAN_POST' {
                        $SetHash['RequireSenderAuthenticationEnabled'] = $true
                        $SetHash['AcceptMessagesOnlyFromSendersOrMembers'] = $ManagedBy
                    }
                    'ALL_MEMBERS_CAN_POST' {
                        $SetHash['RequireSenderAuthenticationEnabled'] = $true
                        $SetHash['AcceptMessagesOnlyFromSendersOrMembers'] = $CurGroup.Email
                    }

                }

                # Create a splat with only parameters with values for New-DistributionGroup

                $NewSplat = @{ }

                foreach ($Key in $NewHash.keys) {

                    if ($NewHash.item($Key) -ne $null) {

                        $NewSplat.add($Key, $($NewHash.item($Key)))
                    }
                }
                if ($SecurityGroup) {

                    $NewSplat['Type'] = 'Security'
                }

                # Create a splat with only parameters with values for Set-DistributionGroup

                $SetSplat = @{ }

                foreach ($Key in $SetHash.keys) {
                    if ($SetHash.item($Key) -ne $null) {

                        $SetSplat.add($Key, $($SetHash.item($Key)))
                    }
                }

                try {

                    $NewDL = New-DistributionGroup @NewSplat -ErrorAction Stop

                    [PSCustomObject]@{
                        Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result          = 'SUCCESS'
                        Action          = 'CREATING'
                        Object          = 'GROUP'
                        Name            = $CurGroup.Name
                        Email           = $CurGroup.Email
                        Message         = 'SUCCESS'
                        ExtendedMessage = 'SUCCESS'
                    }

                    Write-HostLog -Message "Creating`t$($NewDL.Name)`t$($NewDL.PrimarySmtpAddress)" -Status "Success"

                    try {

                        Set-DistributionGroup @SetSplat -ErrorAction Stop -WarningAction SilentlyContinue

                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'SUCCESS'
                            Action          = 'SETTING'
                            Object          = 'GROUP'
                            Name            = $CurGroup.Name
                            Email           = $CurGroup.Email
                            Message         = 'SUCCESS'
                            ExtendedMessage = 'SUCCESS'
                        }

                        Write-HostLog -Message "Setting`t$($NewDL.Name)`t$($NewDL.PrimarySmtpAddress)" -Status "Success"

                    }
                    catch {

                        $Failure = $_.CategoryInfo.Reason
                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'FAILURE'
                            Action          = 'SETTING'
                            Object          = 'GROUP'
                            Name            = $CurGroup.Name
                            Email           = $CurGroup.Email
                            Message         = $Failure
                            ExtendedMessage = $_.Exception.Message
                        }

                        Write-HostLog -Message "Setting`t$($NewDL.Name)`t$($NewDL.PrimarySmtpAddress)" -Status "Failed"

                    }
                }
                catch {

                    $Failure = $_.CategoryInfo.Reason

                    if ($_ -match 'The email address') {

                        $Failure = "The email address $($CurGroup.Email) isn't correct"
                    }

                    if ($_ -match 'is already managed by recipient') {

                        $Failure = 'DL already managed by recipient'
                    }
                    [PSCustomObject]@{
                        Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result          = 'FAILURE'
                        Action          = 'CREATING'
                        Object          = 'GROUP'
                        Name            = $CurGroup.Name
                        Email           = $CurGroup.Email
                        Message         = $Failure
                        ExtendedMessage = $_.Exception.Message
                    }

                    Write-HostLog -Message "Creating`t$($CurGroup.Name)`t$Failure" -Status "Failed"

                }
            }
        }
    }
    end {
        Write-Host "Complete"
    }
}