
# Posh365

###### Install
```powershell
Set-ExecutionPolicy RemoteSigned
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-Module Posh365 -Force
```

###### Install without Admin Access
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-Module Posh365 -Force -Scope CurrentUser
```
### `Connect`

**Connect-Cloud** Connect to one or more services: Az, AzureAD, Compliance, Exo2, MSOnline, SharePoint & Teams

```powershell
Connect-Cloud -Tenant Contoso -EXO2 -MSOnline -AzureAD
Connect-Cloud -Tenant Contoso -SharePoint
Connect-Cloud -Tenant Contoso -Compliance
Connect-Cloud -Tenant Contoso -EXO2 -MSOnline -AzureAD -MFA #when using MFA
Connect-Cloud -Tenant Contoso -DeleteCreds #Deletes locally encrypted creds only
```

**Connect-CloudMFA** Same as Connect-Cloud but includes built-in password manager gui

```powershell
Connect-CloudMFA -Tenant Contoso -EXO2 -MSOnline -AzureAD -Teams
```
**Connect-Exchange** Connect to Exchange on-premises
```powershell
Connect-Exchange -Server EXHybrid #Encrypts and reuses creds locally
Connect-Exchange -Server EXHybrid -DontViewEntireForest
Connect-Exchange -Server EXHybrid -DeleteExchangeCreds #Deletes locally encrypted creds only
```
**Export-GraphConfig** Use a Gui to save/encrypt ClientID, TenantID, Secret, UserName & Password  
**Connect-PoshGraph** Use saved encrypted credentials to connnect to Graph and Azure APIs
```powershell
Export-GraphConfig -Tenant Contoso 
Connect-PoshGraph -Tenant Contoso
```

### `Discover Office 365`
```powershell
Get-DiscoveryOffice365 -Tenant Contoso -Verbose
```
**Choose** all but Compliance & click OK  
**Choose** Connection type & click OK  

><sub>**First time running this?** Let's install PowerShellGet2:</sub>  

<sub>1. Run: Connect-Cloud -Tenant Contoso -EXO2</sub>  
<sub>2. Sign in as Global Admin & restart powershell when prompted</sub>  
<sub>3. Run: Get-DiscoveryOffice365 -Tenant Contoso -Verbose</sub>  

### `Discover On-Premises`
> <sub>Requires RSAT</sub>  
```powershell
Get-DiscoveryOnPrem -Verbose
```
<sub>1. Run: Get-Discovery -Verbose</sub>  
<sub>2. Enter name of Exchange Server when prompted</sub>  
<sub>3. Click link for Batches, copy/paste code on-premises</sub>  
<sub>4. Click link for Permissions, copy/paste code on-premises</sub>  
<sub>5. Add both documents to the root of SharePoint > Documents</sub>  
<sub>6. Add BATCH01 to BatchName column in Batches.xlsx for pilot</sub>  


| Document to add to SharePoint | Paste code on-premises (not EMS) |
| :---------------------------: | :------------------------------: |
| Batches.xlsx | https://bit.ly/corebatches |
| Permissions.xlsx | http://bit.ly/PermissionsScaled |


### `Migrate from Hybrid to Office 365`
> <sub>**Note**: Each command presents a GUI for selection and confirmation</sub>

#### `Analyze Permissions`
**Update-MailboxMovePermissionBatch** Gui to analyze permissions of mailboxes from Batches.xlsx. Will output new Batches.xlsx to desktop. Can add to SharePoint as new Batches file. 
```powershell
$params = @{
    SharePointURL = 'https://Contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
}
Update-MailboxMovePermissionBatch @params
```  

#### `Migrate`

**Test-MailboxMove** Gui to test migration readiness of the mailboxes from Batches.xlsx. Of each user to be migrated, reports PASS or FAIL overall and individual on the following tests:
* Verifies each smtp address domain is an accepted domain
* Verifies mail user exists in Exchange Online
* Verifies mailbox does not exist in Exchange Online
* Verifies mail user is DirSynced
* Verifies UserMailboxes accounts are not disabled
* Verifies Routing Address is valid
* Verifies UserPrincipalName matches PrimarySmtpAddress (Use -SkipUpnMatchSmtpTest to skip this test)

```powershell
$params = @{
    SharePointURL = 'https://Contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
}
Test-MailboxMove @params
```
**New-MailboxMove** Creates new move requests. Example uses batches file in SP site named "migrate". Use links in Discovery On-Premises to create Batches and Permissions files [[ Link ]](https://github.com/kevinblumenfeld/Posh365#discover-on-premises)
```powershell
$params = @{
    SharePointURL = 'https://Contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
    RemoteHost    = 'hybrid.Contoso.com'
    Tenant        = 'Contoso'
}
New-MailboxMove @params
```

**Set-MailboxMove** Set move requests

```powershell
Set-MailboxMove -BadItemLimit 300 -LargeItemLimit 400
```

**Suspend-MailboxMove** Suspends move requests

```powershell
Suspend-MailboxMove
```
**Resume-MailboxMove** Resumes move requests
```powershell
Resume-MailboxMove
Resume-MailboxMove -DontAutoComplete
```

**Remove-MailboxMove** Removes move requests
```powershell
Remove-MailboxMove
```
**Complete-MailboxMove** Complete move requests
```powershell
Complete-MailboxMove
Complete-MailboxMove -Schedule #Gui presented to pick time, date, and users
```
#### `Report on Migration`
**Get-MailboxMoveStatistics** Gets move request statistics for any or all move requests. Multi-select or select all, click OK 
```powershell
Get-MailboxMoveStatistics
Get-MailboxMoveStatistics -IncludeCompleted
```
**Get-MailboxMoveReport** Gets full move request report - from present to past. The way it should be
```powershell
Get-MailboxMoveReport
```

#### `License`

**Set-MailboxMoveLicense** Gui to licenses users via AzureAD
```powershell
Set-MailboxMoveLicense
Set-MailboxMoveLicense -MailboxCSV .\UserPrincipalName.csv

