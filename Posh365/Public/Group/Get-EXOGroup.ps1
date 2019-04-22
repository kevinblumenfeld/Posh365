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
                @{n = "AcceptMessagesOnlyFrom" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFrom -ne '') } },
                @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFromDLMembers -ne '') } },
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFromSendersOrMembers -ne '') } },
                @{n = "AddressListMembership" ; e = { [string]::join('|', [String[]]$_.AddressListMembership -ne '') } },
                @{n = "AdministrativeUnits" ; e = { [string]::join('|', [String[]]$_.AdministrativeUnits -ne '') } },
                @{n = "BypassModerationFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.BypassModerationFromSendersOrMembers -ne '') } },
                @{n = "GrantSendOnBehalfTo" ; e = { [string]::join('|', [String[]]$_.GrantSendOnBehalfTo -ne '') } },
                @{n = "ManagedBy" ; e = { [string]::join('|', [String[]]$_.ManagedBy -ne '') } },
                @{n = "ModeratedBy" ; e = { [string]::join('|', [String[]]$_.ModeratedBy -ne '') } },
                @{n = "RejectMessagesFrom" ; e = { [string]::join('|', [String[]]$_.RejectMessagesFrom -ne '') } },
                @{n = "RejectMessagesFromDLMembers" ; e = { ($_.RejectMessagesFromDLMembers | Where-Object { $_ -ne $null }) -join ";" } },
                @{n = "RejectMessagesFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.RejectMessagesFromSendersOrMembers -ne '') } },
                @{n = "ExtensionCustomAttribute1" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute1 -ne '') } },
                @{n = "ExtensionCustomAttribute2" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute2 -ne '') } },
                @{n = "ExtensionCustomAttribute3" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute3 -ne '') } },
                @{n = "ExtensionCustomAttribute4" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute4 -ne '') } },
                @{n = "ExtensionCustomAttribute5" ; e = { [string]::join('|', [String[]]$_.ExtensionCustomAttribute5 -ne '') } },
                @{n = "MailTipTranslations" ; e = { [string]::join('|', [String[]]$_.MailTipTranslations -ne '') } },
                @{n = "ObjectClass" ; e = { [string]::join('|', [String[]]$_.ObjectClass -ne '') } },
                @{n = "PoliciesExcluded" ; e = { [string]::join('|', [String[]]$_.PoliciesExcluded -ne '') } },
                @{n = "PoliciesIncluded" ; e = { [string]::join('|', [String[]]$_.PoliciesIncluded -ne '') } },
                @{n = "EmailAddresses" ; e = { [string]::join('|', [String[]]$_.EmailAddresses -ne '') } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "membersName" ; e = { [string]::join('|', [String[]]$Members.name -ne '') } },
                @{n = "membersSMTP" ; e = { [string]::join('|', [String[]]$Members.PrimarySmtpAddress -ne '') } }
            )
        }
        else {
            $Selectproperties = @(
                'Name', 'DisplayName', 'Alias', 'GroupType', 'Identity', 'PrimarySmtpAddress', 'RecipientTypeDetails', 'WindowsEmailAddress'
            )

            $CalculatedProps = @(
                @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { [string]::join('|', [String[]]$_.AcceptMessagesOnlyFromSendersOrMembers -ne '') } },
                @{n = "ManagedBy" ; e = { [string]::join('|', [String[]]$_.ManagedBy -ne '') } },
                @{n = "EmailAddresses" ; e = { [string]::join('|', [String[]]$_.EmailAddresses -ne '') } },
                @{n = "x500" ; e = { "x500:" + $_.LegacyExchangeDN } },
                @{n = "membersName" ; e = { [string]::join('|', [String[]]$Members.name -ne '') } },
                @{n = "membersSMTP" ; e = { [string]::join('|', [String[]]$Members.PrimarySmtpAddress -ne '') } }
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