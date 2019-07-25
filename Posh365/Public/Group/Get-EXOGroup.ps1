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
        [Parameter(Mandatory = $false)]
        [switch] $DetailedReport,

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
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
                @{n = "AcceptMessagesOnlyFrom" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFrom) } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFromDLMembers) } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFromSendersOrMembers) } },
                @{n = "AddressListMembership" ; e = { [string]::join('|', [String[]]$_.AddressListMembership) } },
                @{n = "AdministrativeUnits" ; e = { [string]::join('|', [String[]]$_.AdministrativeUnits) } },
                @{n = "BypassModerationFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.BypassModerationFromSendersOrMembers) } },
                @{n = "GrantSendOnBehalfTo" ; e = { [string]::join('|', [String[]]$_.GrantSendOnBehalfTo) } },
                @{n = "ManagedBy" ; e = { [string]::join('|', [String[]]$_.ManagedBy) } },
                @{n = "ModeratedBy" ; e = { [string]::join('|', [String[]]$_.ModeratedBy) } },
                @{n = "RejectMessagesFrom" ; e = { [string]::join('|', [String[]]$_.RejectMessagesFrom) } },
                @{n = "RejectMessagesFromDLMembers" ; e = { ($_.RejectMessagesFromDLMembers | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.RejectMessagesFromSendersOrMembers) } },
                @{n = "ExtensionCustomAttribute1" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute1) } },
                @{n = "ExtensionCustomAttribute2" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute2) } },
                @{n = "ExtensionCustomAttribute3" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute3) } },
                @{n = "ExtensionCustomAttribute4" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute4) } },
                @{n = "ExtensionCustomAttribute5" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute5) } },
                @{n = "MailTipTranslations" ; e = { [string]::join('|', [String[]]$_.MailTipTranslations) } },
                @{n = "ObjectClass" ; e = { [string]::join('|', [String[]]$_.ObjectClass) } },
                @{n = "PoliciesExcluded" ; e = { [string]::join('|', [String[]]$_.PoliciesExcluded) } },
                @{n = "PoliciesIncluded" ; e = { [string]::join('|', [String[]]$_.PoliciesIncluded) } },
                @{n = "EmailAddresses" ; e = { [string]::join('|', [String[]]$_.EmailAddresses) } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "membersName" ; e = { [string]::join('|', [String[]]$Members.name) } },
                @{n = "membersSMTP" ; e = { [string]::join('|', [String[]]$Members.PrimarySmtpAddress) } }
            )
        }
        else {
            $Selectproperties = @(
                'Name', 'DisplayName', 'Alias', 'GroupType', 'Identity', 'PrimarySmtpAddress', 'RecipientTypeDetails', 'WindowsEmailAddress'
            )

            $CalculatedProps = @(
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFromSendersOrMembers) } },
                @{n = "ManagedBy" ; e = { [string]::join('|', [String[]]$_.ManagedBy) } },
                @{n = "EmailAddresses" ; e = { [string]::join('|', [String[]]$_.EmailAddresses) } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "membersName" ; e = { [string]::join('|', [String[]]$Members.name) } },
                @{n = "membersSMTP" ; e = { [string]::join('|', [String[]]$Members.PrimarySmtpAddress) } }
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

