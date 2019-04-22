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
            @{n = "AcceptMessagesOnlyFrom" ; e = { [string]::join("|", [String[]]$_.AcceptMessagesOnlyFrom -ne '') } },
            @{n = "AcceptMessagesOnlyFromDLMembers" ; e = { [string]::join("|", [String[]]$_.AcceptMessagesOnlyFromDLMembers -ne '') } },
            @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = { [string]::join("|", [String[]]$_.AcceptMessagesOnlyFromSendersOrMembers -ne '') } },
            @{n = "AddressListMembership" ; e = { [string]::join("|", [String[]]$_.AddressListMembership -ne '') } },
            @{n = "AdministrativeUnits" ; e = { [string]::join("|", [String[]]$_.AdministrativeUnits -ne '') } },
            @{n = "BypassModerationFromSendersOrMembers" ; e = { [string]::join("|", [String[]]$_.BypassModerationFromSendersOrMembers -ne '') } },
            @{n = "GrantSendOnBehalfTo" ; e = { [string]::join("|", [String[]]$_.GrantSendOnBehalfTo -ne '') } },
            @{n = "ModeratedBy" ; e = { [string]::join("|", [String[]]$_.ModeratedBy -ne '') } },
            @{n = "RejectMessagesFrom" ; e = { [string]::join("|", [String[]]$_.RejectMessagesFrom -ne '') } },
            @{n = "RejectMessagesFromDLMembers" ; e = { [string]::join("|", [String[]]$_.RejectMessagesFromDLMembers -ne '') } },
            @{n = "RejectMessagesFromSendersOrMembers" ; e = { [string]::join("|", [String[]]$_.RejectMessagesFromSendersOrMembers -ne '') } },
            @{n = "UserCertificate" ; e = { [string]::join("|", [String[]]$_.UserCertificate -ne '') } },
            @{n = "UserSMimeCertificate" ; e = { [string]::join("|", [String[]]$_.UserSMimeCertificate -ne '') } },
            @{n = "ExtensionCustomAttribute1" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute1 -ne '') } },
            @{n = "ExtensionCustomAttribute2" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute2 -ne '') } },
            @{n = "ExtensionCustomAttribute3" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute3 -ne '') } },
            @{n = "ExtensionCustomAttribute4" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute4 -ne '') } },
            @{n = "ExtensionCustomAttribute5" ; e = { [string]::join("|", [String[]]$_.ExtensionCustomAttribute5 -ne '') } },
            @{n = "Extensions" ; e = { [string]::join("|", [String[]]$_.Extensions -ne '') } },
            @{n = "MailTipTranslations" ; e = { [string]::join("|", [String[]]$_.MailTipTranslations -ne '') } },
            @{n = "ObjectClass" ; e = { [string]::join("|", [String[]]$_.ObjectClass -ne '') } },
            @{n = "PoliciesExcluded" ; e = { [string]::join("|", [String[]]$_.PoliciesExcluded -ne '') } },
            @{n = "PoliciesIncluded" ; e = { [string]::join("|", [String[]]$_.PoliciesIncluded -ne '') } },
            @{n = "UMDtmfMap" ; e = { [string]::join("|", [String[]]$_.UMDtmfMap -ne '') } },
            @{n = "EmailAddresses" ; e = { [string]::join("|", [String[]]$_.EmailAddresses -ne '') } }
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