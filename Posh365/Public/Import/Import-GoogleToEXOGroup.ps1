function Import-GoogleToEXOGroup {
    <#
    .SYNOPSIS
    Import CSV of Google Groups into Office 365 as Distribution Groups

    .DESCRIPTION
    Import CSV of Google Groups into Office 365 as Distribution Groups

    .PARAMETER Groups
    CSV of new groups and attributes to create.

    .EXAMPLE
    Import-Csv .\importgroups.csv | Import-EXOGroup


    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Groups
    )
    Begin {

    }
    Process {
        ForEach ($CurGroup in $Groups) {
            $Alias = ($CurGroup.Email -split "@")[0]
            $ManagedBy = [System.Collections.Generic.List[PSObject]]::new()

            if (-not $dontAddOwnersToManagedBy) {
                $CurGroup.Managers -split "`r`t" | ForEach-Object {
                    $ManagedBy.Add($_)
                }
            }
            if (-not $dontAddManagersToManagedBy) {
                $CurGroup.Owners -split "`r`t" | ForEach-Object {
                    $ManagedBy.Add($_)
                }
            }

            $NewHash = @{
                Name                               = $CurGroup.Name
                DisplayName                        = $CurGroup.DisplayName
                Alias                              = $Alias
                ManagedBy                          = $ManagedBy
                PrimarySmtpAddress                 = $CurGroup.Email

                BypassNestedModerationEnabled      = [bool]::Parse($CurGroup.BypassNestedModerationEnabled)
                IgnoreNamingPolicy                 = $CurGroup.IgnoreNamingPolicy
                MemberDepartRestriction            = $CurGroup.MemberDepartRestriction
                MemberJoinRestriction              = $CurGroup.MemberJoinRestriction
                ModerationEnabled                  = [bool]::Parse($CurGroup.ModerationEnabled)
                RequireSenderAuthenticationEnabled = [bool]::Parse($CurGroup.RequireSenderAuthenticationEnabled)
                SendModerationNotifications        = $CurGroup.SendModerationNotifications
            }
            $SetHash = @{
                Identity                          = $CurGroup.Email
                HiddenFromAddressListsEnabled     = -not [bool]::Parse($CurGroup.includeInGlobalAddressList)
                ReportToManagerEnabled            = [bool]::Parse($CurGroup.ReportToManagerEnabled)
                ReportToOriginatorEnabled         = [bool]::Parse($CurGroup.ReportToOriginatorEnabled)
                SendOofMessageToOriginatorEnabled = [bool]::Parse($CurGroup.SendOofMessageToOriginatorEnabled)
                SimpleDisplayName                 = $CurGroup.SimpleDisplayName
                WindowsEmailAddress               = $CurGroup.WindowsEmailAddress

            }

            $NewParams = @{}
            ForEach ($h in $NewHash.keys) {
                if ($($NewHash.item($h))) {
                    $NewParams.add($h, $($NewHash.item($h)))
                }
            }
            $SetParams = @{}
            ForEach ($h in $SetHash.keys) {
                if ($($SetHash.item($h))) {
                    $SetParams.add($h, $($SetHash.item($h)))
                }
            }

            New-DistributionGroup @NewParams
            Set-DistributionGroup @SetParams

            if ($CurGroup.AcceptMessagesOnlyFrom) {
                $CurGroup.AcceptMessagesOnlyFrom -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFrom @{Add = "$_"}
                }
            }
            if ($CurGroup.AcceptMessagesOnlyFromDLMembers) {
                $CurGroup.AcceptMessagesOnlyFromDLMembers -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFromDLMembers @{Add = "$_"}
                }
            }
            if ($CurGroup.BypassModerationFromSendersOrMembers) {
                $CurGroup.BypassModerationFromSendersOrMembers -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -BypassModerationFromSendersOrMembers @{Add = "$_"}
                }
            }
            if ($CurGroup.GrantSendOnBehalfTo) {
                $CurGroup.GrantSendOnBehalfTo -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -GrantSendOnBehalfTo @{Add = "$_"}
                }
            }
            if ($CurGroup.ManagedBy) {
                $CurGroup.ManagedBy -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ManagedBy @{Add = "$_"}
                }
            }
            if ($CurGroup.ModeratedBy) {
                $CurGroup.ModeratedBy -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ModeratedBy @{Add = "$_"}
                }
            }
            if ($CurGroup.RejectMessagesFrom) {
                $CurGroup.RejectMessagesFrom -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFrom @{Add = "$_"}
                }
            }
            if ($CurGroup.RejectMessagesFromDLMembers) {
                $CurGroup.RejectMessagesFromDLMembers -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromDLMembers @{Add = "$_"}
                }
            }
            if ($CurGroup.RejectMessagesFromSendersOrMembers) {
                $CurGroup.RejectMessagesFromSendersOrMembers -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromSendersOrMembers @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute1) {
                $CurGroup.ExtensionCustomAttribute1 -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute1 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute2) {
                $CurGroup.ExtensionCustomAttribute2 -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute2 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute3) {
                $CurGroup.ExtensionCustomAttribute3 -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute3 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute4) {
                $CurGroup.ExtensionCustomAttribute4 -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute4 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute5) {
                $CurGroup.ExtensionCustomAttribute5 -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute5 @{Add = "$_"}
                }
            }
            if ($CurGroup.MailTipTranslations) {
                $CurGroup.MailTipTranslations -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -MailTipTranslations @{Add = "$_"}
                }
            }
            if ($CurGroup.EmailAddresses) {
                $CurGroup.EmailAddresses -Split ";" | Where-Object {!($_ -clike "SMTP:*")} | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_"}
                }
            }
            if ($CurGroup.x500) {
                Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$($CurGroup.x500)"}
            }
            # Move to its own function!
            if ($CurGroup.membersSMTP) {
                $CurGroup.membersSMTP -Split ";" | ForEach-Object {
                    Add-DistributionGroupMember -Identity $CurGroup.Identity -member "$_"
                }
            }
        }
    }
    End {

    }
}
