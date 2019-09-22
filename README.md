# Posh365
Module used by Office 365 consultants and admins to migrate, discover and manage.

This module leverages several native cmdlets.  I created this for my everyday use.
All feedback is welcome.

## How to install
```
Install-Module Posh365 -Force
```

## Install without admin access
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Install-Module Posh365 -Force -Scope CurrentUser
```


## Function Examples
_Syntax_: https://github.com/kevinblumenfeld/Posh365Demo

###Connect
* **Connect-CloudMFA** Connect to EXO, MSOnline, AzureAD, SharePoint, Compliance.
###Migrate
* **New-MailboxMove** Creates new move requests
* **Get-MailboxMove** Gets current move requests.
* **Set-MailboxMove** Set move requests.
* **Suspend-MailboxMove** Suspends move requests.
* **Resume-MailboxMove** Resumes move requests.
* **Remove-MailboxMove** Removes move requests.
###Report
* **Get-MailboxMoveStatistic** Gets move request statistics.
* **Get-MailboxMoveReport** Gets full move request report.
###License
* **Set-MailboxMoveLicense** Licenses users via AzureAD.
* **Get-MailboxMoveLicense** Reports on user licenses.
* **Get-MailboxMoveLicenseCount** Reports on a tenant's skus and options.
* **Get-MailboxMoveLicenseReport** Reports on each user's assigned skus and options.

