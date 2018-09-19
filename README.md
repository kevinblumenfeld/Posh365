# Posh365

Connect.  Provision.  Maintain.  
Posh365 is a Toolbox for Office 365 and On-Premises Environments
 

## Change Log   
   
0.8.6.9 Various improvements and a couple new functions like Compare-Csv and Compare-List   
0.8.6.8 Now allows for decimal input for StartSearchHoursAgo and EndSearchHoursAgo for New-EXOMessageTrace     
0.8.6.7 Fixed bug in New-EXOMessageTrace where using -subject parameter would cause script to fail.  Also now uses -StartSearchHoursAgo and EndSearchHoursAgo instead of minutes.   
0.8.6.6 in Connect-Cloud, added verbiage to give user alternate method to download MFA PS module if auto-install fails   
0.8.6.5 Added support to automatically download MFA module needed for EXO and Security & Compliance in Connect-Cloud   
0.8.6.4 Added support to connect to Exchange Online and Security and Compliance with MFA in the same console   
0.8.6.3 Added support to connect to Exchange Online with MFA without having to download MFA console each time   
0.8.6.2 Added functionality and killed bugs in Get-DiscoveryInfo, Export-CsvData & Import-CsvData  
0.8.6.1 Corrected issue with Get-DiscoveryInfo   
0.8.6.0 Get-DiscoveryInfo for on-premises discovery. First version  
0.8.5.9 Formatted hashtables properly in Permissions functions  
0.8.5.8 Added support for loading MFA module if already installed.  Corrected Get-ActiveDirectoryGroup  
0.8.5.7 Correct bug in Export-CsvData  
0.8.5.6 Added function Clear-Attribute to clear pesky AD Attribute values  
0.8.5.5 Added replace and attribute selection for Import-CsvData  
0.8.5.4 Added ability to change domains when importing addresses with Import-CsvData  
0.8.5.3 Squashed bug when Add or Remove ProxyAddresses from AD with Import-CsvData  
0.8.5.2 Ability to Add or Remove ProxyAddresses from AD with Import-CsvData  
0.8.5.1 More output with Export-CsvData  
0.8.5.0 Better logging for Import-CsvData  
0.8.4.9 Import-CsvData cleaned  
0.8.4.8 Removed Add-SecondarySIP function  
0.8.4.7 Export-CsvDataForGroups added and corrections to Get-ActiveDirecoryGroup  
0.8.4.6 Corrected a bug in Get-ActiveDirectoryGroup  
0.8.4.5 Added Get-ActiveDirectoryGroup  
0.8.4.4 Corrected Get-ActiveDirectoryObject output incorrectly was using Get-ADUser instead of Get-ADObject  
0.8.4.3 Added new function Get-ActiveDirectoryObject and added column to Export-CsvData  
0.8.4.2 Now Import-ADProxyAddress is split between Import-ADUserProxyAddress and Import-ADGroupProxyAddress  
0.8.4.1 Added option to pick from 3 different columns from CSV when using Export-CSVData  
0.8.4.0 Added additional CBH for Import-ADProxyAddress and Export-CSVData  
0.8.3.9 Get-ActiveDirectoryUserFiltered is working properly now  
0.8.3.8 Removed old sip in Switch-AddressDomain  
0.8.3.7 Updated comment based help for Switch-AddressDomain  
0.8.3.6 Corrected bug in Switch-AddressDomain that would cause new address become the new secondary, instead current primary smtp should become new additional smtp: address  
0.8.3.5 Corrected bug in Switch-AddressDomain that would cause odd logging of errors  
0.8.3.4 Created Switch-AddressDomain and removed same functionality from Import-ADProxyAddress   
0.8.3.3 Updated Import-ADProxyAddress with new functionality  
0.8.3.1 New Comment Based Help  
0.8.3.0 Removed the switch -SelectMessageForDetails & made the action default in New-EXOMessageTrace  
0.8.2.9 Changed Sort to descending for migration and move request stats detailed report  
0.8.2.8 Added Get-EXOMigrationStatistics & Get-EXOMoveRequestStatistics  
0.8.2.7 Added New-EXOMailTransportRuleReport  
0.8.2.6 Completely revised New-EXOMessageTrace to allow for searches by minute for both start and end times. All output is to Out-GridView. Message(s) can then be selected.  Click OK and MessageTraceDetails will appear an in Out-Grid, one for each message selected  
0.8.2.5 Working version of Import-ActiveDirectoryGroupMember   
0.8.2.4 Corrected issue where rename of DisplayName (to account for CNs longer than 15 characters) would fail in New-ActiveDirectoryGroup   
0.8.2.3 New-ActiveDirectoryGroup can now replace domain (domain/newDomain params) when importing email addresses   
0.8.2.2 New-ActiveDirectoryUser now renames CN attribute to DisplayName   
0.8.2.1 Changed method to iterate samaccountname in New-ActiveDirectoryUser   
0.8.2.0 Corrected iteration when duplicate sAMAccountname is found in New-ActiveDirectoryUser   
0.8.1.9 sAMAccountname truncate to 15 characters in New-ActiveDirectoryUser   
0.8.1.8 Removed unneeded parameters from New-ActiveDirectoryUser   
0.8.1.7 Added New-ActiveDirectoryUser for adding SharedMailbox and Resource Mailboxes in a tenant to tenant migration etc.  
0.8.1.6 Added domain replacement functionality to Import-ADProxyAddresses -Domain -NewDomain  
0.8.1.5 Added functions Import-ActiveDirectoryGroup & Import-ActiveDirectoryGroupMember  
0.8.1.4 Added functions Test-PreFlight and Test-PreFlightOnPrem  
0.8.1.3 Corrected bug in Import-ADProxyAddress and added Verbose output  
0.8.1.2 Added error handling for Import-ADProxyAddress  
0.8.1.1 Added Import-ADProxyAddress.  Prior to adding any action will output file with what will be added to each ADUser  
0.8.1 Property order change in Get-ActiveDirectoryUser  
0.8.0 Corrected duplicate properties in Get-ActiveDirectoryUser  
0.7.9 Rearranged order of properties for Get-ActiveDirectoryUser  
0.7.8 Corrected module PSD1 file to export function names correctly  
0.7.7 Added several new function.  As always use Get-Command -Module Posh365 for a list of commands and use Get-Help on each command.  
0.7.6 Removed unneeded attributes from Import-EXOGroup's parameter splat  
0.7.5 Removed Duplicate -ResultSize Unlimited from Get-EXOMailboxPerms  
0.7.4 Corrected cmdlet name in Import-EXOMailboxPermissions.  Performance enhancements in Get-365Info  
0.7.3 Added 3 -ResultSize Unlimited to correct issue where over 1000 recipients in 2 functions  
0.7.2 Fix multi-domain forest issue with mailbox and dg permissions if Global Catalog was not already being used to authenticate session.  Added more -Verbose output for permissions functions.  SendOnBehalf permissions on Distribution Groups is reported on from Distribution Groups script instead of permissions scripts  
0.7.1 Corrected DG SendAs report.  SendOnBehalf to follow. In the meantime, GrantSendOnBehalfTo is reported at the Group level  
0.7.0 Added on-prem Dist Group Permissions Reporting function  
0.6.9 Added EXO "apply" permissions to mailboxes and groups function  
0.6.8 Added Get-DGPerms and added to Get-365Info comprehensive report  
0.6.6 Fixed typo  
0.6.5 Updated example  
0.6.4 Add Get-EXOMailContact function  
0.6.3 Added controller script (Get-365Info) to discover EXO/365 Tenant with the means to restrict by domain name.  Added report for archive mailboxes, licensing, Retention Policies.  Improved help with detailed examples.  
0.6.2 Fixed a bug that prevented Get-EXOGroup from correct output when requesting all groups  
0.6.1 Added several Get-EXO... functions to gather msolusers, msolgroups, mailboxes, resource mailboxes(calendar processing) with simple and/or detailed reports.  Reporting can can be limited by email domains etc.  
0.6.0 Corrected issue where Get-EXOGroups would not report members when reporting on all groups  
0.5.9 Added Get-EXOGroups, reports on all Exchange Online mail-enabled dist & sec groups, all email addresses and other multivalued attributes (semicolon separated).  Also all members.  Planning to add a -Recurse switch soon.  Also, Get-EXOMailboxPerms collects all Exchange Online permissions and can accept txt input instead of entire tenant.  Moving txt to pipeline input in next release  
0.5.8 Resolved issue where AzureAD and MSOnline modules would not auto install  
0.5.7 Added VanHybrid's amazing Get-VirtualDirectoryInfo (ver 1.8) function  
0.5.6 Added Get-EdiscoveryCase function to obtain Security and Compliance case reports  
0.5.5 Add 2 New-EXOMessageTrace functions  
0.5.4 New-HybridMailbox will give user SIP proxy address if -primarySMTPAddress parameter is used (No EAP applied) 
0.5.3 made correction to New-HybridMailbox. Used Try/Catch to import AD Module and throw if not available on all needed functions  
0.5.2 Check for ActiveDirectory module for New-HybridMailbox uses Try/Catch instead of #Requires  
0.5.1 Get-MailboxPerms, Get-EXOMailboxPerms and Get-EXOMailboxRecursePerms released  
