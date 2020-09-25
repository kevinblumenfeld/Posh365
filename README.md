
# Posh365



# `Install Posh365`

```
Set-ExecutionPolicy RemoteSigned
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-Module Posh365 -Force
```


# `Install Posh365 without Admin Access`

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-Module Posh365 -Force -Scope CurrentUser
```

# `Discovery`



## `Office 365 Discovery`
> First time? Run:  ```Connect-Cloud -Tenant Contoso -EXO2```
> Sign in as Global Admin & restart powershell when prompted
```
Get-DiscoveryOffice365 -Tenant Contoso -Verose
```
**Choose** all but Compliance & click OK
**Choose** Connection type & click OK
## `On Premises Discovery`
> Requires RSAT
```
Get-DiscoveryOnPrem -Verbose
```
Enter name of Exchange Server when prompted
Last, click each link, copy/paste code on-premise & add to documents to SharePoint:

| Document to add to SharePoint | Paste code on-premises (not EMS) |
| :---------------------------: | :------------------------------: |
| Batches.xlsx | https://bit.ly/corebatches |
| Permissions.xlsx | http://bit.ly/PermissionsScaled |





# `Commands`
### `Migration`

#### `Connect`

*  **Connect-CloudMFA** Connect to EXOv2, MSOnline, AzureAD, SharePoint, Compliance.

*  **Connect-Exchange** Connect to Exchange on-premises

#### `Migrate`

*  **New-MailboxMove** Creates new move requests

*  **Set-MailboxMove** Set move requests.

*  **Suspend-MailboxMove** Suspends move requests.

*  **Resume-MailboxMove** Resumes move requests. Includes the switch -DontAutoComplete

*  **Remove-MailboxMove** Removes move requests.

*  **Complete-MailboxMove** Complete move requests.

#### `Report`
*  **Get-MailboxMove** Gets current move requests.

*  **Get-MailboxMoveStatistics** Gets move request statistics.

*  **Get-MailboxMoveReport** Gets full move request report.

#### `License`

*  **Set-MailboxMoveLicense** Licenses users via AzureAD.

*  **Get-MailboxMoveLicense** Reports on user licenses.

*  **Get-MailboxMoveLicenseCount** Reports on a tenant's skus and options.

*  **Get-MailboxMoveLicenseReport** Reports on each user's assigned skus and options.



#### `Message Trace`

*  **Trace-Message** GUI to trace Exchange Online messages. Click messages for trace details.

*  **Trace-ExchangeMessage** GUI to trace Exchange on-premises messages. Click messages to trace by message id.
### `Administration`

#### `Managed Folder Assistant`
* **Get-MfaStats** Return Managed Folder Assistant statistics as an object. Switch to start the MFA too.
```
(Get-EXOMailbox -Properties Office -Filter "Office -eq 'Redmond'").UserPrincipalName | Get-MfaStats
'jane@contoso.com' | Get-MfaStats -StartMFA
```

#### `Office365 Endpoints`
*  **Get-OfficeEndpoints** URLs and IPs, initial and "changes since", CSV and Excel output (click to enlarge)

![ME3V6nNhwV](https://user-images.githubusercontent.com/28877715/71635906-fcb6a980-2bf6-11ea-927e-03c9bda8f2a4.gif)
