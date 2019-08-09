function Get-EXOGroup {
    <#
    .SYNOPSIS
    Export Office 365 Distribution Groups & Mail-Enabled Security Groups

    .DESCRIPTION
    Export Office 365 Distribution & Mail-Enabled Security Groups

    .PARAMETER ListofGroups
    Provide a text list of specific groups to report on.  Otherwise, all groups will be reported.
    It is highly recommend to use a list of primarysmtpaddresses or GUIDs

    .EXAMPLE
    Get-EXOGroup | Export-Csv c:\scripts\All365GroupExport.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-DistributionGroup -Filter "emailaddresses -like '*contoso.com*'" -ResultSize Unlimited | Select -ExpandProperty Name | Get-EXOGroup | Export-Csv c:\scripts\365GroupExport.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-Content "c:\scripts\groups.txt" | Get-EXOGroup | Export-Csv c:\scripts\365GroupExport.csv -notypeinformation -encoding UTF8

    Example of groups.txt
    #####################

    Group01
    Group02
    Group03
    Accounting Team

    #####################

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline)]
        [string[]] $ListofGroups
    )
    Begin {
        if ($DetailedReport) {
            $Selectproperties = @(
                'Name', 'DisplayName', 'Alias', 'GroupType', 'Identity', 'PrimarySmtpAddress', 'RecipientType'
                'RecipientTypeDetails', 'WindowsEmailAddress', 'ArbitrationMailbox', 'CustomAttribute1'
                'CustomAttribute10', 'CustomAttribute11', 'CustomAttribute12', 'CustomAttribute13'
                'CustomAttribute14', 'CustomAttribute15', 'CustomAttribute2', 'CustomAttribute3'
                'CustomAttribute4', 'CustomAttribute5', 'CustomAttribute6', 'CustomAttribute7'
                'CustomAttribute8', 'CustomAttribute9', 'DistinguishedName', 'ExchangeVersion'
                'ExpansionServer', 'ExternalDirectoryObjectId', 'Id', 'LegacyExchangeDN'
                'MaxReceiveSize', 'MaxSendSize', 'MemberDepartRestriction', 'MemberJoinRestriction'
                'ObjectCategory', 'ObjectState', 'OrganizationalUnit', 'OrganizationId', 'OriginatingServer'
                'SamAccountName', 'SendModerationNotifications', 'SimpleDisplayName'
                'BypassNestedModerationEnabled', 'EmailAddressPolicyEnabled', 'HiddenFromAddressListsEnabled'
                'IsDirSynced', 'IsValid', 'MigrationToUnifiedGroupInProgress', 'ModerationEnabled'
                'ReportToManagerEnabled', 'ReportToOriginatorEnabled', 'RequireSenderAuthenticationEnabled'
                'SendOofMessageToOriginatorEnabled'
            )

            $CalculatedProps = @(
                @{n = "AcceptMessagesOnlyFrom" ; e = { @($_.AcceptMessagesOnlyFrom) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { @($_.AcceptMessagesOnlyFromDLMembers) -ne '' -join '|' } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { @($_.AcceptMessagesOnlyFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "AddressListMembership" ; e = { @($_.AddressListMembership) -ne '' -join '|' } },
                @{n = "AdministrativeUnits" ; e = { @($_.AdministrativeUnits) -ne '' -join '|' } },
                @{n = "BypassModerationFromSendersOrMembers" ; e = { @($_.BypassModerationFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "GrantSendOnBehalfTo" ; e = { @($_.GrantSendOnBehalfTo) -ne '' -join '|' } },
                @{n = "ManagedBy" ; e = { @($_.ManagedBy) -ne '' -join '|' } },
                @{n = "ModeratedBy" ; e = { @($_.ModeratedBy) -ne '' -join '|' } },
                @{n = "RejectMessagesFrom" ; e = { @($_.RejectMessagesFrom) -ne '' -join '|' } },
                @{n = "RejectMessagesFromDLMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute1" ; e = { @($_.ExtensionCustomAttribute1) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute2" ; e = { @($_.ExtensionCustomAttribute2) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute3" ; e = { @($_.ExtensionCustomAttribute3) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute4" ; e = { @($_.ExtensionCustomAttribute4) -ne '' -join '|' } },
                @{n = "ExtensionCustomAttribute5" ; e = { @($_.ExtensionCustomAttribute5) -ne '' -join '|' } },
                @{n = "MailTipTranslations" ; e = { @($_.MailTipTranslations) -ne '' -join '|' } },
                @{n = "ObjectClass" ; e = { @($_.ObjectClass) -ne '' -join '|' } },
                @{n = "PoliciesExcluded" ; e = { @($_.PoliciesExcluded) -ne '' -join '|' } },
                @{n = "PoliciesIncluded" ; e = { @($_.PoliciesIncluded) -ne '' -join '|' } },
                @{n = "EmailAddresses" ; e = { @($_.emailaddresses) -ne '' -join '|' } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "membersName" ; e = { @($Members.name) -ne '' -join '|' } },
                @{n = "membersSmtp" ; e = { @($Members.PrimarySmtpAddress) -ne '' -join '|' } },
                @{n = "ExchangeObjectId" ; e = { ($_.ExchangeObjectId).Guid } }
            )
        }
        else {
            $Selectproperties = @(
                'Name', 'DisplayName', 'Alias', 'GroupType', 'Identity', 'PrimarySmtpAddress', 'RecipientTypeDetails', 'WindowsEmailAddress'
            )

            $CalculatedProps = @(
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { @($_.AcceptMessagesOnlyFromSendersOrMembers) -ne '' -join '|' } },
                @{n = "ManagedBy" ; e = { @($_.ManagedBy) -ne '' -join '|' } },
                @{n = "EmailAddresses" ; e = { @($_.emailaddresses) -ne '' -join '|' } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "membersName" ; e = { @($Members.name) -ne '' -join '|' } },
                @{n = "membersSmtp" ; e = { @($Members.PrimarySmtpAddress) -ne '' -join '|' } }
            )
        }
    }
    Process {
        if ($ListofGroups) {
            foreach ($CurGroup in $ListofGroups) {
                $Members = Get-DistributionGroupMember -Identity $CurGroup -ResultSize Unlimited | Select-Object name, primarysmtpaddress
                Get-DistributionGroup -identity $CurGroup -ResultSize Unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            $Groups = Get-DistributionGroup -ResultSize unlimited
            foreach ($CurGroup in $Groups) {
                [string]$Guid = $CurGroup.Guid
                $Members = Get-DistributionGroupMember -Identity $Guid -ResultSize Unlimited | Select-Object name, primarysmtpaddress
                Get-DistributionGroup -identity $Guid -ResultSize Unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
    }
    End {

    }
}

