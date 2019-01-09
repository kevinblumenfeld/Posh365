function Get-ExchangeDistributionGroup { 
    <#
    .SYNOPSIS
    Export Office 365 Distribution Groups & Mail-Enabled Security Groups
    
    .DESCRIPTION
    Export Office 365 Distribution & Mail-Enabled Security Groups
    
    .PARAMETER ListofGroups
    Provide a text list of specific groups to report on.  Otherwise, all groups will be reported.
    
    .PARAMETER PowerShell2
    Use it for PowerShell version 2
    
    .EXAMPLE
    Get-ExchangeDistributionGroup | Export-Csv c:\scripts\All365GroupExport.csv -Notypeinformation -Encoding UTF8
    
    .EXAMPLE
    Get-DistributionGroup -Filter "emailaddresses -like '*contoso.com*'" -ResultSize Unlimited | Select -ExpandProperty Name | Get-ExchangeDistributionGroup | Export-Csv c:\scripts\365GroupExport.csv -Notypeinformation -Encoding UTF8
    
    .EXAMPLE
    Get-Content "c:\scripts\groups.txt" | Get-ExchangeDistributionGroup | Export-Csv c:\scripts\365GroupExport.csv -Notypeinformation -Encoding UTF8
    
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
        [string[]] $ListofGroups,

        [Parameter(Mandatory = $false)]
        [switch] $PowerShell2
    )
    Begin {
        $Selectproperties = New-Object System.Collections.ArrayList

        # [void] to prevent Array returning index after each add
        [void]$Selectproperties.Add('Name')
        [void]$Selectproperties.Add('DisplayName')
        [void]$Selectproperties.Add('Alias')
        [void]$Selectproperties.Add('GroupType')
        [void]$Selectproperties.Add('Identity')
        [void]$Selectproperties.Add('PrimarySmtpAddress')
        [void]$Selectproperties.Add('RecipientTypeDetails')
        [void]$Selectproperties.Add('WindowsEmailAddress')       
        
        $CalculatedProps = New-Object System.Collections.ArrayList
        [void]$CalculatedProps.Add(@{n = "OU" ; e = {$_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'}})
        [void]$CalculatedProps.Add(@{n = "AcceptMessagesOnlyFromSendersOrMembers" ; e = {($_.AcceptMessagesOnlyFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }})
        [void]$CalculatedProps.Add(@{n = "ManagedBy" ; e = {($_.ManagedBy | Where-Object {$_ -ne $null}) -join ";" }})
        [void]$CalculatedProps.Add( @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join ";" }})
        [void]$CalculatedProps.Add(@{n = "x500" ; e = {"x500:" + $_.LegacyExchangeDN}})
        [void]$CalculatedProps.Add(
            @{n = "membersName" ; e ={
                    if($PowerShell2)
                    {
                        ($Members | ForEach { $_.Name }) -join ';'
                    }
                    else
                    {
                        ($Members.name | Where-Object {$_ -ne $null}) -join ";"
                    }
                }
            }
        )
        [void]$CalculatedProps.Add(
            @{n = "membersSMTP" ; e ={
                    if($PowerShell2)
                    {
                        ($Members | ForEach { $_.PrimarySmtpAddress }) -join ';'
                    }
                    else
                    {
                        ($Members.PrimarySmtpAddress | Where-Object {$_ -ne $null}) -join ";"
                    }
                }
            }
        )

        
        if ($DetailedReport) 
        {
            [void]$Selectproperties.Add('RecipientType')
            [void]$Selectproperties.Add('ArbitrationMailbox')
            [void]$Selectproperties.Add('CustomAttribute1')
            [void]$Selectproperties.Add('CustomAttribute10')
            [void]$Selectproperties.Add('CustomAttribute11')
            [void]$Selectproperties.Add('CustomAttribute12')
            [void]$Selectproperties.Add('CustomAttribute13')
            [void]$Selectproperties.Add('CustomAttribute14')
            [void]$Selectproperties.Add('CustomAttribute15')
            [void]$Selectproperties.Add('CustomAttribute2')
            [void]$Selectproperties.Add('CustomAttribute3')
            [void]$Selectproperties.Add('CustomAttribute4')
            [void]$Selectproperties.Add('CustomAttribute5')
            [void]$Selectproperties.Add('CustomAttribute6')
            [void]$Selectproperties.Add('CustomAttribute7')
            [void]$Selectproperties.Add('CustomAttribute8')
            [void]$Selectproperties.Add('CustomAttribute9')
            [void]$Selectproperties.Add('DistinguishedName')
            [void]$Selectproperties.Add('ExchangeVersion')
            [void]$Selectproperties.Add('ExpansionServer')
            [void]$Selectproperties.Add('ExternalDirectoryObjectId')
            [void]$Selectproperties.Add('Id')
            [void]$Selectproperties.Add('LegacyExchangeDN')
            [void]$Selectproperties.Add('MaxReceiveSize')
            [void]$Selectproperties.Add('MaxSendSize')
            [void]$Selectproperties.Add('MemberDepartRestriction')
            [void]$Selectproperties.Add('MemberJoinRestriction')
            [void]$Selectproperties.Add('ObjectCategory')
            [void]$Selectproperties.Add('ObjectState')
            [void]$Selectproperties.Add('OrganizationalUnit')
            [void]$Selectproperties.Add('OrganizationId')
            [void]$Selectproperties.Add('OriginatingServer')
            [void]$Selectproperties.Add('SamAccountName')
            [void]$Selectproperties.Add('SendModerationNotifications')
            [void]$Selectproperties.Add('SimpleDisplayName')
            [void]$Selectproperties.Add('BypassNestedModerationEnabled')
            [void]$Selectproperties.Add('EmailAddressPolicyEnabled')
            [void]$Selectproperties.Add('HiddenFromAddressListsEnabled')
            [void]$Selectproperties.Add('IsDirSynced')
            [void]$Selectproperties.Add('IsValid')
            [void]$Selectproperties.Add('MigrationToUnifiedGroupInProgress')
            [void]$Selectproperties.Add('ModerationEnabled')
            [void]$Selectproperties.Add('ReportToManagerEnabled')
            [void]$Selectproperties.Add('ReportToOriginatorEnabled')
            [void]$Selectproperties.Add('RequireSenderAuthenticationEnabled')
            [void]$Selectproperties.Add('SendOofMessageToOriginatorEnabled')

            [void]$CalculatedProps.Add(@{n = "AcceptMessagesOnlyFrom" ; e = {($_.AcceptMessagesOnlyFrom | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "AcceptMessagesOnlyFromDLMembers" ; e = {($_.AcceptMessagesOnlyFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "AddressListMembership" ; e = {($_.AddressListMembership | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "AdministrativeUnits" ; e = {($_.AdministrativeUnits | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "BypassModerationFromSendersOrMembers" ; e = {($_.BypassModerationFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "GrantSendOnBehalfTo" ; e = {($_.GrantSendOnBehalfTo | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "ModeratedBy" ; e = {($_.ModeratedBy | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "RejectMessagesFrom" ; e = {($_.RejectMessagesFrom | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "RejectMessagesFromDLMembers" ; e = {($_.RejectMessagesFromDLMembers | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "RejectMessagesFromSendersOrMembers" ; e = {($_.RejectMessagesFromSendersOrMembers | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "ExtensionCustomAttribute1" ; e = {($_.ExtensionCustomAttribute1 | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "ExtensionCustomAttribute2" ; e = {($_.ExtensionCustomAttribute2 | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "ExtensionCustomAttribute3" ; e = {($_.ExtensionCustomAttribute3 | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "ExtensionCustomAttribute4" ; e = {($_.ExtensionCustomAttribute4 | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "ExtensionCustomAttribute5" ; e = {($_.ExtensionCustomAttribute5 | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "MailTip" ; e = {($_.MailTip | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "MailTipTranslations" ; e = {($_.MailTipTranslations | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "UMDtmfMap" ; e = {($_.UMDtmfMap | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "ObjectClass" ; e = {($_.ObjectClass | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "PoliciesExcluded" ; e = {($_.PoliciesExcluded | Where-Object {$_ -ne $null}) -join ";" }})
            [void]$CalculatedProps.Add(@{n = "PoliciesIncluded" ; e = {($_.PoliciesIncluded | Where-Object {$_ -ne $null}) -join ";" }})
        }
    }
    Process {
        if ($ListofGroups) {
            foreach ($CurGroup in $ListofGroups) {
                $Members = Get-DistributionGroupMember -Identity $CurGroup -ResultSize Unlimited | Select-Object name, primarysmtpaddress
                Get-DistributionGroup -identity $CurGroup  -ResultSize Unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
        else {
            $Groups = Get-DistributionGroup -ResultSize unlimited
            foreach ($CurGroup in $Groups) {
                $Members = Get-DistributionGroupMember -Identity $CurGroup.identity -ResultSize Unlimited | Select-Object name, primarysmtpaddress
                Get-DistributionGroup -identity $CurGroup.identity -ResultSize Unlimited | Select-Object ($Selectproperties + $CalculatedProps)
            }
        }
    }
    End {
        
    }
}
