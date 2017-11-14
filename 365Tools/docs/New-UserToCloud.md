---
external help file: 365Tools-help.xml
Module Name: 365Tools
online version: 
schema: 2.0.0
---

# New-UserToCloud

## SYNOPSIS
1) Copies the properties of an existing AD User to a new AD User
2) Enables the ADUser as a Remote Mailbox in Exchange/Office 365 (can select -noMail switch to assign no mailbox)
3) Syncs changes to Office 365 with Azure AD Connect (AADC)
4) Grid of licenses are presented to user of script to select from and then applied to 365 User


Must be run on PowerShell 5+ (run as administrator) with the following tools installed:
Windows 10/2016 comes pre-installed with PowerShell 5.1

  1) RSAT (Active Directory tools including AD Module for PowerShell)
  2) Exchange Management Tools - Ensure the version matches exactly the version of Exchange installed onprem. 
  3) Run Select-Options once, to choose an initial options
       this allows the scripts to lock in your specific options. 
  This should only need to be changed should any options need to be changed
       It is best to choose the domain controller with which AD Connect is connected.
       Need be, domain controllers can be hard coded (within AD Connect) to use a list of DCs (in order), so that the first in the list is typically the only DC used:
       This is the process:
          https://vanhybrid.com/2016/01/25/force-azure-ad-connect-to-connect-to-specific-domain-controllers-only/
  4) Be sure to enclose in "Double Quotes" anything with special characters, for example, spaces, commas, hyphens etc.  
  The examples below, illustrate this well.

## SYNTAX

### Copy
```
New-UserToCloud -UserToCopy <String> -FirstName <String> -LastName <String> [-OfficePhone <String>]
 [-MobilePhone <String>] [-Description <String>] [-SAMPrefix <String>] -Password <String> [-NoMail]
 [-OUSearch <String>] [<CommonParameters>]
```

### Shared
```
New-UserToCloud [-Shared] -SharedMailboxEmailAlias <String> -DisplayName <String> [-Description <String>]
 -Password <String> [-OUSearch <String>] [<CommonParameters>]
```

### New
```
New-UserToCloud [-New] -FirstName <String> -LastName <String> [-OfficePhone <String>] [-MobilePhone <String>]
 [-Description <String>] [-StreetAddress <String>] [-City <String>] [-State <String>] [-Zip <String>]
 [-SAMPrefix <String>] -Password <String> [-NoMail] [-OUSearch <String>] [<CommonParameters>]
```

### NoMail
```
New-UserToCloud -Password <String> [-OUSearch <String>] -EmailDomain <String> [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
When using the EmailDomain parameter, simply type -EmailDomain, then hit the space-bar, then tab through the available email domains.  The email domains are dynamically acquired from the environment where the script is run.
This is only available/needed when using the NoMail switch.
```

New-UserToCloud -UserToCopy SmithJ -NoMail -FirstName Naomi -LastName Queen -StorePhone "777-222-3333,234" -MobilePhone "404-234-5555" -Description "Naomi's Description" -Prefix NN -Password "Pass1255!!!$" -EmailDomain contoso.com

### -------------------------- EXAMPLE 2 --------------------------
```
Notice the -Shared switch (below).  Use this to create a shared mailbox.  An Exchange Online License is needed but is automatically removed after 6 minutes
```

New-UserToCloud -Shared -SharedMailboxEmailAlias Shared -Description "Shared's Description" -Password "Pass1255!!!$"

## PARAMETERS

### -UserToCopy
{{Fill UserToCopy Description}}

```yaml
Type: String
Parameter Sets: Copy
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Shared
{{Fill Shared Description}}

```yaml
Type: SwitchParameter
Parameter Sets: Shared
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -New
{{Fill New Description}}

```yaml
Type: SwitchParameter
Parameter Sets: New
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FirstName
{{Fill FirstName Description}}

```yaml
Type: String
Parameter Sets: Copy, New
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LastName
{{Fill LastName Description}}

```yaml
Type: String
Parameter Sets: Copy, New
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SharedMailboxEmailAlias
{{Fill SharedMailboxEmailAlias Description}}

```yaml
Type: String
Parameter Sets: Shared
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DisplayName
{{Fill DisplayName Description}}

```yaml
Type: String
Parameter Sets: Shared
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OfficePhone
{{Fill OfficePhone Description}}

```yaml
Type: String
Parameter Sets: Copy, New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MobilePhone
{{Fill MobilePhone Description}}

```yaml
Type: String
Parameter Sets: Copy, New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Description
{{Fill Description Description}}

```yaml
Type: String
Parameter Sets: Copy, Shared, New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -StreetAddress
{{Fill StreetAddress Description}}

```yaml
Type: String
Parameter Sets: New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -City
{{Fill City Description}}

```yaml
Type: String
Parameter Sets: New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -State
{{Fill State Description}}

```yaml
Type: String
Parameter Sets: New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Zip
{{Fill Zip Description}}

```yaml
Type: String
Parameter Sets: New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SAMPrefix
{{Fill SAMPrefix Description}}

```yaml
Type: String
Parameter Sets: Copy, New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
{{Fill Password Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoMail
{{Fill NoMail Description}}

```yaml
Type: SwitchParameter
Parameter Sets: Copy, New
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OUSearch
{{Fill OUSearch Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: Resources
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -EmailDomain
{{Fill EmailDomain Description}}

```yaml
Type: String
Parameter Sets: NoMail
Aliases: 

Required: True
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

