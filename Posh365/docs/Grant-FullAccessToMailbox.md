---
external help file: Posh365-help.xml
Module Name: Posh365
online version: 
schema: 2.0.0
---

# Grant-FullAccessToMailbox

## SYNOPSIS
Grants Full Access mailbox permissions for one or more users over another mailbox

## SYNTAX

```
Grant-FullAccessToMailbox [[-Mailbox] <String>] [[-UserNeedingAccess] <String>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
"fred.smith@contoso.com","frank.jones@contoso.com" | Grant-FullAccessToMailbox -Mailbox "john.smith@contoso.com"
```

## PARAMETERS

### -Mailbox
{{Fill Mailbox Description}}

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

### -UserNeedingAccess
{{Fill UserNeedingAccess Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

