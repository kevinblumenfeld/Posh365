function Export-AndImportUnifiedGroups {
    <#
.SYNOPSIS
Export, Import, and update Unfied Groups

.DESCRIPTION
Use this script to backup, restore, export, import, and update Unified Groups,
primarily when migrating group settings between tenants.

In a 1-stage migration, you will export unified groups from a source tenant,
add the domains to the target tenant, and then import the groups with users into
the target tenant. To do this, you'll use the -Mode Import -IncludeUsers
parameters when importing into the target tenant.

In a 2-stage migration, you will export unified groups from a source tenant,
import the groups to the target tenant, synchronize the data, and then add the
domains at a later date.  Once the domains are added, you can re-run the script
with the -Mode Set parameter to import the users.

.PARAMETER IncludeUsers
When running an Import, if the domains have been migrated, use this switch to
import the users as well.

.PARAMETER Mode
Valid options are Export, Import, and Set.
- Export
  Use when exporting Unified Groups. Converts objects/aliases to fully-qualified
  SMTP Addresses.

- Import
  Use when importing Unified Groups. If domains haven't been moved between
  source and target during a migration, do nothing.  If domains have been moved,
  use the "IncludeUsers" switch.

- Set
  If performing a 2-stage migration (pre-create groups so content can be staged
  and then moving domains), run this param after the domains have been migrated
  to add the users back to the groups.

.PARAMETER RewriteTargetDomain
Use this switch to update the target domain address for users.  You can use this
with any mode (Export, Import, Set) to update the SMTP suffix of the users that
will be added back to groups.  Useful if you are performing a tenant to tenant
migration but not keeping the same address space (such as a divestiture).

.EXAMPLE
Export-AndImportUnifiedGroups -Mode Export -File MyUnifiedGroups.csv
Export unified groups.

.EXAMPLE
Export-AndImportUnifiedGroups -Mode Import -File MyUnifiedGroups.Csv -IncludeUsers
Import unified groups in a 1-stage migration (imports groups and users together)

.EXAMPLE
Export-AndImportUnifiedGroups -Mode Import -File MyUnifiedGroups.csv
Import unified groups in a 2-stage migration (import groups first, import users
later in a second pass).

.EXAMPLE
Export-AndImportUnifiedGroups -Mode Set -File MyUnifiedGroups.csv
Import users and set additional properties of previously imported Unified Groups.

.EXAMPLE
Export-AndImportUnifiedGroups -IncludeUsers -Mode Import -File MyUnifiedGroups.csv -RewriteTargetDomain -SourceDomain contoso.com -TargetDomain fabrikam.com
Import users while rewriting source domain from contoso.com to fabrikam.com in a
single-pass (1 stage) migration.  Use this when migrating Office 365 groups but not
preserving the domain name (such as in a divestiture scenario).

.LINK
Credit
Aaron Guilmette
https://gallery.technet.microsoft.com/Export-and-Import-Unified-e73d82ba

.NOTES
2017-10-27	- Fixed typo for Owners.
2017-10-25 	- Fixed parameter typos.
			- Updated import/set processing to check recipients prior to processing
			  and remove users that aren't valid recipients in the tenant.
#>
    param (
        [string]
        $File,

        [switch]
        $IncludeUsers,
        [validateset('Export', 'Import', 'Set')]
        $Mode,

        [Parameter(ParameterSetName = "Rewrite")]
        [switch]
        $RewriteTargetDomain,

        [Parameter(Mandatory = $false)]
        [string]
        $SourceDomain,

        [Parameter(Mandatory = $false)]
        [string]
        $TargetDomain
    )

    begin {

        $Selectproperties1 = @(
            'Alias', 'Name', 'DisplayName', 'AccessType'
        )

        $Selectproperties2 = @(
            'AllowAddGuests', 'AlwaysSubscribeMembersToCalendarEvents', 'AutoSubscribeNewMembers', 'BypassModerationFromSendersOrMembers'
            'CalendarMemberReadOnly', 'CalendarUrl', 'Classification', 'ConnectorsEnabled', 'CustomAttribute1', 'CustomAttribute2'
            'CustomAttribute3', 'CustomAttribute4', 'CustomAttribute5', 'CustomAttribute6', 'CustomAttribute7', 'CustomAttribute8'
            'CustomAttribute9', 'CustomAttribute10', 'CustomAttribute11', 'CustomAttribute12', 'CustomAttribute13', 'CustomAttribute14'
            'CustomAttribute15', 'ExchangeObjectId'
        )

        $Selectproperties3 = @(
            'EmailAddressPolicyEnabled', 'ExtenstionCustomAttribute1', 'ExtenstionCustomAttribute2', 'ExtenstionCustomAttribute3'
            'ExtenstionCustomAttribute4', 'ExtenstionCustomAttribute5', 'FileNotificationsSettings'
        )

        $Selectproperties4 = @(
            'HiddenFromAddressListsEnabled', 'HiddenGroupMembershipEnabled', 'InboxUrl', 'MailboxProvisioningConstraint'
        )
        $Selectproperties5 = @(
            'MaxReceiveSize', 'MaxSendSize'
        )
        $Selectproperties6 = @(
            'ModerationEnabled', 'Notes', 'PeopleUrl', 'PhotoUrl', 'PrimarySmtpAddress', 'ProvisioningOption'
        )
        $Selectproperties7 = @(
            'ReportToManagerEnabled', 'RequireSenderAuthenticationEnabled', 'SendModerationNotifications'
            'SendOofMessageToOriginatorEnabled', 'SharePointDocumentsUrl', 'SharePointNotebookUrl'
            'SharePointSiteUrl', 'SubscriptionEnabled', 'WelcomeMessageEnabled', 'YammerEmailAddress'
        )
        $CalculatedProps1 = @(
            @{N = "AcceptMessagesOnlyFrom"; E = { $AcceptMessagesOnlyFrom -join "," } },
            @{N = "AcceptMessagesOnlyFromDLMembers"; E = { $AcceptMessagesOnlyFromDLMembers -join "," } },
            @{N = "AcceptMessagesOnlyFromSendersOrMembers"; E = { $AcceptMessagesOnlyFromSendersOrMembers -join "," } }
        )

        $CalculatedProps2 = @(
            @{N = "EmailAddresses"; E = { $_.EmailAddresses -join "," } }
        )

        $CalculatedProps3 = @(
            @{N = "GrantSendOnBehalfTo"; E = { $GrantSendOnBehalfTo -join "," } }
        )

        $CalculatedProps4 = @(
            @{N = "ManagedBy"; E = { $ManagedBy -join "," } },
            @{N = "ManagedByDetails"; E = { $ManagedByDetails -join "," } },
            @{N = "Members"; E = { $Members -join "," } },
            @{N = "Owners"; E = { $Owners -join "," } },
            @{N = "Subscribers"; E = { $Subscribers -join "," } },
            @{N = "Aggregators"; E = { $Aggregators -join "," } }
        )
        $CalculatedProps5 = @(
            @{N = "ModeratedBy"; E = { $ModeratedBy -join "," } }
        )

        $CalculatedProps6 = @(
            @{N = "RejectMessagesFrom"; E = { $RejectMessagesFrom -join "," } },
            @{N = "RejectMessagesFromDLMembers"; E = { $RejectMessagesFromDLMembers -join "," } },
            @{N = "RejectMessagesFromSendersOrMembers"; E = { $RejectMessagesFromSendersOrMembers -join "," } }
        )
        If ($RewriteTargetDomain -and -not $SourceDomain -and -not $TargetDomain) {
            Write-Host -ForegroundColor Red "You cannot specify RewriteTargetDomain without specifying SourceDomain and TargetDomain parameters."
            Break
        }

        # Functions
        # The ReWriteTargetDomain switch is used for rewriting the target domain between
        # source and target environments.  It is a simple find/replace in the input or
        # output file. The ReWriteExoprt function operates on the original export before
        # it's written out to disk, and the ReWriteImport function creates a temporary
        # file while leaving the original export alone.
        function ReWriteExport($File, $SourceDomain, $TargetDomain) {
            (Get-Content $File) -replace $SourceDomain, $TargetDomain | Set-Content $File
        }

        function ReWriteImport($File, $SourceDomain, $TargetDomain) {
            $global:TempFile = "TempImport_" + (Get-Date -Format yyyymmddhhmmss) + ".csv"
            (Get-Content $File) -replace $SourceDomain, $TargetDomain | Set-Content $TempFile
        }

        Switch ($Mode) {
            Export {
                $UnifiedGroups = Get-UnifiedGroup -ResultSize Unlimited
                $Count = $UnifiedGroups.Count
                $i = 1
                Foreach ($Group in $UnifiedGroups) {
                    Write-Host "$($Group.Name) [$i of $Count]"
                    $Sub = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Subscribers
                    $Mem = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members
                    $Own = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Owners
                    $Agg = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Aggregators

                    # Resolve GrantSendOnBehalfTo
                    $GrantSendOnBehalfTo = @()
                    foreach ($addr in $Group.GrantSendOnBehalfTo) { $GrantSendOnBehalfTo += (Get-Recipient $addr).PrimarySmtpAddress }

                    #Resolve ManagedBy
                    $ManagedBy = @()
                    foreach ($addr in $Group.ManagedBy) { $ManagedBy += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve ManagedByDetails
                    $ManagedByDetails = @()
                    foreach ($addr in $Group.ManagedByDetails) { $ManagedByDetails += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve Members
                    $Members = @()
                    foreach ($addr in $Mem) { $Members += $addr.PrimarySmtpAddress }

                    # Resolve Subscribers
                    $Subscribers = @()
                    foreach ($addr in $Sub) { $Subscribers += $addr.PrimarySmtpAddress }

                    # Resolve Aggregators
                    $Aggregators = @()
                    foreach ($addr in $Agg) { $Aggregators += $addr.PrimarySmtpAddress }

                    # Resolve Owners
                    $Owners = @()
                    foreach ($addr in $Own) { $Owners += $addr.PrimarySmtpAddress }

                    # Resolve ModeratedBy
                    $ModeratedBy = @()
                    foreach ($addr in $Group.ModeratedBy) { $ModeratedBy += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve RejectMessagesFrom
                    $RejectMessagesFrom = @()
                    foreach ($addr in $Group.RejectMessagesFrom) { $RejectMessagesFrom += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve RejectMessagesFromSendersOrMembers
                    $RejectMessagesFromSendersOrMembers = @()
                    foreach ($addr in $Group.RejectMessagesFromSendersOrMembers) { $RejectMessagesFromSendersOrMembers += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve RejectMessagesFromDLMembers
                    $RejectMessagesFromDLMembers = @()
                    foreach ($addr in $Group.RejectMessagesFromDLMembers) { $RejectMessagesFromDLMembers += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve AcceptMessagesOnlyFrom
                    $AcceptMessagesOnlyFrom = @()
                    foreach ($addr in $Group.AcceptMessagesOnlyFrom) { $AcceptMessagesOnlyFrom += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve AcceptMessagesOnlyFromDLMembers
                    $AcceptMessagesOnlyFromDLMembers = @()
                    foreach ($addr in $Group.AcceptMessagesOnlyFromDLMembers) { $AcceptMessagesOnlyFromDLMembers += (Get-Recipient $addr).PrimarySmtpAddress }

                    # Resolve AcceptMessagesOnlyFromSendersOrMembers
                    $AcceptMessagesOnlyFromSendersOrMembers = @()
                    foreach ($addr in $Group.AcceptMessagesOnlyFromSendersOrMembers) { $AcceptMessagesOnlyFromSendersOrMembers += (Get-Recipient $addr).PrimarySmtpAddress }

                    $Group | Add-Member -TypeName NoteProperty -NotePropertyName Subscribers -NotePropertyValue ($Subscribers -join ",") -Force
                    $Group | Add-Member -TypeName NoteProperty -NotePropertyName Members -NotePropertyValue ($Members -join ",") -Force
                    $Group | Add-Member -TypeName NoteProperty -NotePropertyName Owners -NotePropertyValue ($Owners -join ",") -Force
                    $Group | Add-Member -TypeName NoteProperty -NotePropertyName Aggregators -NotePropertyValue ($Aggregators -join ",") -Force
                    $Group | Select-Object ($Selectproperties1 + $CalculatedProps1 + $Selectproperties2 + $CalculatedProps2 + $Selectproperties3 + $CalculatedProps3 + $Selectproperties4 + $CalculatedProps4 + $Selectproperties5 + $CalculatedProps5 + $Selectproperties6 + $CalculatedProps6 + $Selectproperties7) | Export-Csv -Append $File -NoTypeInformation
                    $i++
                    $Group = $null
                } #End Foreach ($Group in UnifiedGroups)
                If ($RewriteTargetDomain) {
                    RewriteExport -File $File -SourceDomain $SourceDomain -TargetDomain $TargetDomain
                }
            } # End Switch Export
            Import {
                If ($RewriteTargetDomain) {
                    RewriteImport -File $File -SourceDomain $SourceDomain -TargetDomain $TargetDomain
                    $UnifiedGroups = Import-Csv $TempFile
                    Write-Host Importing $($TempFile)
                }
                Else {
                    $UnifiedGroups = Import-Csv $File
                }
                $Count = $UnifiedGroups.Count
                $i = 1
                foreach ($Group in $UnifiedGroups) {
                    Write-Host "Creating group $($Group.Name) [$i of $Count]"
                    New-UnifiedGroup -Name $Group.Name `
                        -Alias $Group.Alias `
                        -DisplayName $Group.DisplayName `
                        -AccessType $Group.AccessType `
                        -Classification $Group.Classification
                    $cmd = "Set-UnifiedGroup -Identity $($Group.Alias) "
                    $cmd += "-RequireSenderAuthenticationEnabled $" + "$($Group.RequireSenderAuthenticationEnabled) "
                    If ($Group.HiddenFromAddressListsEnabled) { $cmd += "-HiddenFromAddressListsEnabled $" + "$($Group.HiddenFromAddressListsEnabled)" }

                    # Unable to set these properties at this time
                    #If ($Group.HiddenGroupMembershipEnabled) { $cmd += "-HiddenGroupMembershipEnabled $" + "$($Group.HiddenGroupMembershipEnabled) " }
                    #If ($Group.AutoSubscribeNewMembers) { $cmd += "-AutoSubscribeNewMembers $" + "$($Group.AutoSubscribeNewMembers) " }
                    #If ($Group.SubscriptionEnabled) { $cmd += "-SubscriptionEnabled $" + "$($Group.SubscriptionEnabled) "}
                    #If ($Group.AlwaysSubscribeMembersToCalendarEvents) { $cmd += "-AlwaysSubscribeMembersToCalendarEvents $" + "$($Group.AlwaysSubscribeMembersToCalendarEvents) "}
                    #If ($Group.ReportToManagerEnabled) { $cmd += "-ReportToManagerEnabled $" + "$($Group.ReportToManagerEnabled) "}
                    #If ($Group.SendOofMessageToOriginatorEnabled) { $cmd += "-SendOofMessageToOriginatorEnabled $" + "$($Group.SendOofMessageToOriginatorEnabled) "}
                    #If ($Group.WelcomeMessageEnabled) { $cmd += "-WelcomeMessageEnabled $" + "$($Group.WelcomeMessageEnabled) " }
                    Invoke-Expression $cmd

                    # If the IncludeUsers switch has been specified, use this
                    If ($IncludeUsers) {
                        $AllRecipients = (Get-Recipient -ResultSize Unlimited).PrimarySmtpAddress

                        $Members = @()
                        [array]$Members_All = $Group.Members.Split(",")
                        foreach ($Member_obj in $Members_All) {
                            if ($AllRecipients -contains $Member_obj) { $Members += $Member_obj }
                        }

                        $Subscribers = @()
                        [array]$Subscribers_All = $Group.Subscribers.Split(",")
                        foreach ($Subscriber_obj in $Subscribers_All) {
                            if ($AllRecipients -contains $Subscriber_obj) { $Subscribers += $Subscriber_obj }
                        }

                        $Owners = @()
                        [array]$Owners_All = $Group.Owners.Split(",")
                        foreach ($Owner_obj in $Owners_All) {
                            if ($AllRecipients -contains $Owner_obj) { $Owners += $Owner_obj }
                        }

                        $Aggregators = @()
                        [array]$Aggregators_All = $Group.Aggregators.Split(",")
                        foreach ($Aggregator_obj in $Aggregators_All) {
                            if ($AllRecipients -contains $Aggregator_obj) { $Aggregators += $Aggregator_obj }
                        }

                        $ManagedByDetails = @()
                        [array]$ManagedByDetails_All = $Group.ManagedByDetails.Split(",")
                        foreach ($ManagedByDetails_obj in $ManagedByDetails_All) {
                            if ($AllRecipients -contains $ManagedByDetails_obj) { $ManagedByDetails += $ManagedByDetails_obj }
                        }

                        $ManagedBy = @()
                        [array]$ManagedBy_All = $Group.ManagedBy.Split(",")
                        foreach ($ManagedBy_obj in $ManagedBy_All) {
                            if ($AllRecipients -contains $ManagedBy_Obj) { $ManagedBy += $ManagedBy_Obj }
                        }

                        $ModeratedBy = @()
                        [array]$ModeratedBy_All = $Group.ModeratedBy.Split(",")
                        foreach ($ModeratedBy_obj in $ModeratedBys_All) {
                            if ($AllRecipients -contains $ModeratedBy_Obj) { $ModeratedBy += $ModeratedBy_Obj }
                        }

                        $AcceptMessagesOnlyFrom = @()
                        [array]$AcceptMessagesOnlyFrom_All = $Group.AcceptMessagesOnlyFrom.Split(",")
                        foreach ($AcceptMessagesOnlyFrom_obj in $AcceptMessagesOnlyFrom_All) {
                            if ($AllRecipients -contains $AcceptMessagesOnlyFrom_Obj) { $AcceptMessagesOnlyFrom += $AcceptMessagesOnlyFrom_Obj }
                        }

                        $AcceptMessagesOnlyFromDLMembers = @()
                        [array]$AcceptMessagesOnlyFromDLMembers_All = $Group.AcceptMessagesOnlyFromDLMembers.Split(",")
                        foreach ($AcceptMessagesOnlyFromDLMembers_obj in $AcceptMessagesOnlyFromDLMembers_All) {
                            if ($AllRecipients -contains $AcceptMessagesOnlyFromDLMembers_Obj) { $AcceptMessagesOnlyFromDLMembers += $AcceptMessagesOnlyFromDLMembers_Obj }
                        }

                        $AcceptMessagesOnlyFromSendersOrMembers = @()
                        [array]$AcceptMessagesOnlyFromSendersOrMembers_All = $Group.AcceptMessagesOnlyFromSendersOrMembers.Split(",")
                        foreach ($AcceptMessagesOnlyFromSendersOrMembers_obj in $AcceptMessagesOnlyFromSendersOrMembers_All) {
                            if ($AllRecipients -contains $AcceptMessagesOnlyFromSendersOrMembers_Obj) { $AcceptMessagesOnlyFromSendersOrMembers += $AcceptMessagesOnlyFromSendersOrMembers_Obj }
                        }

                        $RejectMessagesFrom = @()
                        [array]$RejectMessagesFrom_All = $Group.RejectMessagesFrom.Split(",")
                        foreach ($RejectMessagesFrom_obj in $RejectMessagesFrom_All) {
                            if ($AllRecipients -contains $RejectMessagesFrom_Obj) { $RejectMessagesFrom += $RejectMessagesFrom_Obj }
                        }

                        $GrantSendOnBehalfTo = @()
                        [array]$GrantSendOnBehalfTo_All = $Group.GrantSendOnBehalfTo.Split(",")
                        foreach ($GrantSendOnBehalfTo_obj in $GrantSendOnBehalfTo_All) {
                            if ($AllRecipients -contains $GrantSendOnBehalfTo_Obj) { $GrantSendOnBehalfTo += $GrantSendOnBehalfTo_Obj }
                        }

                        $RejectMessagesFromSendersOrMembers = @()
                        [array]$RejectMessagesFromSendersOrMembers_All = $Group.RejectMessagesFromSendersOrMembers.Split(",")
                        foreach ($RejectMessagesFromSendersOrMembers_obj in $RejectMessagesFromSendersOrMembers_All) {
                            if ($AllRecipients -contains $RejectMessagesFromSendersOrMembers_Obj) { $RejectMessagesFromSendersOrMembers += $RejectMessagesFromSendersOrMembers_Obj }
                        }

                        $RejectMessagesFromDLMembers = @()
                        [array]$RejectMessagesFromDLMembers_All = $Group.RejectMessagesFromDLMembers.Split(",")
                        foreach ($RejectMessagesFromDLMembers_obj in $RejectMessagesFromDLMembers_All) {
                            if ($AllRecipients -contains $RejectMessagesFromDLMembers_Obj) { $RejectMessagesFromDLMembers += $RejectMessagesFromDLMembers_Obj }
                        }

                        # Add Group Links
                        # Members
                        $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                        If ($Members) { $cmd += "-LinkType Members -Links `$Members " }
                        Invoke-Expression $cmd

                        # Subscribers
                        $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                        If ($Subscribers) { $cmd += "-LinkType Subscribers -Links `$Subscribers " }

                        # Owners
                        $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                        If ($Owners) { $cmd += "-LinkType Owners -Links `$Owners " }

                        # Aggregators
                        $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                        If ($Aggregators) { $cmd += "-LinkType Aggregators -Links`$Aggregators " }

                        # Unable to set these properties at this time
                        #If ($ManagedByDetails) { $cmd += "-ManagedByDetails `$ManagedByDetails " }
                        #If ($ModeratedBy) { $cmd += "-ModeratedBy `$ModeratedBy " }

                        # Accept and reject settings
                        $cmd = "Set-UnifiedGroup -Identity $($Group.Alias) "
                        If ($AcceptMessagesOnlyFrom) { $cmd += "-AcceptMessagesOnlyFrom `$AcceptMessagesOnlyFrom " }
                        If ($AcceptMessagesOnlyFromDLMembers) { $cmd += "-AcceptMessagesOnlyFromDLMembers `$AcceptMessagesOnlyFromDLMembers " }
                        If ($AcceptMessagesOnlyFromSendersOrMembers) { $cmd += "-AcceptMessagesOnlyFromSendersOrMembers `$AcceptMessagesOnlyFromSendersOrMembers " }
                        If ($RejectMessagesFrom) { $cmd += "-RejectMessagesFrom `$RejectMessagesFrom " }
                        If ($GrantSendOnBehalfTo) { $cmd += "-GrantSendOnBehalfTo `$GrantSendOnBehalfTo " }
                        If ($RejectMessagesFromSendersOrMembers) { $cmd += "-RejectMessagesFromSendersOrMembers `$RejectMessagesFromSendersOrMembers " }
                        If ($RejectMessagesFromDLMembers) { $cmd += "-RejectMessagesFromDLMembers `$RejectMessagesFromDLMembers" }
                        Invoke-Expression $cmd
                    } #End If IncludeUsers
                    $i++
                } # End Foreach
            } # End Import

            Set {
                $AllRecipients = (Get-Recipient -ResultSize Unlimited).PrimarySmtpAddress
                If ($RewriteTargetDomain) {
                    RewriteImport -File $File -SourceDomain $SourceDomain -TargetDomain $TargetDomain
                    $UnifiedGroups = Import-Csv $TempFile
                }
                Else {
                    $UnifiedGroups = Import-Csv $File
                }
                foreach ($Group in $UnifiedGroups) {
                    Write-Host "Processing $($Group.Name) [$i of $Count]"
                    $Members = @()
                    [array]$Members_All = $Group.Members.Split(",")
                    foreach ($Member_obj in $Members_All) {
                        if ($AllRecipients -contains $Member_obj) { $Members += $Member_obj }
                    }

                    $Subscribers = @()
                    [array]$Subscribers_All = $Group.Subscribers.Split(",")
                    foreach ($Subscriber_obj in $Subscribers_All) {
                        if ($AllRecipients -contains $Subscriber_obj) { $Subscribers += $Subscriber_obj }
                    }

                    $Owners = @()
                    [array]$Owners_All = $Group.Owners.Split(",")
                    foreach ($Owner_obj in $Owners_All) {
                        if ($AllRecipients -contains $Owner_obj) { $Owners += $Owner_obj }
                    }

                    $Aggregators = @()
                    [array]$Aggregators_All = $Group.Aggregators.Split(",")
                    foreach ($Aggregator_obj in $Aggregators_All) {
                        if ($AllRecipients -contains $Aggregator_obj) { $Aggregators += $Aggregator_obj }
                    }

                    $ManagedByDetails = @()
                    [array]$ManagedByDetails_All = $Group.ManagedByDetails.Split(",")
                    foreach ($ManagedByDetails_obj in $ManagedByDetails_All) {
                        if ($AllRecipients -contains $ManagedByDetails_obj) { $ManagedByDetails += $ManagedByDetails_obj }
                    }

                    $ManagedBy = @()
                    [array]$ManagedBy_All = $Group.ManagedBy.Split(",")
                    foreach ($ManagedBy_obj in $ManagedBy_All) {
                        if ($AllRecipients -contains $ManagedBy_Obj) { $ManagedBy += $ManagedBy_Obj }
                    }

                    $ModeratedBy = @()
                    [array]$ModeratedBy_All = $Group.ModeratedBy.Split(",")
                    foreach ($ModeratedBy_obj in $ModeratedBys_All) {
                        if ($AllRecipients -contains $ModeratedBy_Obj) { $ModeratedBy += $ModeratedBy_Obj }
                    }

                    $AcceptMessagesOnlyFrom = @()
                    [array]$AcceptMessagesOnlyFrom_All = $Group.AcceptMessagesOnlyFrom.Split(",")
                    foreach ($AcceptMessagesOnlyFrom_obj in $AcceptMessagesOnlyFrom_All) {
                        if ($AllRecipients -contains $AcceptMessagesOnlyFrom_Obj) { $AcceptMessagesOnlyFrom += $AcceptMessagesOnlyFrom_Obj }
                    }

                    $AcceptMessagesOnlyFromDLMembers = @()
                    [array]$AcceptMessagesOnlyFromDLMembers_All = $Group.AcceptMessagesOnlyFromDLMembers.Split(",")
                    foreach ($AcceptMessagesOnlyFromDLMembers_obj in $AcceptMessagesOnlyFromDLMembers_All) {
                        if ($AllRecipients -contains $AcceptMessagesOnlyFromDLMembers_Obj) { $AcceptMessagesOnlyFromDLMembers += $AcceptMessagesOnlyFromDLMembers_Obj }
                    }

                    $AcceptMessagesOnlyFromSendersOrMembers = @()
                    [array]$AcceptMessagesOnlyFromSendersOrMembers_All = $Group.AcceptMessagesOnlyFromSendersOrMembers.Split(",")
                    foreach ($AcceptMessagesOnlyFromSendersOrMembers_obj in $AcceptMessagesOnlyFromSendersOrMembers_All) {
                        if ($AllRecipients -contains $AcceptMessagesOnlyFromSendersOrMembers_Obj) { $AcceptMessagesOnlyFromSendersOrMembers += $AcceptMessagesOnlyFromSendersOrMembers_Obj }
                    }

                    $RejectMessagesFrom = @()
                    [array]$RejectMessagesFrom_All = $Group.RejectMessagesFrom.Split(",")
                    foreach ($RejectMessagesFrom_obj in $RejectMessagesFrom_All) {
                        if ($AllRecipients -contains $RejectMessagesFrom_Obj) { $RejectMessagesFrom += $RejectMessagesFrom_Obj }
                    }

                    $GrantSendOnBehalfTo = @()
                    [array]$GrantSendOnBehalfTo_All = $Group.GrantSendOnBehalfTo.Split(",")
                    foreach ($GrantSendOnBehalfTo_obj in $GrantSendOnBehalfTo_All) {
                        if ($AllRecipients -contains $GrantSendOnBehalfTo_Obj) { $GrantSendOnBehalfTo += $GrantSendOnBehalfTo_Obj }
                    }

                    $RejectMessagesFromSendersOrMembers = @()
                    [array]$RejectMessagesFromSendersOrMembers_All = $Group.RejectMessagesFromSendersOrMembers.Split(",")
                    foreach ($RejectMessagesFromSendersOrMembers_obj in $RejectMessagesFromSendersOrMembers_All) {
                        if ($AllRecipients -contains $RejectMessagesFromSendersOrMembers_Obj) { $RejectMessagesFromSendersOrMembers += $RejectMessagesFromSendersOrMembers_Obj }
                    }

                    $RejectMessagesFromDLMembers = @()
                    [array]$RejectMessagesFromDLMembers_All = $Group.RejectMessagesFromDLMembers.Split(",")
                    foreach ($RejectMessagesFromDLMembers_obj in $RejectMessagesFromDLMembers_All) {
                        if ($AllRecipients -contains $RejectMessagesFromDLMembers_Obj) { $RejectMessagesFromDLMembers += $RejectMessagesFromDLMembers_Obj }
                    }

                    # Add Group Links
                    # Members
                    $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                    If ($Members) { $cmd += "-LinkType Members -Links `$Members " }
                    Invoke-Expression $cmd

                    # Subscribers
                    $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                    If ($Subscribers) { $cmd += "-LinkType Subscribers -Links `$Subscribers " }

                    # Owners
                    $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                    If ($Owners) { $cmd += "-LinkType Owners -Links `$Owners " }

                    # Aggregators
                    $cmd = "Add-UnifiedGroupLinks -Identity $($Group.Alias) "
                    If ($Aggregators) { $cmd += "-LinkType Aggregators -Links`$Aggregators " }

                    # Unable to set these properties at this time
                    #If ($ManagedByDetails) { $cmd += "-ManagedByDetails `$ManagedByDetails " }
                    #If ($ModeratedBy) { $cmd += "-ModeratedBy `$ModeratedBy " }

                    # Accept and reject settings
                    $cmd = "Set-UnifiedGroup -Identity $($Group.Alias) "
                    If ($AcceptMessagesOnlyFrom) { $cmd += "-AcceptMessagesOnlyFrom `$AcceptMessagesOnlyFrom " }
                    If ($AcceptMessagesOnlyFromDLMembers) { $cmd += "-AcceptMessagesOnlyFromDLMembers `$AcceptMessagesOnlyFromDLMembers " }
                    If ($AcceptMessagesOnlyFromSendersOrMembers) { $cmd += "-AcceptMessagesOnlyFromSendersOrMembers `$AcceptMessagesOnlyFromSendersOrMembers " }
                    If ($RejectMessagesFrom) { $cmd += "-RejectMessagesFrom `$RejectMessagesFrom " }
                    If ($GrantSendOnBehalfTo) { $cmd += "-GrantSendOnBehalfTo `$GrantSendOnBehalfTo " }
                    If ($RejectMessagesFromSendersOrMembers) { $cmd += "-RejectMessagesFromSendersOrMembers `$RejectMessagesFromSendersOrMembers " }
                    If ($RejectMessagesFromDLMembers) { $cmd += "-RejectMessagesFromDLMembers `$RejectMessagesFromDLMembers" }
                    Invoke-Expression $cmd
                    $i++
                }
            } # End Set
        } # End Switch

        #Cleanup
        If ($TempFile) { Remove-Item $TempFile }
    }
    Process {

    }
    End {

    }
}
