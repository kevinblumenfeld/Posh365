---
external help file: PSLicense-help.xml
online version: 
schema: 2.0.0
---

# Get-LACloudLicense

## SYNOPSIS
Exports all of a Office 365 tenant's licensed users. 
Based on a script by Alan Byrne

## SYNTAX

```
Get-LACloudLicense [<CommonParameters>]
```

## DESCRIPTION
Exports all of a Office 365 tenant's licensed users. 
Detailing which users have which SKU and if the provisioning status of each Option in that SKU
There is an Excel Macro with instruction in the comments in the script which divide into tabs, each Sku
Once connected to MSOnline, simply run the script (as in the example) and a time/date stamped file 
will be created in the current directory. 
The excel macro should then be used. 
Can be time consuming
run against large tenants.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Get-LAConnected -Tenant Contoso -ExchangeAndMSOL
```

Get-LACloudLicense

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

