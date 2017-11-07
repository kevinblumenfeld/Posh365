---
external help file: PSLicense-help.xml
online version: 
schema: 2.0.0
---

# Set-LACloudLicense

## SYNOPSIS
Use this tool to license Office 365 with ease.

## SYNTAX

```
Set-LACloudLicense [-RemoveSkus] [-AddSkus] [-RemoveOptions] [-AddOptions] [-MoveOptionsFromOneSkuToAnother]
 [-MoveOptionsSourceOptionsToIgnore] [-MoveOptionsDestOptionsToAdd] [-TemplateMode] [-ReportUserLicenses]
 [-ReportUserLicensesEnabled] [-ReportUserLicensesDisabled] [-DisplayTenantsSkusAndOptions]
 [-DisplayTenantsSkusAndOptionsFriendlyNames] [-DisplayTenantsSkusAndOptionsLookup] [-TheUser] <String[]>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This tool allows you license one, many or all of your Office 365 users with several methods.

**IMPORTANT**

**THIS SCRIPT WILL ADD/REMOVE DEPENDENCIES FOR ANY OPTION SELECTED**

For example, if _Skype for Business Cloud PBX_ is selected to be assigned to a user(s) then _Skype for Business Online_ will also be assigned (if the person running the script doesn't select it.)  This is because _Skype for Business Cloud PBX_ has a dependency on _Skype for Business Online_ thus it will also be assigned.

Conversely, when removing options.
For example, if the person running the script selects to remove the option _Skype for Business Online_, then the option _Skype for Business Cloud PBX_ would also be unassigned from the user(s).  Again, _Skype for Business Cloud PBX_ depends on _Skype for Business Online_ to be assigned thus the dependency would be automatically unassigned.

While this is a feature and not a bug, it is important that the person running this script is aware.

**When using the MoveOptionsFromOneSkuToAnother switch the Source Sku will be unassigned from the user(s)**
If the options successfully migrate to the Destination Sku, the Source Sku will be unassigned from the user(s) - as the goal is to move/migrate the options to the Destination Sku.  For safety sake, the Source Sku will not be removed unless the **matching** options are moved.  Please see EXAMPLE 1 & 2
**For example, if a user(s) already has the Destination Sku with Yammer assigned and the Source Sku does not have Yammer assigned - in the end, the Destination Sku will not have Yammer. Destination Sku options are not retained**
If needed, have a look at the 2 switches that compliment MoveOptionsFromOneSkuToAnother: _MoveOptionsSourceOptionsToIgnore_ and _MoveOptionsDestOptionsToAdd_.  Please see EXAMPLE 1 & 2 

The person running the script uses the switch(es) provided at runtime to select an action(s).
The script will then present a GUI (Out-GridView) from which the person running the script will select.
Depending on the switch(es), the GUI will contain Skus and/or Options - all specific to their Office 365 tenant.

For example, if the person running the script selects the switch "Add Options", they will be presented with each Sku and its corresponding options.
The person running the script can then control + click to select multiple options.

If the person running the script wanted to apply a Sku that the end-user did not already have BUT not apply all options in that Sku, use the "Add Options" switch.
"Add Sku" will add all options in that Sku. 

Template Mode wipes out any other options - other than the options the person running the script chooses.
This is specific only to the Skus that contain the options chosen in Template Mode.
For example, if the end-user(s) has 3 Skus: E1, E3 and E5...
and the person running the script selects only the option "Skype" in the E3 Sku, E1 and E5 will remain unchanged.
However, the end-user(s) that this script runs against will have only one option under the E3 Sku - Skype.

Multiple switches can be used simultaneously.  
For example, the person running the script could choose to remove a Sku, add a different Sku, then add or remove options.
However, again, if only selected options are desired in a Sku that is to be newly assigned, use the "Add Options" switch (instead of "Add Sku" and "Remove Option").
When using "Add Sku", the speed of Office 365's provisioning of the Sku is not fast enough to allow the removal of options during the same command.  
It is more simple to use "Add Options" anyway.   

No matter which switch is used, the person running the script will be presented with a GUI(s) for any selections that need to be made.

Further explanations of the switches are demonstrated in the EXAMPLES below.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LAConnected -Tenant Contoso -MSOnline -AzureADver2

Get-MsolUser -SearchString cloud01 | Select -ExpandProperty Userprincipalname | Set-LACloudLicense -MoveOptionsFromOneSkuToAnother
```

Moves **ENABLED** options (Service Plans) from one Sku to another Sku.  
the person running the script will be presented with 2 GUIs to select the Source Sku and the Destination Sku.
All Source Sku options will be moved to their corresponding, same-named option in the Destination Sku.

The script will strip off MOST version numbers for a best-effort match from unlike SKUs (for ex, E3 to E5)
This is the list of what is stripped off currently, (more can be added to Get-UniqueString.ps1)

_E3 _E5 _P1 _P2 _P3 _1  _2    2   _GOV    _MIDMARKET  _STUDENT    _FACULTY    _A  _O365

To have a look at the Options use the following command - this will display the option names mentioned above (and corresponding "friendly name")
Get-AzureADUser -SearchString foo | Set-LACloudLicense -DisplayTenantsSkusAndOptionsLookup

