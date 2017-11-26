---
external help file: Posh365-help.xml
Module Name: Posh365
online version: 
schema: 2.0.0
---

# New-UserToCloud

## SYNOPSIS
1) Copies the properties of an existing AD User to a new AD User  
2) Enables the ADUser as a Remote Mailbox in Exchange/Office 365 (can select -noMail switch to assign no mailbox)  
3) Syncs changes to Office 365 with Azure AD Connect (AADC)  
4) Grid of licenses are presented to user of script to select from and then applied to 365 User

## SYNTAX

### Copy
```
New-UserToCloud -UserToCopy <String> -FirstName <String> -LastName <String> [-OfficePhone <String>]
 [-MobilePhone <String>] [-Description <String>] [-StreetAddress <String>] [-City <String>] [-State <String>]
 [-Zip <String>] [-SAMPrefix <String>] [-NoMail] [-Country <String>] [-Office <String>] [-Title <String>]
 [-Department <String>] [-Company <String>] [-OUSearch <String>] [-UPNSuffix <String>]
```

### Shared
```
New-UserToCloud [-Shared] -SharedMailboxEmailAlias <String> -DisplayName <String> [-Description <String>]
 [-OUSearch <String>]
```

### New
```
New-UserToCloud [-New] -FirstName <String> -LastName <String> [-OfficePhone <String>] [-MobilePhone <String>]
 [-Description <String>] [-StreetAddress <String>] [-City <String>] [-State <String>] [-Zip <String>]
 [-SAMPrefix <String>] [-NoMail] [-Country <String>] [-Office <String>] [-Title <String>]
 [-Department <String>] [-Company <String>] [-OUSearch <String>] [-UPNSuffix <String>]
```

### UPN
```
New-UserToCloud [-NoMail] -UPNSuffix <String>
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
New-UserToCloud -New -FirstName Kevin -LastName Todd
```

### -------------------------- EXAMPLE 2 --------------------------
```
When using the UPNSuffix parameter, simply type -UPNSuffix, then hit the space-bar, then tab through the available email domains.  The email domains are dynamically acquired from the environment where the script is run.  They 
This is only available/needed when using the *NoMail* switch.
```

New-UserToCloud -UserToCopy SmithJ -NoMail -FirstName Naomi -LastName Queen -StorePhone "777-222-3333,234" -MobilePhone "404-234-5555" -Description "Naomi's Description" -Prefix NN -UPNSuffix contoso.com

Once complete, hit enter and you will be prompted for the password for the user. 
Please enter a network password and hit enter when you are prompted like so, Enter a Password for the User:

### -------------------------- EXAMPLE 3 --------------------------
```
Notice the -Shared switch (below).  Use this to create a shared mailbox.  An Exchange Online License is needed but is automatically removed after 6 minutes
The SharedMailboxEmailAlias creates the email address.  In this example SalesDept@contoso.com is the desired email address, there for you would enter "SalesDept"
```

New-UserToCloud -Shared -SharedMailboxEmailAlias "SalesDept" -DisplayName "Sales Dept Shared Mailbox" -Description "Sales Department"

Once complete, hit enter and you will be prompted for the password for the user. 
Please enter a network password and hit enter when you are prompted like so, Enter a Password for the User:

## PARAMETERS

### -City
{{Fill City Description}}

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

### -Company
{{Fill Company Description}}

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

### -Country
{{Fill Country Description}}

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

### -Department
{{Fill Department Description}}

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

```yaml
Type: SwitchParameter
Parameter Sets: UPN
Aliases: 

Required: True
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OUSearch
{{Fill OUSearch Description}}

```yaml
Type: String
Parameter Sets: Copy, Shared, New
Aliases: 

Required: False
Position: Named
Default value: Resources
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Office
{{Fill Office Description}}

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

### -State
{{Fill State Description}}

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

### -StreetAddress
{{Fill StreetAddress Description}}

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

### -Title
{{Fill Title Description}}

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

### -Zip
{{Fill Zip Description}}

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

### -UPNSuffix
{{Fill UPNSuffix Description}}

```yaml
Type: String
Parameter Sets: Copy, New
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: UPN
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

