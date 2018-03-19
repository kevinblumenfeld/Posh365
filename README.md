# Posh365

Connect.  Provision.  Maintain.  
Posh365 is a Toolbox for Office 365 Environments


 Designed to manage users in Hybrid Office 365 environment.
   On-Premises Exchange server is required.  

## New-HybridMailbox   
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

Connects to Office 365 services and/or Azure.  

Connects to some or all of the Office 365/Azure services based on switches provided at runtime.  

Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter.  
The -Tenant parameter is mandatory.

There is a switch to use Multi-Factor Authentication.  
For Exchange Online MFA, you are required to download and use the Exchange Online Remote PowerShell Module.  
To download the Exchange Online Remote PowerShell Module for multi-factor authentication, in the EAC (https://outlook.office365.com/ecp/), go to Hybrid \> Setup and click the appropriate Configure button. 

When using Multi-Factor Authentication the saving of credentials is not available currently - thus each service will prompt independently for credentials.  Also, the Security and Compliance Center does not currently support multi-factor authentication.  

Locally saves and encrypts to a file the username and password.  
The encrypted file...can only be used on the computer and within the user's profile from which it was created, is the same .txt file for all the Office 365 services and is a separate .json file for Azure.  
If a username or password becomes corrupt or is entered incorrectly, it can be deleted using -DeleteCreds.  
For example, Connect-Cloud Contoso -DeleteCreds  

## Set-CloudLicense

The person running the script uses the switch(es) provided at runtime to select an action(s). The script will then present a GUI (Out-GridView) from which the person running the script will select. Depending on the switch(es), the GUI will contain Skus and/or Options - all specific to their Office 365 tenant.

For example, if the person running the script selects the switch "Add Options", they will be presented with each Sku and its corresponding options. The person running the script can then control + click to select multiple options.

If the person running the script wanted to apply a Sku that the end-user did not already have BUT not apply all options in that Sku, use the "Add Options" switch. "Add Sku" will add all options in that Sku.

Template Mode wipes out any other options - other than the options the person running the script chooses. This is specific only to the Skus that contain the options chosen in Template Mode. For example, if the end-user(s) has 3 Skus: E1, E3 and E5... and the person running the script selects only the option "Skype" in the E3 Sku, E1 and E5 will remain unchanged. However, the end-user(s) that this script runs against will have only one option under the E3 Sku - Skype.

Multiple switches can be used simultaneously.
For example, the person running the script could choose to remove a Sku, add a different Sku, then add or remove options. However, again, if only selected options are desired in a Sku that is to be newly assigned, use the "Add Options" switch (instead of "Add Sku" and "Remove Option"). When using "Add Sku", the speed of Office 365's provisioning of the Sku is not fast enough to allow the removal of options during the same command.
It is more simple to use "Add Options" anyway.

No matter which switch is used, the person running the script will be presented with a GUI(s) for any selections that need to be made.  
 
