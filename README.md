# Posh365

Connect.  Provision.  Maintain.  
Posh365 is a Toolbox for Office 365 Environments


 Designed to manage users in Hybrid Office 365 environment.
   On-Premises Exchange server is required.  
   
   The UserPrincipalName is created by copying the Primary SMTP Address (as created by the On-Premises Exchange Email Address Policies or manually entering PrimarySMTP)
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
   **                           See example below                                          **
      
    .EXAMPLE
    Import-Csv C:\data\theTEST.csv | New-HybridMailbox

    Example of CSV (illustrated without commas):

    FirstName LastName
    John      Smith
    Sally     James
    Jeff      Williams
    Jamie     Yothers

    .EXAMPLE
    New-HybridMailbox -FirstName John -LastName Smith

    .EXAMPLE
    New-HybridMailbox -UserToCopy "FredJones@contoso.com" -FirstName Jonathan -LastName Smithson
   
    .EXAMPLE
    New-HybridMailbox -FirstName Jon -LastName Smith -OfficePhone "(404)555-1212" -MobilePhone "(404)333-5252" -DescriptiADdedon "Hired Feb 12, 2018"
    
    .EXAMPLE
    New-HybridMailbox -FirstName Jon -LastName Smith -StreetAddress "123 Main St" -City "New York" -State "NY" -Zip "10080" -Country "US"
       
    .EXAMPLE
    New-HybridMailbox -FirstName Jon -LastName Smith -Office "Manhattan" -Title "Vice President of Finance" -Department "Finance" -Company "Contoso, Inc."
   
     
## Connect-Cloud

Allows for easy connecting to Office 365 and Azure services while saving and encrypting your passwords locally.  
This prevents having to constantly type in credentials each session.  
  
Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter. Additionally, if more than one username will be used against a single tenant, use the -User parameter (for the second username and so on).  
Use anything unique to that username so the credential can be uniquely saved.  -User parameter is **not** mandatory.

## Set-CloudLicense

The person running the script uses the switch(es) provided at runtime to select an action(s). The script will then present a GUI (Out-GridView) from which the person running the script will select. Depending on the switch(es), the GUI will contain Skus and/or Options - all specific to their Office 365 tenant.

For example, if the person running the script selects the switch "Add Options", they will be presented with each Sku and its corresponding options. The person running the script can then control + click to select multiple options.

If the person running the script wanted to apply a Sku that the end-user did not already have BUT not apply all options in that Sku, use the "Add Options" switch. "Add Sku" will add all options in that Sku.

Template Mode wipes out any other options - other than the options the person running the script chooses. This is specific only to the Skus that contain the options chosen in Template Mode. For example, if the end-user(s) has 3 Skus: E1, E3 and E5... and the person running the script selects only the option "Skype" in the E3 Sku, E1 and E5 will remain unchanged. However, the end-user(s) that this script runs against will have only one option under the E3 Sku - Skype.

Multiple switches can be used simultaneously.
For example, the person running the script could choose to remove a Sku, add a different Sku, then add or remove options. However, again, if only selected options are desired in a Sku that is to be newly assigned, use the "Add Options" switch (instead of "Add Sku" and "Remove Option"). When using "Add Sku", the speed of Office 365's provisioning of the Sku is not fast enough to allow the removal of options during the same command.
It is more simple to use "Add Options" anyway.

No matter which switch is used, the person running the script will be presented with a GUI(s) for any selections that need to be made.  
 

 

# SYNOPSIS (under construction)  

1.	Connect-Exchange - on premise connections to on prem Exchange   
2.	Connect-Cloud – connects to all 365 services incl support for mfa also azure  
3.	ConvertTo-Shared – Converts a cloud user mailbox/ad attributes to a shared mailbox then removes licences  
4.	Set-CloudLicense – fairly sophisticated licensing function to license one, many or all mailbox in 365.  Can migrate licenses between skus also  
5.	Get-CloudLicense – Breakdown of a user’s license by SKU and respective options and if enabled or disabled for said user.  
6.	Rename-SamAccount – If a SamAccountName needs to be renamed of a mail-enabled user, this adjusts all the proper attributes  
7.	Rename-User – When a person’s name changes due to marriage etc. this properly adjusts attributes and unchecks and rechecks email address policy (auto apply) to force email address addition.  
8.	Sync-ADConnect – Forces a sync of AD Connect from any computer on the network  
9.	Sync-AD – Replicates AD from each domain controller in the forest.  
10.	New-UserToCloud – One command does this..  
a.	Creates an AD User either newly or by copying an existing users attributes (similar to “Copy” in ADUC – all group memberships and the like)
b.	User is prompted to select an OU from Out-GridView 
c.	Creates connected mailbox for said user in Office 365  
d.	User is prompted with Out-GridView with all SKUs & Options that is assigned to the user  
e.	Forces a Sync of AD Connect – if busy it waits till AD Connect will accept a sync command and does so  
f.	With -Shared switch the mailbox is created/converted to a shared mailbox and licenses are removed 
g.	The first time the user uses New-UserToCloud this script they are auto-prompted to select options with these commands:  
i.	Select-ADConnectServer - self explanatory  
ii.	Select-DisplayNameFormat – where they choose Firstname Lastname or Lastname, Firstname for displayname in ADUC (what you see looking at a user in ADUC without opening them)  
iii.	Select-DomainController – It is recommended to select the DC that AD Connect looks too.. AD Connect can be set to look in order and this is explained in HELP of New-UserToCloud  
iv.	Select-ExchangeServer – self explanatory  
v.	Select-TargetAddressSuffix – this is here just in case the companies accepted domains contains more than one targetaddress suffix for example, contoso.mail.onmicrosoft.com & fabrikam.mail.onmicrosoft.com  
vi.	All choices are saved to text files and can be called again by function name or by simply calling Select-Options, which will allow the user to run thru each of the above’s Out-Gridviews  
11.	Get-MfaStats – Will take pipeline input of upn(s) and reveal the last time the Managed Folder Assistant serviced their mailbox (or archive mailbox), count of what in mailbox was tagged/deleted what in dumpster was tagged/deleted – can also request MFA to process the mailbox.  This data is usually hard to interpret as it is in XML.. this renders nicely for export or screenviewing  
12.	Get-RetentionLinks – This gets all RetentionPolicies and their respective Retention Tags (linked) shows tag linked, age, action, type enabled and comment  


**Several more functions are included and their help will be detailed here in the near future.**