### -------------------------- EXAMPLE 2 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-Content .\upns.txt | Set-LACloudLicense -MoveOptionsFromOneSkuToAnother -MoveOptionsSourceOptionsToIgnore -MoveOptionsDestOptionsToAdd
```

Same as in EXAMPLE 1 but also these "overrides" are available...
The person running the script can choose which options in the Source Sku to ignore for the Move of Options.
And/Or, the person running the script can choose which options should be added to the destination SKU regardless of the Move of Options.

### -------------------------- EXAMPLE 3 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-Content .\upns.txt | Set-LACloudLicense -MoveOptionsFromOneSkuToAnother -MoveOptionsSourceOptionsToIgnore -MoveOptionsDestOptionsToAdd 

The text file would look something like this:

user01@contoso.com
user02@contoso.com
```

Demonstrates the use of a CSV, who would receive the changes made by the script.  Ensure there is a header named, UserPrincipalName.

### -------------------------- EXAMPLE 4 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -ObjectID "foo@contoso.com" | Select -ExpandProperty Userprincipalname | Set-LACloudLicense -AddSku
```

Adds a Sku or multiple Skus with all available options.
If the end-user already has the Sku, all options will be added to that Sku, if not already.

### -------------------------- EXAMPLE 5 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString cloud01 | Select -ExpandProperty Userprincipalname | Set-LACloudLicense -AddOptions
```

Adds specific options in addition to options that are already in place for each end user.
If the end-user has yet to have the Sku assigned, it will be assigned with the options enabled - that were specified by the person running the script.
The options are chosen via a GUI (Out-GridView). Each options is listed next to its corresponding SKU to eliminate any possible confusion.

### -------------------------- EXAMPLE 6 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -Department 'Human Resources'| Select -ExpandProperty Userprincipalname | Set-LACloudLicense -RemoveSku
```

Removes a Sku or Skus.
The Sku(s) are chosen via a GUI (Out-GridView)

### -------------------------- EXAMPLE 7 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-Content .\upns.txt | Set-LACloudLicense -RemoveOptions
```

Removes specific options from a Sku or multiple Skus.
If the end-user does not have the Sku, no action will be taken
Options are presented in pairs, with their respective SKU - to avoid any possible confusion with "which option is associated with which Sku".
The Options(s) are chosen via a GUI (Out-GridView)

### -------------------------- EXAMPLE 8 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -Filter "JobTitle eq 'CEO'"   | Select -ExpandProperty Userprincipalname | Set-LACloudLicense -ReportUserLicenses
Get-AzureADUser -SearchString "John Smith"    | Select -ExpandProperty Userprincipalname | Set-LACloudLicense -ReportUserLicensesEnabled
Get-AzureADUser -Department "Human Resources" | Select -ExpandProperty Userprincipalname | Set-LACloudLicense -ReportUserLicensesDisabled
```

The 3 commands display the current options licensed to an end-user(s) - 3 different ways respectively.
1. All the end-user(s) Options (organized by Sku)
2. All the end-user(s) Enabled licenses only (organized by Sku)
3. All the end-user(s) Disabled licenses only (organized by Sku)

### -------------------------- EXAMPLE 9 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-AzureADUser -SearchString foo | Select -ExpandProperty Userprincipalname | Set-LACloudLicense -DisplayTenantsSkusAndOptionsLookup
```

This will display the available Office 365 tenant's available Skus and corresponding Options.
Also, this displays the the total amount of licenses and the total amount that are unassigned (remaining).

### -------------------------- EXAMPLE 10 --------------------------
```
Get-LAConnected -Tenant Contoso -AzureADver2

Get-Content .\upns.txt | Set-LACloudLicense -TemplateMode
```

This is meant to level-set the end-users with the same options.

Here is an example of a scenario.  The end-users all have 3 Skus E3, E5 & EMS.  The command listed in this example is executed and The person running the script makes the following selections in the presented GUI: 
1. 4 options are chosen for Sku E3 
2. 7 options are chosen for Sku E5
3. Zero options are chosen for Sku EMS

For each End-User in the upns.csv, the result would be the following:
1. Sku E3: They will have assigned exactly the 4 options** - all the other Sku's options will be disabled
2. Sku E5: They will have assigned exactly the 7 options** - all the other Sku's options will be disabled
3. Sku EMS: Will remain unchanged, regardless of what the end-user had previously.
* ** in addition to any mandatory options

## PARAMETERS

### -AddOptions
{{AddOptions}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddSkus
{{AddSkus}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayTenantsSkusAndOptions
{{DisplayTenantsSkusAndOptions}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayTenantsSkusAndOptionsFriendlyNames
{{DisplayTenantsSkusAndOptionsFriendlyNames}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayTenantsSkusAndOptionsLookup
{{DisplayTenantsSkusAndOptionsLookup}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveOptionsDestOptionsToAdd
{{MoveOptionsDestOptionsToAdd}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveOptionsFromOneSkuToAnother
{{MoveOptionsFromOneSkuToAnother}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MoveOptionsSourceOptionsToIgnore
{{MoveOptionsSourceOptionsToIgnore}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveOptions
{{RemoveOptions}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveSkus
{{RemoveSkus}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportUserLicenses
{{ReportUserLicenses}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportUserLicensesDisabled
{{ReportUserLicensesDisabled}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportUserLicensesEnabled
{{ReportUserLicensesEnabled}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateMode
{{TemplateMode}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TheUser
{{TheUser}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

