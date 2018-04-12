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
            @{n = "AcceptMessagesOnlyFrom" ; e = {($_.AcceptMessagesOnlyFrom | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "AcceptMessagesOnlyFromDLMembers" ; e = {($_.AcceptMessagesOnlyFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = {($_.AcceptMessagesOnlyFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "AddressListMembership" ; e = {($_.AddressListMembership | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "AdministrativeUnits" ; e = {($_.AdministrativeUnits | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "BypassModerationFromSendersOrMembers" ; e = {($_.BypassModerationFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "GrantSendOnBehalfTo" ; e = {($_.GrantSendOnBehalfTo | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "ModeratedBy" ; e = {($_.ModeratedBy | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "RejectMessagesFrom" ; e = {($_.RejectMessagesFrom | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "RejectMessagesFromDLMembers" ; e = {($_.RejectMessagesFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "RejectMessagesFromSendersOrMembers" ; e = {($_.RejectMessagesFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "UserCertificate" ; e = {($_.UserCertificate | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "UserSMimeCertificate" ; e = {($_.UserSMimeCertificate | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute1" ; e = {($_.ExtensionCustomAttribute1 | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute2" ; e = {($_.ExtensionCustomAttribute2 | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute3" ; e = {($_.ExtensionCustomAttribute3 | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute4" ; e = {($_.ExtensionCustomAttribute4 | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute5" ; e = {($_.ExtensionCustomAttribute5 | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "Extensions" ; e = {($_.Extensions | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "MailTipTranslations" ; e = {($_.MailTipTranslations | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "ObjectClass" ; e = {($_.ObjectClass | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "PoliciesExcluded" ; e = {($_.PoliciesExcluded | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "PoliciesIncluded" ; e = {($_.PoliciesIncluded | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "UMDtmfMap" ; e = {($_.UMDtmfMap | Where-Object {$_ -ne $null}) -join ";" }},
            @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join ";" }}       
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