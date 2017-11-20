---
external help file: Posh365-help.xml
Module Name: Posh365
online version: 
schema: 2.0.0
---

# Get-RetentionLinks

## SYNOPSIS
Reports on RetentionPolicies and their Tags, links & respective descriptions

## SYNTAX

```
Get-RetentionLinks [<CommonParameters>]
```

## DESCRIPTION
Reports on Exchange and Exchange Online Retention Policies, Retention Policy Tags and Retention Policy Tag Links

This function will display all Retention Policy Tags and to which Retention Policy they are linked

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-RetentionLinks | Export-Csv ./Retention.csv -NoTypeInformation
```

### -------------------------- EXAMPLE 2 --------------------------
```
Get-RetentionLinks | Out-GridView
```
## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

