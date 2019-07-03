# About Posh365*


## Add-365RecipientEmailAddresses

Add Recipients Email Addresses and other functions


## Add-ConnectionFilterPolicyDetail

Adds Detail to Connection Filter Policy. Specifically, Allowed/Blocked IP Addresses. If the Connection Filter Policy does not exist, it creates it.


## Add-ContentFilterPolicyDetail

Adds Detail to Content Filter Policy. Specifically, Allowed/Blocked Senders and Domains


## Add-ForwarderToExoMailbox

Waits for an Exchange Online Mailbox to be provisioned then adds a forwarder.
Prefix of forwarder is the mailbox's PrimarySmtpAddress and the Suffix is specified at runtime.


## Add-Task

Create Scheduled Tasks


## Add-TaskByMinute

Create Scheduled Tasks


## Add-TaskDaily

Create Scheduled Tasks that run daily


## Add-TaskWeekly

Create Scheduled Tasks that run on a weekly schedule
Make sure directory structure is in place


## Add-TransportRuleDetail

Adds details to Transport Rule.  If the transport rule does not exist it creates it.


## Add-UserToOktaGroup

Add any user that lives in Okta to Okta Groups (these are groups mastered in Okta Only)


## Clear-SFBAttribute

Clear Attributes of On-Premises Skype users to prepare for Skype For Business Online
Can be tweaked to remove any attributes.
Run this from PowerShell for Active Directory Users and Computers
Use with caution as this removes attributes
This is often use to prep

The process to move from On-Premises Skype to Skype for Business Online (where there is not hybrid or transition, contact lists are NOT preserved)

1. Remove Skype for Business Licenses from user(s)
    Install-Module Posh365 -Force -SkipPublisherCheck  (Run PowerShell as admin. this step is one-time thing)
    Connect-Cloud -tenant Contoso -AzureADver2
    Get-Content .\UpnList.txt | Set-CloudLicense -RemoveOptions    (Select-click all entries named Skype & click OK)
2. Sync AD Connect
    Sync-ADConnect   (if prompted, select the AD Connect server name & click OK)
3. Remove attributes with this script (run from on-premises Active Directory PowerShell as administrator)
4. Repeat Step #2
5. Add Skype License Back
    Get-Content .\UpnList.txt | Set-CloudLicense -AddOptions  (Select one entry named Skype & click OK)


## Compare-Csv




## Compare-GroupMembership




## Compare-List




## Complete-MailboxSync

Allows the completion or the scheduling of the completion of move requests


## Connect-Cloud

Connects to Office 365 services and/or Azure.

Connects to some or all of the Office 365/Azure services based on switches provided at runtime.

Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter.
The -Tenant parameter is mandatory.

