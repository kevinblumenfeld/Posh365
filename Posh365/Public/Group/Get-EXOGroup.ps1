function Get-EXOGroup { 
    <#
    .SYNOPSIS
    Export Office 365 Distribution Groups & Mail-Enabled Security Groups
    
    .DESCRIPTION
    Export Office 365 Distribution & Mail-Enabled Security Groups
    
    .PARAMETER ListofGroups
    Provide a text list of specific groups to report on.  Otherwise, all groups will be reported.
    
    .EXAMPLE
    Get-EXOGroup | Export-Csv c:\scripts\All365GroupExport.csv -notypeinformation -encoding UTF8
    
    .EXAMPLE
    Get-Content "c:\scripts\groups.txt" | Export-Csv c:\scripts\365GroupExport.csv -notypeinformation -encoding UTF8
    
    Example of groups.txt
    #####################

    Group01
    Group02
    Group03
    Accounting Team

    #####################

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string[]] $ListofGroups
    )
    Begin {
        $Selectproperties = @('Alias', 'ArbitrationMailbox', 'CustomAttribute1', 'CustomAttribute10', 'CustomAttribute11'
            'CustomAttribute12', 'CustomAttribute13', 'CustomAttribute14', 'CustomAttribute15', 'CustomAttribute2'
            'CustomAttribute3', 'CustomAttribute4', 'CustomAttribute5', 'CustomAttribute6', 'CustomAttribute7'
            'CustomAttribute8', 'CustomAttribute9', 'DisplayName', 'DistinguishedName', 'ExchangeVersion'
            'ExpansionServer', 'ExternalDirectoryObjectId', 'GroupType', 'Id', 'Identity', 'LegacyExchangeDN'
            'MaxReceiveSize', 'MaxSendSize', 'MemberDepartRestriction', 'MemberJoinRestriction', 'Name'
            'ObjectCategory', 'ObjectState', 'OrganizationalUnit', 'OrganizationId', 'OriginatingServer'
            'PrimarySmtpAddress', 'RecipientType', 'RecipientTypeDetails', 'SamAccountName'
            'SendModerationNotifications', 'SimpleDisplayName', 'WindowsEmailAddress')

        $CalculatedProps = @(@{n = "AcceptMessagesOnlyFrom" ; e = {($_.AcceptMessagesOnlyFrom | ? {$_ -ne $null}) -join ";" }},
            @{n = "AcceptMessagesOnlyFromDLMembers" ; e = {($_.AcceptMessagesOnlyFromDLMembers | ? {$_ -ne $null}) -join ";" }},
            @{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = {($_.AcceptMessagesOnlyFromSendersOrMembers | ? {$_ -ne $null}) -join ";" }},
            @{n = "AddressListMembership" ; e = {($_.AddressListMembership | ? {$_ -ne $null}) -join ";" }},
            @{n = "AdministrativeUnits" ; e = {($_.AdministrativeUnits | ? {$_ -ne $null}) -join ";" }},
            @{n = "BypassModerationFromSendersOrMembers" ; e = {($_.BypassModerationFromSendersOrMembers | ? {$_ -ne $null}) -join ";" }},
            @{n = "GrantSendOnBehalfTo" ; e = {($_.GrantSendOnBehalfTo | ? {$_ -ne $null}) -join ";" }},
            @{n = "ManagedBy" ; e = {($_.ManagedBy | ? {$_ -ne $null}) -join ";" }},
            @{n = "ModeratedBy" ; e = {($_.ModeratedBy | ? {$_ -ne $null}) -join ";" }},
            @{n = "RejectMessagesFrom" ; e = {($_.RejectMessagesFrom | ? {$_ -ne $null}) -join ";" }},
            @{n = "RejectMessagesFromDLMembers" ; e = {($_.RejectMessagesFromDLMembers | ? {$_ -ne $null}) -join ";" }},
            @{n = "RejectMessagesFromSendersOrMembers" ; e = {($_.RejectMessagesFromSendersOrMembers | ? {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute1" ; e = {($_.ExtensionCustomAttribute1 | ? {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute2" ; e = {($_.ExtensionCustomAttribute2 | ? {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute3" ; e = {($_.ExtensionCustomAttribute3 | ? {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute4" ; e = {($_.ExtensionCustomAttribute4 | ? {$_ -ne $null}) -join ";" }},
            @{n = "ExtensionCustomAttribute5" ; e = {($_.ExtensionCustomAttribute5 | ? {$_ -ne $null}) -join ";" }},
            @{n = "MailTipTranslations" ; e = {($_.MailTipTranslations | ? {$_ -ne $null}) -join ";" }},
            @{n = "ObjectClass" ; e = {($_.ObjectClass | ? {$_ -ne $null}) -join ";" }},
            @{n = "PoliciesExcluded" ; e = {($_.PoliciesExcluded | ? {$_ -ne $null}) -join ";" }},
            @{n = "PoliciesIncluded" ; e = {($_.PoliciesIncluded | ? {$_ -ne $null}) -join ";" }},
            @{n = "EmailAddresses" ; e = {($_.EmailAddresses | ? {$_ -ne $null}) -join ";" }},
            @{n = "x500" ; e = {"x500:" + $_.LegacyExchangeDN}},
            @{n = "membersName" ; e = {($Members.name | ? {$_ -ne $null}) -join ";"}}
            @{n = "membersSMTP" ; e = {($Members.PrimarySmtpAddress | ? {$_ -ne $null}) -join ";"}}
        )
    }
    Process {
        if ($ListofGroups) {
            foreach ($CurGroup in $ListofGroups) {
                $Members = Get-DistributionGroupMember -Identity $CurGroup | Select name, primarysmtpaddress
                Get-DistributionGroup -identity $CurGroup | select ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            $Members = Get-DistributionGroupMember -Identity $CurGroup | Select name, primarysmtpaddress
            Get-DistributionGroup -ResultSize unlimited | select ($Selectproperties + $CalculatedProps)
        }
    }
    End {
        
    }
}