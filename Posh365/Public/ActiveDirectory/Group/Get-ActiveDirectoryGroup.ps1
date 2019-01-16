function Get-ActiveDirectoryGroup {
    <#
    .SYNOPSIS
    Export Office 365 Distribution Groups & Mail-Enabled Security Groups

    .DESCRIPTION
    Export Office 365 Distribution & Mail-Enabled Security Groups

    .PARAMETER ListofGroups
    Provide a text list of specific groups to report on.  Otherwise, all groups will be reported.

    .EXAMPLE
    Get-ActiveDirectoryGroup | Export-Csv c:\scripts\All365GroupExport.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-ADGroup -Filter "emailaddresses -like '*contoso.com*'" -ResultSize Unlimited | Select -ExpandProperty Name | Get-ActiveDirectoryGroup | Export-Csv c:\scripts\365GroupExport.csv -notypeinformation -encoding UTF8

    .EXAMPLE
    Get-Content "c:\scripts\groups.txt" | Get-ActiveDirectoryGroup | Export-Csv c:\scripts\365GroupExport.csv -notypeinformation -encoding UTF8

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

        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $ListofGroups
    )
    Begin {
        $Selectproperties1 = @(
            'Name', 'DisplayName'
        )
        $CalculatedProps1 = @(
            @{n = "OU" ; e = {$_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'}},
            @{n = "PrimarySmtpAddress" ; e = {($_.ProxyAddresses | Where-Object {$_ -cmatch "SMTP:"}) -join ";" }}
        )
        $Selectproperties2 = @(
            'GroupCategory', 'GroupScope', 'groupType', 'ManagedBy', 'SID', 'ObjectGUID', 'msExchRequireAuthToSendTo'
            'systemFlags', 'adminCount', 'showInAdvancedViewOnly', 'displayNamePrintable', 'legacyExchangeDN', 'mail'
            'mailNickname', 'msExchALObjectVersion', 'msExchArbitrationMailbox', 'msExchHideFromAddressLists'
            'msExchRecipientDisplayType', 'msExchVersion', 'oOFReplyToOriginator', 'reportToOriginator'
            'reportToOwner', 'textEncodedORAddress', 'info', 'internetEncoding', 'msExchAddressBookFlags'
            'msExchBypassAudit', 'msExchProvisioningFlags', 'deliverAndRedirect', 'msExchGenericForwardingAddress', 'msExchGroupDepartRestriction'
            'msExchGroupJoinRestriction', 'msExchMailboxAuditEnable', 'msExchMailboxAuditLogAgeLimit', 'uSNChanged', 'uSNCreated', 'whenChanged', 'whenCreated'
            'msExchModerationFlags', 'msExchTransportRecipientSettingsFlags', 'hideDLMembership'
            'msExchRecipientTypeDetails', 'CanonicalName', 'CN', 'Created', 'createTimeStamp', 'Deleted', 'Description', 'DistinguishedName'
            'HomePage', 'instanceType', 'isDeleted', 'LastKnownParent', 'Modified', 'modifyTimeStamp', 'ObjectCategory', 'ObjectClass', 'objectSid'
            'ProtectedFromAccidentalDeletion', 'SamAccountName', 'sAMAccountType', 'sDRightsEffective', 'isCriticalSystemObject'
        )
        $CalculatedProps2 = @(
            @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join '|' }},
            @{n = "x500" ; e = {"x500:" + $_.LegacyExchangeDN}},
            @{n = "Member" ; e = {($_.Members | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "MemberOf" ; e = {($_.MemberOf | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "SIDHistory" ; e = {($_.SIDHistory | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "msExchPoliciesIncluded" ; e = {($_.msExchPoliciesIncluded | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "authOrig" ; e = {($_.authOrig | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "authOrigBL" ; e = {($_.authOrigBL | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "dLMemSubmitPerms" ; e = {($_.dLMemSubmitPerms | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "msExchPoliciesExcluded" ; e = {($_.msExchPoliciesExcluded | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "msExchCoManagedByLink" ; e = {($_.msExchCoManagedByLink | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "altRecipientBL" ; e = {($_.altRecipientBL | Where-Object {$_ -ne $null}) -join ";"}},
            @{n = "dLMemSubmitPermsBL" ; e = {($_.dLMemSubmitPermsBL | Where-Object {$_ -ne $null}) -join ";"}}
        )

    }
    Process {
        if ($ListofGroups) {
            foreach ($CurGroup in $ListofGroups) {
                $Members = $CurGroup.Members
                Get-ADGroup -identity $CurGroup -Properties * | Select-Object ($Selectproperties1 + $CalculatedProps1 + $Selectproperties2 + $CalculatedProps2)
            }
        }
        else {
            $Groups = Get-ADGroup -ResultSetSize:$null -filter * -Properties *
            foreach ($CurGroup in $Groups) {
                $Members = $CurGroup.Members
                Get-ADGroup -identity $CurGroup.ObjectGUID -Properties * | Select-Object ($Selectproperties1 + $CalculatedProps1 + $Selectproperties2 + $CalculatedProps2)
            }
        }
    }
    End {

    }
}