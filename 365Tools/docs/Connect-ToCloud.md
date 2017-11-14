---
external help file: 365Tools-help.xml
Module Name: 365Tools
online version: 
schema: 2.0.0
---

# Connect-ToCloud

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

```
Connect-ToCloud [-Tenant] <String> [[-User] <String>] [-ExchangeOnline] [-MSOnline] [-All365] [-Azure] [-Skype]
 [-SharePoint] [-Compliance] [-AzureADver2] [-MFA] [-DeleteCreds] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Connects to Office 365 services and/or Azure.

Connects to some or all of the Office 365/Azure services based on switches provided at runtime.

Office 365 tenant name, for example, either contoso or contoso.onmicrosoft.com must be provided with -Tenant parameter.
Additionally, if more than one username will be used against a single tenant, use the -User parameter (for the second username and on).  Use anything unique to that username so the credential can be properly saved.  Both the -Tenant and -User parameters are positional so it's not necessary to type -Tenant or -User.  The -Tenant parameter is mandatory while the -User parameter is optional.

For example, _Connect-ToCloud Contoso -Exchange_ demonstrates how it is not necessary to use the -User parameter and how the -Tenant parameter is positional.  However, say I want to connect to the Contoso tenant as _frank@contoso.com_  I could use _Connect-ToCloud Contoso Frank -Exchange_

When just connecting to Azure, it is still required to provide a Tenant, anything that uniquely identifies it.

There is a switch to use Multi-Factor Authentication.  For Exchange Online MFA, you are required to download and use the Exchange Online Remote PowerShell Module.
To download the Exchange Online Remote PowerShell Module for multi-factor authentication, in the EAC (https://outlook.office365.com/ecp/), go to Hybrid > Setup and click the appropriate Configure button.  When using Multi-Factor Authentication the saving of credentials is not available currently - thus each service will prompt independently for credentials.  Also the Security and Compliance Center does not currently support multi-factor authentication.

Locally saves and encrypts to a file the username and password.
The encrypted file...can only be used on the computer and within the user's profile from which it was created, is the same .txt file for all the Office 365 services and is a separate .json file for Azure.  If a username or password becomes corrupt or is entered incorrectly, it can be deleted using -DeleteCreds.  For example, _Connect-ToCloud Contoso -DeleteCreds_

If Azure switch is used **for first time**:

1.  User will login as normal when prompted by Azure
2.  User will be prompted to select which Azure Subscription
3.  Select the subscription and click "OK"

If Azure switch is used after first time:

1.  User will be prompted to pick username used previously
2.  If a new username is to be used (e.g. username not found when prompted), click **Cancel** to be prompted to login.
3.  User will be prompted to select which Azure Subscription
4.  Select the subscription and click "OK"

Directories used/created during the execution of this script 

1.  $env:USERPROFILE\ps\
2.  $env:USERPROFILE\ps\creds\

All saved credentials are saved in $env:USERPROFILE\ps\creds\
Transcript is started and kept in $env:USERPROFILE\ps\<tenantspecified\>

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Connect-ToCloud -Tenant Contoso -ExchangeOnline -MSOnline
```

Connects to MS Online Service (MSOL) and Exchange Online

The tenant must be specified, for example either contoso or contoso.onmicrosoft.com

### -------------------------- EXAMPLE 2 --------------------------
```
Connect-ToCloud Contoso -Skype -Azure -ExchangeOnline -MSOnline
```

Connects to Azure, MS Online Service (MSOL), Exchange Online & Skype

This is to illustrate that any number of individual services can be used to connect. Also that the -Tenant parameter is positional

### -------------------------- EXAMPLE 3 --------------------------
```
Connect-ToCloud -Tenant Contoso -SharePoint
```

Connects to SharePoint Online

### -------------------------- EXAMPLE 4 --------------------------
```
Connect-ToCloud -Tenant Contoso -DeleteCreds
```

The switch, DeleteCreds can be used if invalid credentials were inadvertently entered.
Typically, the symptom would be a user would be prompted each time for credentials, as the saved credential is invalid.
Use this switch with the mandatory Tenant parameter to delete the appropriate credentials.
Credentials will then be saved on the following login.

### -------------------------- EXAMPLE 5 --------------------------
```
Connect-ToCloud -Tenant Contoso -Compliance
```

Connects to Compliance & Security Center

### -------------------------- EXAMPLE 6 --------------------------
```
Connect-ToCloud -Tenant Contoso -All365
```

Connects to MS Online Service (MSOL), Exchange Online, Skype, SharePoint & Compliance

### -------------------------- EXAMPLE 7 --------------------------
```
Connect-ToCloud -Tenant Contoso -All365 -Azure
```

Connects to Azure, MS Online Service (MSOL), Exchange Online, Skype, SharePoint & Compliance

### -------------------------- EXAMPLE 8 --------------------------
```
Connect-ToCloud -Tenant Contoso -Skype -ExchangeOnline -MSOnline
```

Connects to MS Online Service (MSOL) and Exchange Online and Skype Online

## PARAMETERS

### -All365
{{Fill All365 Description}}

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

### -Azure
{{Fill Azure Description}}

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

### -AzureADver2
{{Fill AzureADver2 Description}}

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

### -Compliance
{{Fill Compliance Description}}

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

### -DeleteCreds
{{Fill DeleteCreds Description}}

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

### -ExchangeOnline
{{Fill ExchangeOnline Description}}

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

### -MFA
{{Fill MFA Description}}

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

### -MSOnline
{{Fill MSOnline Description}}

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

### -SharePoint
{{Fill SharePoint Description}}

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

### -Skype
{{Fill Skype Description}}

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

### -Tenant
{{Fill Tenant Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -User
{{Fill User Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: False
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

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

