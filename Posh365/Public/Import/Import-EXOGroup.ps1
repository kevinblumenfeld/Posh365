function Import-EXOGroup {
    <#
    .SYNOPSIS
    Import Office 365 Distribution Groups

    .DESCRIPTION
    Import Office 365 Distribution Groups

    .PARAMETER Groups
    CSV of new groups and attributes to create.

    .EXAMPLE
    Import-Csv .\importgroups.csv | Import-EXOGroup


    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        $Groups
    )
    Begin {

    }
    Process {
        ForEach ($CurGroup in $Groups) {
            Write-Host "Group:`t $($CurGroup.Name)" -ForegroundColor Green
            $newhash = @{
                Alias                              = $CurGroup.Alias
                BypassNestedModerationEnabled      = [bool]::Parse($CurGroup.BypassNestedModerationEnabled)
                DisplayName                        = $CurGroup.DisplayName
                IgnoreNamingPolicy                 = $CurGroup.IgnoreNamingPolicy
                MemberDepartRestriction            = $CurGroup.MemberDepartRestriction
                MemberJoinRestriction              = $CurGroup.MemberJoinRestriction
                ModerationEnabled                  = [bool]::Parse($CurGroup.ModerationEnabled)
                Name                               = $CurGroup.Name
                Notes                              = $CurGroup.Notes
                PrimarySmtpAddress                 = $CurGroup.PrimarySmtpAddress
                RequireSenderAuthenticationEnabled = [bool]::Parse($CurGroup.RequireSenderAuthenticationEnabled)
                SendModerationNotifications        = $CurGroup.SendModerationNotifications
            }
            $sethash = @{
                CustomAttribute1                  = $CurGroup.CustomAttribute1
                CustomAttribute10                 = $CurGroup.CustomAttribute10
                CustomAttribute11                 = $CurGroup.CustomAttribute11
                CustomAttribute12                 = $CurGroup.CustomAttribute12
                CustomAttribute13                 = $CurGroup.CustomAttribute13
                CustomAttribute14                 = $CurGroup.CustomAttribute14
                CustomAttribute15                 = $CurGroup.CustomAttribute15
                CustomAttribute2                  = $CurGroup.CustomAttribute2
                CustomAttribute3                  = $CurGroup.CustomAttribute3
                CustomAttribute4                  = $CurGroup.CustomAttribute4
                CustomAttribute5                  = $CurGroup.CustomAttribute5
                CustomAttribute6                  = $CurGroup.CustomAttribute6
                CustomAttribute7                  = $CurGroup.CustomAttribute7
                CustomAttribute8                  = $CurGroup.CustomAttribute8
                CustomAttribute9                  = $CurGroup.CustomAttribute9
                HiddenFromAddressListsEnabled     = [bool]::Parse($CurGroup.HiddenFromAddressListsEnabled)
                Identity                          = $CurGroup.Identity
                ReportToManagerEnabled            = [bool]::Parse($CurGroup.ReportToManagerEnabled)
                ReportToOriginatorEnabled         = [bool]::Parse($CurGroup.ReportToOriginatorEnabled)
                SendOofMessageToOriginatorEnabled = [bool]::Parse($CurGroup.SendOofMessageToOriginatorEnabled)
                SimpleDisplayName                 = $CurGroup.SimpleDisplayName
                WindowsEmailAddress               = $CurGroup.WindowsEmailAddress

            }
            $newparams = @{ }
            ForEach ($h in $newhash.keys) {
                if ($($newhash.item($h))) {
                    $newparams.add($h, $($newhash.item($h)))
                }
            }
            $setparams = @{ }
            ForEach ($h in $sethash.keys) {
                if ($($sethash.item($h))) {
                    $setparams.add($h, $($sethash.item($h)))
                }
            }
            $type = $CurGroup.RecipientTypeDetails

            switch ( $type ) {
                MailUniversalDistributionGroup {
                    $newparams['Type'] = "Distribution"
                }
                MailNonUniversalGroup {
                    $newparams['Type'] = "Distribution"
                }
                MailUniversalSecurityGroup {
                    $newparams['Type'] = "Security"
                }
                RoomList {
                    $newparams['Roomlist'] = $true
                }
            }
            Write-Host "New:`t $($CurGroup.Name)" -ForegroundColor White
            New-DistributionGroup @newparams
            Write-Host "Set:`t $($CurGroup.Name)" -ForegroundColor Yellow
            Set-DistributionGroup @setparams

            if ($CurGroup.AcceptMessagesOnlyFrom) {
                $CurGroup.AcceptMessagesOnlyFrom -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFrom @{Add = "$_" }
                }
            }
            if ($CurGroup.AcceptMessagesOnlyFromDLMembers) {
                $CurGroup.AcceptMessagesOnlyFromDLMembers -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFromDLMembers @{Add = "$_" }
                }
            }
            if ($CurGroup.BypassModerationFromSendersOrMembers) {
                $CurGroup.BypassModerationFromSendersOrMembers -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -BypassModerationFromSendersOrMembers @{Add = "$_" }
                }
            }
            if ($CurGroup.GrantSendOnBehalfTo) {
                $CurGroup.GrantSendOnBehalfTo -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -GrantSendOnBehalfTo @{Add = "$_" }
                }
            }
            if ($CurGroup.ManagedBy) {
                $CurGroup.ManagedBy -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ManagedBy @{Add = "$_" }
                }
            }
            if ($CurGroup.ModeratedBy) {
                $CurGroup.ModeratedBy -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ModeratedBy @{Add = "$_" }
                }
            }
            if ($CurGroup.RejectMessagesFrom) {
                $CurGroup.RejectMessagesFrom -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFrom @{Add = "$_" }
                }
            }
            if ($CurGroup.RejectMessagesFromDLMembers) {
                $CurGroup.RejectMessagesFromDLMembers -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromDLMembers @{Add = "$_" }
                }
            }
            if ($CurGroup.RejectMessagesFromSendersOrMembers) {
                $CurGroup.RejectMessagesFromSendersOrMembers -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromSendersOrMembers @{Add = "$_" }
                }
            }
            if ($CurGroup.ExtensionCustomAttribute1) {
                $CurGroup.ExtensionCustomAttribute1 -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute1 @{Add = "$_" }
                }
            }
            if ($CurGroup.ExtensionCustomAttribute2) {
                $CurGroup.ExtensionCustomAttribute2 -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute2 @{Add = "$_" }
                }
            }
            if ($CurGroup.ExtensionCustomAttribute3) {
                $CurGroup.ExtensionCustomAttribute3 -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute3 @{Add = "$_" }
                }
            }
            if ($CurGroup.ExtensionCustomAttribute4) {
                $CurGroup.ExtensionCustomAttribute4 -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute4 @{Add = "$_" }
                }
            }
            if ($CurGroup.ExtensionCustomAttribute5) {
                $CurGroup.ExtensionCustomAttribute5 -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute5 @{Add = "$_" }
                }
            }
            if ($CurGroup.MailTipTranslations) {
                $CurGroup.MailTipTranslations -split [regex]::Escape('|') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -MailTipTranslations @{Add = "$_" }
                }
            }

            if ($CurGroup.EmailAddresses) {
                ($CurGroup.EmailAddresses -split [regex]::Escape('|') -match '(?i)x500:.*|smtp:.*@(?!(.*onmicrosoft\.com)).*') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_" }
                }
            }
            <#if ($CurGroup.EmailAddresses) {
                ($CurGroup.EmailAddresses -split [regex]::Escape('|') -notmatch 'smtp:.*@(?!(.*onmicrosoft\.com|three\.com|four\.com)).*') | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_" }
                }
            }#>
            # if ($CurGroup.EmailAddresses) {
            #     $CurGroup.EmailAddresses -split [regex]::Escape('|') | Where-Object { !($_ -clike "SMTP:*") } | ForEach-Object {
            #         Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_" }
            #     }
            # }
            if ($CurGroup.x500) {
                Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$($CurGroup.x500)" }
            }
            if ($CurGroup.membersSMTP) {
                $CurGroup.membersSMTP -split [regex]::Escape('|') | ForEach-Object {
                    Add-DistributionGroupMember -Identity $CurGroup.Identity -member "$_"
                }
            }
        }
    }
    End {

    }
}
