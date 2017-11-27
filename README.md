# Posh365
Connect.  Provision.  Maintain.  
Posh365 is a Toolbox for Office 365 Environments


## New-UserToCloud

**-New**

Creates a new Active Directory user in an OU of your choosing.  The user is given an Office 365 mailbox and licensed by you.  Once the command is run you will be presented with grids to select the OU and the license for the user.  

    New-UserToCloud -New -FirstName John -LastName Smith -StreetAddress "100 Industry Ln" -City "New York" -State "NY" -Zip "30002" -OfficePhone "(404)555-1212" -Description "Lexington Warehouse" -Department "Warehouse" -Title "Forklift Operator"



> **Note:**
>
> - The **only mandatory parameters** are **Firstname** and **Lastname**
> - After entering the command you will be prompted to enter a new password for the user

**-UserToCopy**

Creates a new Active Directory user in an OU of your choosing, while copying these attributes of another AD user: *StreetAddress, City, State & PostalCode*.  The user is given an Office 365 mailbox and licensed by you.  Once the command is run you will be presented with grids to select the OU and the license for the user.  

    New-UserToCloud -UserToCopy FJones -FirstName John -LastName Smith

**-Shared**

Creates a disabled Active Directory user in an OU of your choosing.  A shared mailbox is created and is associated with the AD User.  Once the command is run you will be presented with grids to select the OU and the license for the user.  After a few minutes the license will be removed as Shared Mailboxes do not require a license.

     New-UserToCloud -Shared -SharedMailboxEmailAlias "Sales" -DisplayName "Sales Department" -Description "Shared Mailbox for Sales Department"
     

## Connect-Cloud

Allows for easy connecting to Office 365 and Azure services while saving and encrypting your passwords locally.  
This prevents having to constantly type in credentials each session.  
  
Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter. Additionally, if more than one username will be used against a single tenant, use the -User parameter (for the second username and so on).  
Use anything unique to that username so the credential can be uniquely saved.  -User parameter is no mandatory.

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
