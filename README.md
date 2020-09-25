
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
Connect-Cloud -Tenant contoso -EXO2 -MSonline -AzureAD
Connect-Cloud -Tenant contoso -SharePoint
Connect-Cloud -Tenant contoso -Compliance
Connect-Cloud -Tenant contoso -EXO2 -MSonline -AzureAD -MFA #when using MFA
Connect-Cloud -Tenant contoso -DeleteCreds #Deletes locally encrypted creds only
```

**Connect-CloudMFA** Same as Connect-Cloud but includes built-in password manager gui

```powershell
Connect-CloudMFA -Tenant contoso -EXO2 -MSonline -AzureAD -Teams
```
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
Export-GraphConfig -Tenant contoso 
Connect-Exchange -Server EXHybrid -DontViewEntireForest
Connect-Exchange -Server EXHybrid -DeleteExchangeCreds #Deletes locally encrypted creds only
```

### `Discover Office 365`
```powershell
Get-DiscoveryOffice365 -Tenant contoso -Verose
```
**Choose** all but Compliance & click OK
**Choose** Connection type & click OK

`First time running Get-DiscoveryOffice365?`  

<sub>1. Run: Connect-Cloud -Tenant contoso -EXO2</sub>
<sub>2. Sign in as Global Admin & restart powershell when prompted</sub>
<sub>3. Installs modules PowerShellGet2 & ExchangeOnlineManagement</sub>


### `Discover On-Premises`
> Requires RSAT
```powershell
Get-DiscoveryOnPrem -Verbose
```
Enter name of Exchange Server when prompted
Last, click each link, copy/paste code on-premise & add to documents to SharePoint:

| Document to add to SharePoint | Paste code on-premises (not EMS) |
| :---------------------------: | :------------------------------: |
| Batches.xlsx | https://bit.ly/corebatches |
| Permissions.xlsx | http://bit.ly/PermissionsScaled |


### `Migrate from Hybrid to Office 365`
> *Note*: each command presents a GUI for selection and confirmation

**New-MailboxMove** Creates new move requests
```powershell
$params = @{
    SharePointURL = 'https://contoso.sharepoint.com/sites/migrate'
    ExcelFile     = 'Batches.xlsx'
    RemoteHost    = 'hybrid.contoso.com'
    Tenant        = 'contoso'
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
Complete-MailboxMove -Schedule #Gui presented to pick users and time
```

#### `Report`
**Get-MailboxMove** Gets current move requests

**Get-MailboxMoveStatistics** Gets move request statistics

**Get-MailboxMoveReport** Gets full move request report

#### `License`

**Set-MailboxMoveLicense** Licenses users via AzureAD

**Get-MailboxMoveLicense** Reports on user licenses

**Get-MailboxMoveLicenseCount** Reports on a tenant's skus and options

**Get-MailboxMoveLicenseReport** Reports on each user's assigned skus and options



#### `Message Trace`

**Trace-Message** GUI to trace Exchange Online messages. Click messages for trace details

**Trace-ExchangeMessage** GUI to trace Exchange on-premises messages. Click messages to trace by message id
### `Administration`

#### `Managed Folder Assistant`
* **Get-MfaStats** Return Managed Folder Assistant statistics as an object. Switch to start the MFA too
```powershell
(Get-EXOMailbox -Properties Office -Filter "Office -eq 'Redmond'").UserPrincipalName | Get-MfaStats
'jane@contoso.com' | Get-MfaStats -StartMFA
```

#### `Office365 Endpoints`
**Get-OfficeEndpoints** URLs and IPs, initial and "changes since", CSV and Excel output (click to enlarge)

![ME3V6nNhwV](https://user-images.githubusercontent.com/28877715/71635906-fcb6a980-2bf6-11ea-927e-03c9bda8f2a4.gif)