$params = @{
    SharePointURL = 'https://Contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
 }
Set-MailboxMoveLicense @params
```

**Get-MailboxMoveLicense** Reports on user license Skus via AzureAD
```powershell
Get-MailboxMoveLicense
Get-MailboxMoveLicense -OneSkuPerLine
Get-MailboxMoveLicense -OneSkuPerLine -ExportToExcel # file saved in Posh365 folder on desktop
Get-MailboxMoveLicense -IncludeRecipientType # Connect to EXO2

$params = @{
    SharePointURL = 'https://Contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
 }
Get-MailboxMoveLicense @params
```
**Get-MailboxMoveLicenseCount** Reports on a tenant's consumed and total skus and options
```powershell
Get-MailboxMoveLicenseCount
```
**Get-MailboxMoveLicenseReport** Reports on each user's assigned skus and options, csv and excel output
```powershell
Get-MailboxMoveLicenseReport -Path C:\temp\
```
### `Mail Flow`  
#### `Message Trace`

**Trace-Message** GUI to trace Exchange Online messages. Select messages & click OK for trace details
```powershell
Trace-Message # all messages from past 15 minutes
Trace-Message -StartSearchHoursAgo 6.3 -EndSearchHoursAgo 5 -Subject 'From the CEO'
Trace-Message -StartSearchHoursAgo 10 -Sender jane@Contoso.com
Trace-Message -Sender jane@Contoso.com -Recipient emily@Contoso.com
```

**Trace-ExchangeMessage** GUI to trace on-premises messages. Select messages & click OK for messageID details
```powershell
Trace-ExchangeMessage # all messages from past 15 minutes
Trace-ExchangeMessage -StartSearchHoursAgo 10 -ExportToCsv
Trace-ExchangeMessage -StartSearchHoursAgo 10 -ExportToExcel -SkipHealthMessages
```
### `Administration`  
#### `Managed Folder Assistant`
**Get-MfaStats** Return Managed Folder Assistant statistics as an object. Switch to start the MFA too
```powershell
'jane@Contoso.com' | Get-MfaStats
'jane@Contoso.com' | Get-MfaStats -StartMFA
(Import-CSV .\mailboxes.csv).UserPrincipalName | Get-MfaStats
(Import-CSV .\mailboxes.csv).UserPrincipalName | Get-MfaStats -StartMFA
(Get-EXOMailbox -Properties Office -Filter "Office -eq 'Redmond'").UserPrincipalName | Get-MfaStats
(Get-EXOMailbox -Properties Office -Filter "Office -eq 'Redmond'").UserPrincipalName | Get-MfaStats -StartMFA
```
### `Networking`  
#### `Office365 Endpoints`
**Get-OfficeEndpoints** URLs and IPs, initial and "changes since", CSV and Excel output (click to enlarge)

![ME3V6nNhwV](https://user-images.githubusercontent.com/28877715/71635906-fcb6a980-2bf6-11ea-927e-03c9bda8f2a4.gif)
