function Get-EXOMailContact {
    <#
    .SYNOPSIS
    Export Office 365 Mail Contacts

    .DESCRIPTION
    Export Office 365 Mail Contacts

    .PARAMETER Filter
    Provide specific Mail Contacts to report on.  Otherwise, all Mail Contacts will be reported.  Please review the examples provided.

    .EXAMPLE
    Get-EXOMailContact | Export-Csv c:\scripts\All365MailContacts.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    '{emailaddresses -like "*contoso.com"}' | Get-EXOMailContact | Export-Csv c:\scripts\365MailContacts.csv -notypeinformation -encoding UTF8

    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $Filter
    )
    Begin {
        $Selectproperties = @(
            'ArbitrationMailbox', 'LastExchangeChangedTime', 'MailTip', 'EmailAddressPolicyEnabled', 'HasPicture', 'HasSpokenName', 'HiddenFromAddressListsEnabled'
            'IsDirSynced', 'IsValid', 'ModerationEnabled', 'RequireSenderAuthenticationEnabled', 'UsePreferMessageFormat', 'WhenChanged', 'WhenChangedUTC', 'WhenCreated'
            'WhenCreatedUTC', 'Guid', 'Alias', 'CustomAttribute1', 'CustomAttribute10', 'CustomAttribute11', 'CustomAttribute12', 'CustomAttribute13', 'CustomAttribute14'
            'CustomAttribute15', 'CustomAttribute2', 'CustomAttribute3', 'CustomAttribute4', 'CustomAttribute5', 'CustomAttribute6', 'CustomAttribute7', 'CustomAttribute8'
            'CustomAttribute9', 'DisplayName', 'DistinguishedName', 'ExchangeVersion', 'ExternalDirectoryObjectId', 'ExternalEmailAddress', 'Id', 'Identity', 'LegacyExchangeDN'
            'MacAttachmentFormat', 'MaxReceiveSize', 'MaxRecipientPerMessage', 'MaxSendSize', 'MessageBodyFormat', 'MessageFormat', 'Name', 'ObjectCategory', 'ObjectState'
            'OrganizationalUnit', 'OrganizationId', 'OriginatingServer', 'PrimarySmtpAddress', 'RecipientType', 'RecipientTypeDetails', 'SendModerationNotifications'
            'SimpleDisplayName', 'UseMapiRichTextFormat', 'WindowsEmailAddress'
        )

        $CalculatedProps = @(
            @{n = "AcceptMessagesOnlyFrom" ; e = { @($_.AcceptMessagesOnlyFrom) -ne '' -join '|' } },
            @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { @($_.AcceptMessagesOnlyFromDLMembers) -ne '' -join '|' } },
            @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { @($_.AcceptMessagesOnlyFromSendersOrMembers) -ne '' -join '|' } },
            @{n = "AddressListMembership" ; e = { @($_.AddressListMembership) -ne '' -join '|' } },
            @{n = "AdministrativeUnits" ; e = { @($_.AdministrativeUnits) -ne '' -join '|' } },
            @{n = "BypassModerationFromSendersOrMembers" ; e = { @($_.BypassModerationFromSendersOrMembers) -ne '' -join '|' } },
            @{n = "GrantSendOnBehalfTo" ; e = { @($_.GrantSendOnBehalfTo) -ne '' -join '|' } },
            @{n = "ModeratedBy" ; e = { @($_.ModeratedBy) -ne '' -join '|' } },
            @{n = "RejectMessagesFrom" ; e = { @($_.RejectMessagesFrom) -ne '' -join '|' } },
            @{n = "RejectMessagesFromDLMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
            @{n = "RejectMessagesFromSendersOrMembers" ; e = { @($_.RejectMessagesFromSendersOrMembers) -ne '' -join '|' } },
            @{n = "UserCertificate" ; e = { @($_.UserCertificate) -ne '' -join '|' } },
            @{n = "UserSMimeCertificate" ; e = { @($_.UserSMimeCertificate) -ne '' -join '|' } },
            @{n = "ExtensionCustomAttribute1" ; e = { @($_.ExtensionCustomAttribute1) -ne '' -join '|' } },
            @{n = "ExtensionCustomAttribute2" ; e = { @($_.ExtensionCustomAttribute2) -ne '' -join '|' } },
            @{n = "ExtensionCustomAttribute3" ; e = { @($_.ExtensionCustomAttribute3) -ne '' -join '|' } },
            @{n = "ExtensionCustomAttribute4" ; e = { @($_.ExtensionCustomAttribute4) -ne '' -join '|' } },
            @{n = "ExtensionCustomAttribute5" ; e = { @($_.ExtensionCustomAttribute5) -ne '' -join '|' } },
            @{n = "Extensions" ; e = { @($_.Extensions) -ne '' -join '|' } },
            @{n = "MailTipTranslations" ; e = { @($_.MailTipTranslations) -ne '' -join '|' } },
            @{n = "ObjectClass" ; e = { @($_.ObjectClass) -ne '' -join '|' } },
            @{n = "PoliciesExcluded" ; e = { @($_.PoliciesExcluded) -ne '' -join '|' } },
            @{n = "PoliciesIncluded" ; e = { @($_.PoliciesIncluded) -ne '' -join '|' } },
            @{n = "EmailAddresses" ; e = { @($_.emailaddresses) -ne '' -join '|' } },
            @{n = "ExchangeObjectId" ; e = { ($_.ExchangeObjectId).Guid } }
        )
    }
    Process {
        if ($Filter) {
            foreach ($CurFilter in $Filter) {
                Get-MailContact -Filter $CurFilter -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            Get-MailContact -ResultSize unlimited | Select-Object ($Selectproperties + $CalculatedProps)
        }
    }
    End {

    }
}
