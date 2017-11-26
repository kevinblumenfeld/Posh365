---
external help file: Posh365-help.xml
Module Name: Posh365
online version: 
schema: 2.0.0
---

# Disable-Employee

## SYNOPSIS
Resets AD password to a random complex password, disables the AD User & Removes any Office 365 licenses. 
Also converts mailbox to a Shared Mailbox.
Lastly,allows for full access permissions to be granted to one more users over the shared mailbox.

## SYNTAX

```
Disable-Employee [[-UserToDisable] <String>] [-DontConvertToShared] [[-UsersToGiveFullAccess] <String[]>]
 [[-OUSearch2] <String>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Disable-Employee -UserToDisable rtodd@contoso.com -UsersToGiveFullAccess @("fred.smith@contoso.com","sal.jones@contoso.com")
```

## PARAMETERS

### -UserToDisable
{{Fill UserToDisable Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DontConvertToShared
{{Fill DontConvertToShared Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UsersToGiveFullAccess
{{Fill UsersToGiveFullAccess Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OUSearch2
{{Fill OUSearch2 Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

