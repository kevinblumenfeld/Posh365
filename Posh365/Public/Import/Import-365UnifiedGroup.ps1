function Import-365UnifiedGroup { 
    <#
    .SYNOPSIS
    Import Office 365 Unified Groups
    
    .DESCRIPTION
    Import Office 365 Unified Groups
    
    .PARAMETER Groups
    CSV of existing groups and attributes to change.
    
    .EXAMPLE
    Import-Csv .\importgroups.csv | Import-365UnifiedGroup


    #>

    [CmdletBinding()]
    Param 
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        $Groups
    )
    Begin {
        $AllRecipients = (Get-Recipient -ResultSize Unlimited).PrimarySmtpAddress
    }
    Process {
        ForEach ($CurGroup in $Groups) {
            $sethash = @{
                Identity                           = $CurGroup.Alias
                AccessType                         = $CurGroup.AccessType
                CustomAttribute1                   = $CurGroup.CustomAttribute1
                CustomAttribute10                  = $CurGroup.CustomAttribute10
                CustomAttribute11                  = $CurGroup.CustomAttribute11
                CustomAttribute12                  = $CurGroup.CustomAttribute12
                CustomAttribute13                  = $CurGroup.CustomAttribute13
                CustomAttribute14                  = $CurGroup.CustomAttribute14
                CustomAttribute15                  = $CurGroup.CustomAttribute15
                CustomAttribute2                   = $CurGroup.CustomAttribute2
                CustomAttribute3                   = $CurGroup.CustomAttribute3
                CustomAttribute4                   = $CurGroup.CustomAttribute4
                CustomAttribute5                   = $CurGroup.CustomAttribute5
                CustomAttribute6                   = $CurGroup.CustomAttribute6
                CustomAttribute7                   = $CurGroup.CustomAttribute7
                CustomAttribute8                   = $CurGroup.CustomAttribute8
                CustomAttribute9                   = $CurGroup.CustomAttribute9
                Notes                              = $CurGroup.Notes
                PrimarySmtpAddress                 = $CurGroup.PrimarySmtpAddress
                HiddenFromAddressListsEnabled      = [bool]::Parse($CurGroup.HiddenFromAddressListsEnabled)
                ModerationEnabled                  = [bool]::Parse($CurGroup.ModerationEnabled)
                RequireSenderAuthenticationEnabled = [bool]::Parse($CurGroup.RequireSenderAuthenticationEnabled)
            }
    
            $setparams = @{}
            ForEach ($h in $sethash.keys) {
                if ($($sethash.item($h))) {
                    $setparams.add($h, $($sethash.item($h)))
                }
            }

            Set-UnifiedGroup @setparams

            if ($CurGroup.AcceptMessagesOnlyFromSendersOrMembers) {
                $CurGroup.AcceptMessagesOnlyFromSendersOrMembers -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFromSendersOrMembers @{Add = "$_"}
                }
            }
            if ($CurGroup.GrantSendOnBehalfTo) {
                $CurGroup.GrantSendOnBehalfTo -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -GrantSendOnBehalfTo @{Add = "$_"}
                }
            }
            if ($CurGroup.ModeratedBy) {
                $CurGroup.ModeratedBy -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -ModeratedBy @{Add = "$_"}
                }
            }
            if ($CurGroup.RejectMessagesFromSendersOrMembers) {
                $CurGroup.RejectMessagesFromSendersOrMembers -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -RejectMessagesFromSendersOrMembers @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute1) {
                $CurGroup.ExtensionCustomAttribute1 -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute1 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute2) {
                $CurGroup.ExtensionCustomAttribute2 -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute2 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute3) {
                $CurGroup.ExtensionCustomAttribute3 -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute3 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute4) {
                $CurGroup.ExtensionCustomAttribute4 -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute4 @{Add = "$_"}
                }
            }
            if ($CurGroup.ExtensionCustomAttribute5) {
                $CurGroup.ExtensionCustomAttribute5 -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute5 @{Add = "$_"}
                }
            }
            if ($CurGroup.MailTipTranslations) {
                $CurGroup.MailTipTranslations -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -MailTipTranslations @{Add = "$_"}
                }
            }
            $Members = @()
            [array]$Members_All = $CurGroup.Members.Split(",")
            Write-Verbose "Adding members to group: `t $($CurGroup.Alias)"
            foreach ($Member_obj in $Members_All) {
                if ($AllRecipients -contains $Member_obj) {
                    Write-Verbose "Member: `t $Member_obj"
                    $Members += $Member_obj
                }
            }
            if ($Members) {
                # $Members += "formigrationaccount@contoso.onmicrosoft.com"
                Add-UnifiedGroupLinks -Identity $CurGroup.Alias -LinkType Members -Links $Members
            }
            $Subscribers = @()
            [array]$Subscribers_All = $CurGroup.Subscribers.Split(",")
            Write-Verbose "Adding subscribers to group: `t $($CurGroup.Alias)"
            foreach ($Subscriber_obj in $Subscribers_All) {
                if ($AllRecipients -contains $Subscriber_obj) {
                    Write-Verbose "Subscriber: `t $Subscriber_obj"
                    $Subscribers += $Subscriber_obj 
                }
            }
            if ($Subscribers) {
                Add-UnifiedGroupLinks -Identity $CurGroup.Alias -LinkType Subscribers -Links $Subscribers
            }
            <#
            if ($CurGroup.ManagedBy) {
                $CurGroup.ManagedBy -Split "," | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -ManagedBy @{Add = "$_"}
                }
            }
            if ($CurGroup.EmailAddresses) {
                $CurGroup.EmailAddresses -Split "," | Where-Object {(!($_ -clike "SMTP:*")) -and ($_ -notlike "SPO:*" )} | ForEach-Object {
                    Set-UnifiedGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_"}
                }
            }
            if ($CurGroup.membersSMTP) {
                $CurGroup.membersSMTP -Split "," | ForEach-Object {
                    Add-DistributionGroupMember -Identity $CurGroup.Identity -member "$_"
                }
            }
            #>
        }
    }
    End {
        
    }
}
