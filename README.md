# Connect-ToCloud
Allows for easy connecting to Office 365 and Azure services while saving and encrypting your passwords locally.  
This prevents having to constantly type in credentials each session.  
  
Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter. Additionally, if more than one username will be used against a single tenant, use the -User parameter (for the second username and on).  
Use anything unique to that username so the credential can be uniquely saved.

Detailed help with examples can be found here:
https://github.com/kevinblumenfeld/365Tools/blob/master/365Tools/docs/Connect-ToCloud.md
# Set-CloudLicense

The person running the script uses the switch(es) provided at runtime to select an action(s). The script will then present a GUI (Out-GridView) from which the person running the script will select. Depending on the switch(es), the GUI will contain Skus and/or Options - all specific to their Office 365 tenant.

For example, if the person running the script selects the switch "Add Options", they will be presented with each Sku and its corresponding options. The person running the script can then control + click to select multiple options.

If the person running the script wanted to apply a Sku that the end-user did not already have BUT not apply all options in that Sku, use the "Add Options" switch. "Add Sku" will add all options in that Sku.

Template Mode wipes out any other options - other than the options the person running the script chooses. This is specific only to the Skus that contain the options chosen in Template Mode. For example, if the end-user(s) has 3 Skus: E1, E3 and E5... and the person running the script selects only the option "Skype" in the E3 Sku, E1 and E5 will remain unchanged. However, the end-user(s) that this script runs against will have only one option under the E3 Sku - Skype.

Multiple switches can be used simultaneously.
For example, the person running the script could choose to remove a Sku, add a different Sku, then add or remove options. However, again, if only selected options are desired in a Sku that is to be newly assigned, use the "Add Options" switch (instead of "Add Sku" and "Remove Option"). When using "Add Sku", the speed of Office 365's provisioning of the Sku is not fast enough to allow the removal of options during the same command.
It is more simple to use "Add Options" anyway.

No matter which switch is used, the person running the script will be presented with a GUI(s) for any selections that need to be made.  

Detailed help with examples can be found here:
https://github.com/kevinblumenfeld/365Tools/blob/master/365Tools/docs/Set-CloudLicense.md  

# New-UserToCloud  
Creates new AD user and corresponding 365 mailbox with one command  
Shared mailboxes can be created in the same manner with (with -shared switch)  
Alternatively, can copy the properties of an existing AD User to a new AD User and creates its Office 365 Mailbox  
Syncs changes to Office 365 with Azure AD Connect (AADC)  
Grid of licenses are presented to user of script to select from and then applied to 365 User  

Detailed help with examples can be found here:  
https://github.com/kevinblumenfeld/365Tools/blob/master/365Tools/docs/New-UserToCloud.md  

**Several more functions are included and their help will be detailed here in the near future.**