There is a switch to use Multi-Factor Authentication.
For Exchange Online MFA, you are required to download and use the Exchange Online Remote PowerShell Module.
To download the Exchange Online Remote PowerShell Module for multi-factor authentication ONCE, in the EAC (https://outlook.office365.com/ecp/), go to Hybrid \> Setup and click the appropriate Configure button.
When using Multi-Factor Authentication the saving of credentials is not available currently - thus each service will prompt independently for credentials.

Locally saves and encrypts to a file the username and password.
The encrypted file...can only be used on the computer and within the user's profile from which it was created, is the same .txt file for all the Office 365 services and is a separate .json file for Azure.
If a username or password becomes corrupt or is entered incorrectly, it can be deleted using -DeleteCreds.
For example, Connect-Cloud Contoso -DeleteCreds

If Azure switch is used for first time :

1. User will login as normal when prompted by Azure
2. User will be prompted to select which Azure Subscription
3. Select the subscription and click "OK"

If Azure switch is used after first time:

1. User will be prompted to pick username used previously
2. If a new username is to be used (e.g.username not found when prompted), click Cancel to be prompted to login.
3. User will be prompted to select which Azure Subscription
4. Select the subscription and click "OK"

Directories used/created during the execution of this script

1. $env:USERPROFILE\ps\
2. $env:USERPROFILE\ps\creds\

All saved credentials are saved in `$env:USERPROFILE\ps\creds\`
Transcript is started and kept in `$env:USERPROFILE\ps\<tenantspecified>`


## Connect-Exchange

Connects to On-Premises Microsoft Exchange Server. By default, prefixes all commands with, "OnPrem".
For example, Get-OnPremMailbox. Use the NoPrefix parameter to prevent this.


## Connect-Graph




## Connect-OktaSecure




## Connect-SharePointPNP




## Convert-OktaRateLimitToSleep




## ConvertTo-Shared




## Disable-Employee




## Expand-IdFixReport




## Export-AndImportUnifiedGroups

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


## Export-CsvData

Export ProxyAddresses from a CSV and output one per line.  Filtering if desired.


## Export-CsvDataforGroups

Export ProxyAddresses from a CSV and output one per line.  Filtering if desired.  Automatically a csv will be exported.


## Export-CsvJoinedData

Export specified column from a CSV and output one per line.  Filtering if desired.  Automatically a csv will be exported.


## Export-GoogleAddress

Long description


## Export-GoogleAlias

Google's GAM tool exports aliases
This transforms that data and exports it into an importable format in the Microsoft world


## Export-GoogleForward




## Export-GoogleInitialandPhone

Exports all organizational related information from Google GAM output to then be imported into Microsoft's environments


## Export-GoogleOrganization

Exports all organizational related information from Google GAM output to then be imported into Microsoft's environments


## Export-GooglePhysicalAddress




## Export-QCsvData

Export ProxyAddresses from a CSV and output one per line.  Filtering if desired.  Automatically a csv will be exported.


## Get-365Info

Controller function for gathering information from an Office 365 tenant

All multivalued attributes are expanded for proper output

What information is gathered:
1. Recipients
2. MsolUsers
3. MsolGroups
4. Distribution Groups (includes mail-enabled Security Groups)
5. Mailboxes
6. Archive Mailboxes
7. Resource Mailboxes with Calendar Processing
8. Licenses assigned to each user broken out by Options
9. Retention Policies and linked Retention Tags in a single report

If using the -Filtered switch, it will be necessary to replace domain placeholders in script (e.g. contoso.com etc.)
The filters can be adjusted to anything supported by the -Filter parameter (OPath filters)


## Get-365MobileDevice




## Get-365MsolGroup

Export Office 365 MsolGroups


## Get-365MsolGroupMember




## Get-365MsolUser

Export Office 365 MsolUsers


## Get-365Recipient

Export Office 365 Recipients


## Get-365RecipientEmailAddresses

Export Office 365 Recipients Email Addresses one per line


## Get-ActiveCasConnection

Collect counters that show point-in-time use of various protocols (IMAP, POP, EWS, IIS, OWA, RPC)
If you have mixed environment run from highest version
For example, if you have Exchange 2010, 2013 and 2016 - Run from Exchange 2016 server

NOTE: This is designed to run against servers where the services are running.
You must verify POP and IMAP service is running on all the CAS servers prior to adding it to the list of servers

For example, if the POP service is not running, add '#' to the POP object below, just like this:
`# POP    = [math]::Truncate((Get-Counter "\MSExchangePOP3(_total)\Connections Current" -ComputerName $CurServer).CounterSamples[0].Cookedvalue)`

To verify POP3 and/or IMAP4 service is running run these commands (once):
```
$CAS = Get-ClientAccessServer | Select -ExpandProperty name
$CAS |  % {write-host "`n`nServer: $($_)`nPOP3" -foregroundcolor "Green";Get-service -ComputerName $_ -ServiceName MSExchangePOP3 | Select -expandproperty status }
$CAS |  % {write-host "`n`nServer: $($_)`nIMAP4" -foregroundcolor "Cyan";Get-service -ComputerName $_ -ServiceName MSExchangeIMAP4 | Select -expandproperty status }
```


## Get-ActiveDirectoryContact

Export Active Directory Contacts


## Get-ActiveDirectoryGroup

Export Office 365 Distribution & Mail-Enabled Security Groups


## Get-ActiveDirectoryObject

Export Active Directory Objects


## Get-ActiveDirectoryUser

Export Active Directory Users


## Get-ActiveDirectoryUserByOU

Export Active Directory Users by OU


## Get-ActiveDirectoryUserFiltered

Get ADUsers filtered by attributes.  Provide the name of attribute(s) and the function will look for a txt file of the same name.
The txt file will contain the values to be found.


## Get-ADConnectError

Provides in readable format, all AD Connect provisioning errors within MSOnline


## Get-ADReplication




## Get-AuditLog

Collects all data from Office 365 Unified Audit Log a specified number of minutes in the past till now


## Get-AzureInventory




## Get-AzureLoadBalancerReport




## Get-AzureNSGReport




## Get-AzureReport




## Get-AzureStorageReport




## Get-AzureTrafficManagerEndpointReport




## Get-AzureTrafficManagerReport




## Get-AzureVMReport




## Get-AzureVNetReport




## Get-AzureVPNReport




## Get-CloudLicense

Report on Office 365 License SKUs and Options assigned to each user


## Get-Cred




## Get-DGPerms




## Get-DGSendAsPerms




## Get-DiscoveryInfo




## Get-DistributionGroupMembers

Determines the Groups that a recipient is a member of.  Either recursively or not.


## Get-DistributionGroupMembersHash

Creates a hash table from data returned from Get-DistributionGroupMembership


## Get-DistributionGroupMembership

Determines the Groups that a recipient is a member of.  Either recursively or not.


## Get-DistributionGroupMembershipHash

Creates a hash table from data returned from Get-DistributionGroupMembership


## Get-EdiscoveryCase

The script in this article lets eDiscovery administrators and eDiscovery managers generate a report that contains
information about all holds that are associated with eDiscovery cases in the Office 365 Security & Compliance Center.

To generate a report on all eDiscovery cases in your organization, you have to be an eDiscovery Administrator in your organization.


## Get-ExchangeAddressBookPolicy

## Get-ExchangeAddressList

## Get-ExchangeDistributionGroup

Export Office 365 Distribution & Mail-Enabled Security Groups


## Get-ExchangeGlobalAddressList

## Get-ExchangeListandPolicy

Long description


## Get-ExchangeMailbox

Export Exchange Mailboxes


## Get-ExchangeMailboxStatistics

Get Exchange Mailbox Statistics using GB's as the unit of measurement.
Includes Archive Mailbox and Total of both standard and archive mailbox.
Item Count does not include archive mailbox.


## Get-ExchangeOfflineAddressBook

## Get-ExchangeReceiveConnector

Export on-premises Receive Connectors


## Get-ExchangeSendConnector

Export on-premises Send Connectors


## Get-EXODGPerms

By default, creates permissions reports for all Distribution Groups with SendAs, SendOnBehalf and FullAccess delegates.
Switches can be added to isolate one or more reports

Also a file (or command) containing names of Users & Groups - used to isolate report to specific Distribution Groups.
The file must contain users (and groups, as groups can have permissions to Distribution Groups).

Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.

Output CSVs headers:
"Object","ObjectPrimarySMTP","Granted","GrantedPrimarySMTP","RecipientTypeDetails","Permission"


## Get-EXOFullAccessPerms




## Get-EXOFullAccessRecursePerms




## Get-EXOGroup

Export Office 365 Distribution & Mail-Enabled Security Groups


## Get-EXOMailbox

Export Office 365 Mailboxes


## Get-EXOMailboxPerms

By default, creates permissions reports for all mailboxes with SendAs, SendOnBehalf and FullAccess delegates.
Switches can be added to isolate one or more reports

Also a file (or command) containing names of Users & Groups - used to isolate report to specific mailboxes.
The file must contain users (and groups, as groups can have permissions to mailboxes).

Creates individual reports for each permission type (unless skipped), and a report that combines all CSVs in chosen directory.

Output CSVs headers:
"Mailbox","MailboxPrimarySMTP","Granted","GrantedPrimarySMTP","RecipientTypeDetails","Permission"


## Get-EXOMailboxRecursePerms




## Get-EXOMailContact

Export Office 365 Mail Contacts


## Get-EXOMigrationStatistics

Provides each user found in Get-MigrationUser in an Out-GridView.  The user can select one or more users for the report provided by Get-MigrationUserStatistics -Include report.
Each report will open in a seperate Out-GridView


## Get-EXOResourceMailbox

Export Office 365 Resource Mailboxes and Calendar Processing


## Get-EXOSendAsPerms




## Get-EXOSendAsRecursePerms




## Get-EXOSendOnBehalfPerms




## Get-EXOSendOnBehalfRecursePerms




## Get-FullAccessPerms




## Get-GraphDeltaMailEnabledUser




## Get-GraphMailEnabledUser




## Get-GraphMailFolder




## Get-GraphMailFolderPathId

Long description


## Get-GraphMailMessage




## Get-GraphOrgContact




## Get-GraphSecureScore




## Get-GraphUser




## Get-GraphUserAll




## Get-GSGraphDeltaUser




## Get-GSGraphExchangeUser




## Get-GSGraphUserAll




## Get-InvalidMailPublicFolderAliasReport

Export Report of Mail-Enabled Public Folders with Spaces


## Get-InvalidPublicFolderCharacterReport

Export Report of Public Folders with Invalid Characters


## Get-LegacyPFStatistics

## Get-MailboxFolderPerms




## Get-MailboxPerms




## Get-MailboxSync

Get mailbox moves/syncs


## Get-MailboxSyncReport

Provides each user found in Get-MoveRequest in an Out-GridView.
The user can select one or more users for the report provided by Get-MoveRequestStatistics -Includereport.
Each report will open in a seperate Out-GridView
The title bar contains important bits of information as well as the report beneath it.
Uses Out-GridView automatically


## Get-MailboxSyncStatistics

Get Move Request Statistics and refresh by clicking OK
Uses Out-GridView to display and allows user to click OK to refresh


## Get-MfaStats




## Get-ModifiedMailboxItem




## Get-OktaAppGroupReport




## Get-OktaAppReport




## Get-OktaDiscovery

Runs the Okta Discovery Scripts


## Get-OktaGroupMemberReport

Searches for specific or all Okta Groups and lists their members.  Use no parameters to return all Groups. e.g Get-OktaGroupMemberReport


## Get-OktaGroupMembership




## Get-OktaGroupReport

Searches for specific or all Okta Groups.  Use no parameters to return all Groups. e.g Get-OktaGroupReport


## Get-OktaGroupUserMembershipReport




## Get-OktaPolicyReport




## Get-OktaUserAppReport




## Get-OktaUserGroupMembershipReport




## Get-OktaUserReport

Searches for specific or all Okta Users.  Use no parameters to return all users. e.g Get-OktaUserReport


## Get-OneDriveReport




## Get-PermissionChain




## Get-PFMailboxPerms




## Get-PFSendAsPerms




## Get-PFSendOnBehalfPerms




## Get-RetentionLinks




## Get-SendAsPerms




## Get-SendOnBehalfPerms




## Get-SingleOktaUserReport




## Get-SPN

Retrieves all SPNs


## Get-SPOWeb




## Get-VirtualDirectoryInfo

This script will create an HTML-report which will gather the URL-information from different virtual directories over different Exchange Servers


## Grant-FullAccessToMailbox




## Grant-OneDriveAdminAccess




## Import-365MsolUser




## Import-365UnifiedGroup

Import Office 365 Unified Groups


## Import-ActiveDirectoryGroupMember

Import Active Directory Group Members


## Import-ADData




## Import-ADGroupProxyAddress

Import ProxyAddresses into Active Directory.  Also, can clear existing proxyaddresses.
Can update MAIL attribute with the Primary SMTP Address it finds in the column you choose.


## Import-ADUserProxyAddress

Import ProxyAddresses into Active Directory.  Also, can clear existing proxyaddresses.
Can update UserPrincipalName with the Primary SMTP Address it finds in the column you choose.
Can also update MAIL attribute with same Primary SMTP Address.


## Import-AzureADProperty

Import AzureADUser properties to Office 365 cloud-only accounts


## Import-AzureADUser




## Import-ExchangeFolderPermission

Import Folder Permissions from a CSV via the pipeline
Script expects Data Source to have 3 headers named: Folder, User, DetailLevel
You can replace values in Folder with Domain, NewDomain parameters


## Import-ExchangeFullAccess

Import Full Access Permissions from a CSV via the pipeline
Script expects Data Source to have 2 headers named, PrimarySmtpAddress & ObjectWithAccess
You can replace values in ObjectWithAccess with Domain, NewDomain parameters


## Import-ExchangeSendAs

Import SendAs Permissions from a CSV via the pipeline
Script expects Data Source to have 2 headers named, UserPrincipalName & ObjectWithAccess
You can replace values in ObjectWithAccess with Domain, NewDomain parameters


## Import-ExchangeSendOnBehalf

Import SendOnBehalf Permissions from a CSV via the pipeline
Script expects Data Source to have 2 headers named, PrimarySmtpAddress & ObjectWithAccess
You can replace values in ObjectWithAccess with Domain, NewDomain parameters


## Import-EXOGroup

Import Office 365 Distribution Groups


## Import-EXOGroupPermissions

Applies permissions to Exchange Online Groups


## Import-EXOMailboxPermissions

Applies permissions to Exchange Online Mailboxes Full Access will automap the mailbox
In other words, Outlook automatically opens the mailbox where the user is assigned Full Access permission.


## Import-EXOResourceMailboxSettings

Convert User Mailbox to Room or Equipment Mailbox and add specific settings


## Import-GoogleAliasToEXOGroup




## Import-GoogleAliasToEXOMailbox

Imports Aliases (Google calls secondary email addresses Aliases) to existing Cloud-Only Mailboxes


## Import-GoogleCalendarPermissionToEXO

Assign Groups Permissions to Calendar Folders of 365 mailboxes
This is specific to Groups but can be tweaked for users specifically.


## Import-GoogleTo365Group

Import CSV of Google Groups into Office 365 as Office 365 Groups (Unified Groups)


## Import-GoogleToChangeUpn

Modifies existing UPNs from a CSV containing the header PrimarySmtpAddress
Note this will not succeed when changing cloud only Upn's with federated domain names


## Import-GoogleToEXOGroup

Import CSV of Google Groups into Office 365 as Distribution Groups


## Import-GoogleToEXOGroupMember

Import CSV of Google Group Members into Office 365 as Distribution Groups


## Import-GoogleToMsolDetail

Import CSV of Google Data into MsolUser


## Import-GoogleToResourceMailbox

Import CSV of Google Resource Mailboxes into Exchange Online as Resource Mailboxes


## Import-GoogleToSharedMailbox

Import CSV of Google Shared Mailboxes into Exchange Online as Shared Mailboxes


## Import-MsolProperty

Import MsolUser properties to Office 365 cloud-only accounts


## Import-PrimarySmtpasUpn




## Import-QADAlias

Finds AD user by searching ProxyAddresses of all AD Users in a domain - by using the PrimarySmtpAddress column of CSV
Imports Non-Primary ProxyAddresses (aliases) into an ADUser.


## Import-QADData

Imports (typically from a CSV) at minimum: DisplayName, UserPrincipalName and Mail attributes
It transforms the mail attribute into MailNickName, TargetAddress & ProxyAddresses attributes
It uses the Replace method for those three attributes, thus clearing the attribute and adding the one we want
This is dependant on the ActiveDirectory module


## New-ActiveDirectoryGroup

New Active Directory Group


## New-ActiveDirectoryUser

Create New Active Directory Users - Mainly for Shared and Resource Mailbox as object is disabled with random password


## New-EXOMailTransportRuleReport

View the details of messages that matched the conditions defined by any transport rules


## New-GroupManagementRoleWithECPAccess

It is designed to allow users to modify Exchange Distribution Groups that they already own via ECP
However, it limits their ability to create or remove Distribution Groups.
This is commonly used for mailboxes of DG owners migrated to Office 365


## New-HybridMailbox

Designed to create and manage users in Hybrid Office 365 environment.
On-Premises Exchange server is required.

The UserPrincipalName is created by copying the Primary SMTP Address (as created by the On-Premises Exchange Email Address Policies).
Alternatively use the -PrimarySMTPAddress parameter)
Can be run from any machine on the domain that has the module for ActiveDirectory installed.
The script will prompt once for the names of a Domain Controller, Exchange Server and the Azure AD Connect server.
The script will also prompt once for DisplayName & SamAccountName Format.
All of these prompts will only occur once per machine (per user).
Should you wish to change any/all options just run: Select-Options
The script stores & encrypts both your Exchange/AD & Office 365 password.
You should be prompted only once unless your password changes or a time-out occurs.

By default, the script creates an new Active Directory User & corresponding mailbox in Exchange Online.

You will be prompted for the OU where to place the user(s).
By default, you will be presented to choose from all OUs with the word "user" or "resource" in it.
To add additional search criteria, use:  -OUSearch "SomeOtherSearchCriteria"
You will also be prompted for which license options the user should receive.

If using the "UserToCopy" parameter, the new user will receive all the attributes (Enabled, StreetAddress, City, State, PostalCode & Group Memberships).
The script enables the option: User must change password at next logon.  Unless this switch is used: -DontForceUserToChangePasswordAtLogon

Whichever Retention Policy is set to "Default", will be the retention policy that
the Exchange Online Mailbox will receive - unless this switch is used:  -SpecifyRetentionPolicy
If -SpecifyRetentionPolicy is used, the script will prompt for which Retention Policy to assign the user(s).

** The script will also take CSV input. The minimum parameters are FirstName & LastName **
**                           See examples below                                          **


## New-MailboxSync

Sync Mailboxes from On-Premises Exchange to Exchange Online
Either CSV or Excel file from SharePoint can be used


## Remove-365Domain




## RemoveBrokenOrClosedPSSession




## Remove-MailboxSync

Remove Mailbox Sync


## Remove-OfficeLicense

Remove Product Key and License from an existing Office Install
Often used when moving from one Office 365 tenant to another.


## Remove-OktaGroup

Searches for specific Okta Users and deletes them!


## Remove-OktaUser

Searches for specific Okta Users and deletes them!


## Remove-OktaUserfromApp

Searches for specific Okta Users and removes (and deprovisions them) from a specific app


## Remove-PublicFolderSMTP




## Rename-SamAccount




## Rename-User




## Resume-MailboxSync

Resume Mailbox Sync


## Select-ADConnectServer




## Select-DisplayNameFormat




## Select-DomainController




## Select-ExchangeServer




## Select-Options




## Select-SamAccountNameOptions




## Select-TargetAddressSuffix




## Set-CloudLicense

This tool allows you license one, many or all of your Office 365 users with several methods. IMPORTANT THIS SCRIPT WILL ADD/REMOVE DEPENDENCIES FOR ANY OPTION SELECTED For example, if Skype for Business Cloud PBX is selected to be assigned to a user(s) then Skype for Business Online will also be assigned (if the person running the script doesn't select it.)  This is because Skype for Business Cloud PBX has a dependency on Skype for Business Online thus it will also be assigned.
 Conversely, when removing options. For example, if the person running the script selects to remove the option Skype for Business Online , then the option Skype for Business Cloud PBX would also be unassigned from the user(s).  Again, Skype for Business Cloud PBX depends on Skype for Business Online to be assigned thus the dependency would be automatically unassigned.
 While this is a feature and not a bug, it is important that the person running this script is aware. THIS SCRIPT WILL ADD/REMOVE DEPENDENCIES FOR ANY OPTION SELECTED The person running the script uses the switch(es) provided at runtime to select an action(s). The script will then present a GUI (Out-GridView) from which the person running the script will select. Depending on the switch(es), the GUI will contain Skus and/or Options - all specific to their Office 365 tenant.
 For example, if the person running the script selects the switch "Add Options", they will be presented with each Sku and its corresponding options. The person running the script can then control + click to select multiple options.
 If the person running the script wanted to apply a Sku that the end-user did not already have BUT not apply all options in that Sku, use the "Add Options" switch. "Add Sku" will add all options in that Sku.
 Template Mode wipes out any other options - other than the options the person running the script chooses. This is specific only to the Skus that contain the options chosen in Template Mode. For example, if the end-user(s) has 3 Skus: E1, E3 and E5... and the person running the script selects only the option "Skype" in the E3 Sku, E1 and E5 will remain unchanged. However, the end-user(s) that this script runs against will have only one option under the E3 Sku - Skype.
 Multiple switches can be used simultaneously.
For example, the person running the script could choose to remove a Sku, add a different Sku, then add or remove options. However, again, if only selected options are desired in a Sku that is to be newly assigned, use the "Add Options" switch (instead of "Add Sku" and "Remove Option"). When using "Add Sku", the speed of Office 365's provisioning of the Sku is not fast enough to allow the removal of options during the same command.
It is more simple to use "Add Options" anyway.
No matter which switch is used, the person running the script will be presented with a GUI(s) for any selections that need to be made.
 Further explanations of the switches are demonstrated in the EXAMPLES below.


## Start-PostMailboxSyncTask




## Suspend-MailboxSync

Suspend Mailbox Sync


## Switch-AddressDomain

Modifies PrimarySMTPAddress via Active Directory by changing domain from old to new.  Makes the primary address a secondary (additional) smtp address.
Optionally, changes the UPN, changes the mail attributes or clears all proxy addresses first.


## Switch-PrimarySmtp

Converts an email address to the primary smtp address when it matches a specified search criteria. Run from Exchange Management Shell.
Based on a list of users specified at runtime, this script is designed to find one email per mailbox that matches a search
criteria (like contoso.com) and convert it to the primary smtp address.
The existing primary smtp address will automatically become a secondary stmp address.


## Sync-AD




## Sync-ADConnect




## Test-Preflight




## Trace-ExchangeMessage

Searches all Hub Transport and Mailbox Servers for messages. Once found, you can select one or more messages via Out-GridView to search by those MessageID's.


## Trace-Message

Search message trace logs in Exchange Online by hour or partial hour start and end times
If desired, one or more messages can be selected from the results for more detail
Just click OK once you have selected the message(s)

Many thanks to Matt Marchese for the initial framework of this function


## Update-ExchangeGroupMembership

This will remove all members from all groups (that are fed via the pipeline).
Then add an updated list of members from the same list.


## Update-GoogleCalendarACL

Report on Calendar ACLs from a list of Calendar IDs.


## Update-GroupManagementRole

It is designed to allow users to modify Exchange Distribution Groups that they already own
However, it limits their ability to create or remove Distribution Groups.


## UpdateImplicitRemotingHandler




## Update-RoleEntry

(If no Action is passed we assume remove)
$roleentry should be in the form Role\Roleentry e.g. MyRole\New-DistributionGroup


## Write-HostLog




## Write-HostProgress




## Write-Log





