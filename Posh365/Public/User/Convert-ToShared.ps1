Function Convert-ToShared {
    <#
    .SYNOPSIS
    Converts a Cloud User Mailbox to a Shared Mailbox, Disables the AD User & Removes any licenses

    .EXAMPLE
    Convert-ToShared -UserToConvert JSMITH

    .EXAMPLE
    Convert-ToShared -UserToConvert JSMITH@CONTOSO.COM
   
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [string] $UserToConvert
    )
    
    Begin {
        $f2uSku = @{
            "AX ENTERPRISE USER" = "AX_ENTERPRISE_USER";
            "AX SELF-SERVE USER" = "AX_SELF-SERVE_USER";
            "AX_SANDBOX_INSTANCE_TIER2" = "AX_SANDBOX_INSTANCE_TIER2";
            "AX_TASK_USER" = "AX_TASK_USER";
            "Azure Active Directory Premium P1" = "AAD_PREMIUM";
            "Azure Active Directory Rights Management" = "RMS_S_ENTERPRISE";
            "Azure Rights Management Services Ad-hoc" = "RIGHTSMANAGEMENT_ADHOC";
            "Dynamics CRM Online Plan 2" = "CRMPLAN2";
            "Enterprise Mobility + Security E3" = "EMS";
            "Enterprise Mobility + Security E5" = "EMSPREMIUM";
            "ENTERPRISEPACK_B_PILOT" = "ENTERPRISEPACK_B_PILOT";
            "Exch Online Plan 2 for Faculty" = "EXCHANGEENTERPRISE_FACULTY";
            "Exchange Online (Plan 1)" = "EXCHANGE_L_STANDARD";
            "Exchange Online Advanced Threat Protection" = "ATP_ENTERPRISE_FACULTY";
            "Exchange Online ATP" = "ATP_ENTERPRISE";
            "Exchange Online Plan 1" = "EXCHANGESTANDARD";
            "Exchange Online Plan 2 S" = "EXCHANGE_S_ENTERPRISE";
            "Exchange Online Plan 2" = "EXCHANGEENTERPRISE";
            "Information Rights Management for Faculty" = "RIGHTSMANAGEMENT_STANDARD_FACULTY";
            "Information Rights Management for Students" = "RIGHTSMANAGEMENT_STANDARD_STUDENT";
            "Intune (Volume License)" = "INTUNE_A_VL";
            "Lync Online (Plan 1)" = "MCOLITE";
            "Microsoft Dynamics CRM Online Additional Storage" = "CRMSTORAGE";
            "Microsoft Flow Free" = "FLOW_FREE";
            "Microsoft Imagine Academy" = "IT_ACADEMY_AD";
            "Microsoft PowerApps and Logic flows" = "POWERAPPS_INDIVIDUAL_USER";
            "Microsoft Stream" = "STREAM";
            "MICROSOFT_BUSINESS_CENTER" = "MICROSOFT_BUSINESS_CENTER";
            "Minecraft Education Edition Faculty" = "MEE_FACULTY";
            "Minecraft Education Edition Student" = "MEE_STUDENT";
            "O365 Education E1 for Students" = "STANDARDWOFFPACK_STUDENT";
            "O365 Education for Faculty" = "STANDARDWOFFPACK_IW_FACULTY";
            "O365 Education for Students" = "STANDARDWOFFPACK_IW_STUDENT";
            "Office 365 (Plan A1) for Students" = "STANDARDPACK_STUDENT";
            "Office 365 (Plan E3)" = "ENTERPRISEPACKLRG";
            "Office 365 Advanced Compliance for faculty" = "EQUIVIO_ANALYTICS_FACULTY";
            "Office 365 Education E1 for Faculty" = "STANDARDWOFFPACK_FACULTY";
            "Office 365 Education E4 for Faculty" = "ENTERPRISEWITHSCAL_FACULTY";
            "Office 365 Education E4 for Students" = "ENTERPRISEWITHSCAL_STUDENT";
            "Office 365 Enterprise E1" = "STANDARDPACK";
            "Office 365 Enterprise E2" = "STANDARDWOFFPACK";
            "Office 365 Enterprise E3 without ProPlus Add-on" = "ENTERPRISEPACKWITHOUTPROPLUS";
            "Office 365 Enterprise E3" = "ENTERPRISEPACK";
            "Office 365 Enterprise E4" = "ENTERPRISEWITHSCAL";
            "Office 365 Enterprise E5" = "ENTERPRISEPREMIUM";
            "Office 365 Enterprise K1 with Yammer" = "DESKLESSPACK_YAMMER";
            "Office 365 Enterprise K1 without Yammer" = "DESKLESSPACK";
            "Office 365 Enterprise K2" = "DESKLESSWOFFPACK";
            "Office 365 Midsize Business" = "MIDSIZEPACK";
            "Office 365 Plan A2 for Faculty" = "STANDARDWOFFPACKPACK_FACULTY";
            "Office 365 Plan A2 for Students" = "STANDARDWOFFPACKPACK_STUDENT";
            "Office 365 Plan A3 for Faculty" = "ENTERPRISEPACK_FACULTY";
            "Office 365 Plan A3 for Students" = "ENTERPRISEPACK_STUDENT";
            "Office 365 ProPlus for Faculty" = "OFFICESUBSCRIPTION_FACULTY";
            "Office 365 Small Business Premium" = "LITEPACK_P2";
            "Office Online STD" = "WACSHAREPOINTSTD";
            "Office Online" = "SHAREPOINTWAC";
            "Office ProPlus Student Benefit" = "OFFICESUBSCRIPTION_STUDENT";
            "Office ProPlus" = "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ";
            "Power BI for Office 365 Individual" = "POWER_BI_INDIVIDUAL_USER";
            "Power BI for Office 365 Standalone" = "POWER_BI_STANDALONE";
            "Power BI for Office 365 Standard" = "POWER_BI_STANDARD";
            "POWER_BI_PRO" = "POWER_BI_PRO";
            "Project Lite" = "PROJECTESSENTIALS";
            "Project Online for Faculty Plan 1" = "PROJECTONLINE_PLAN_1_FACULTY";
            "Project Online for Faculty Plan 2" = "PROJECTONLINE_PLAN_2_FACULTY";
            "Project Online for Students Plan 1" = "PROJECTONLINE_PLAN_1_STUDENT";
            "Project Online for Students Plan 2" = "PROJECTONLINE_PLAN_2_STUDENT";
            "Project Online Premium" = "PROJECTPREMIUM";
            "Project Online Professional" = "PROJECTPROFESSIONAL";
            "Project Online with Project for Office 365" = "PROJECTONLINE_PLAN_1";
            "Project Pro for Office 365" = "PROJECTCLIENT";
            "PROJECT_MADEIRA_PREVIEW_IW" = "PROJECT_MADEIRA_PREVIEW_IW_SKU";
            "Secure Productive Enterprise E3" = "SPE_E3";
            "SharePoint Online (Plan 1) Lite" = "SHAREPOINTLITE";
            "SharePoint Online (Plan 1) MidMarket" = "SHAREPOINTENTERPRISE_MIDMARKET";
            "SharePoint Online (Plan 2)" = "SHAREPOINTENTERPRISE";
            "SharePoint Online Plan 1" = "SHAREPOINTSTANDARD";
            "STANDARD_B_PILOT" = "STANDARD_B_PILOT";
            "STANDARDPACK_FACULTY" = "STANDARDPACK_FACULTY";
            "Visio Pro for Office 365" = "VISIOCLIENT";
            "Yammer Enterprise" = "YAMMER_ENTERPRISE";
            "Yammer Midsize" = "YAMMER_MIDSIZE"
        }

        $f2uOpt = @{
            "Azure Active Directory Premium P2" = "AAD_PREMIUM_P2";
            "Azure Active Directory Premium Plan 1" = "AAD_PREMIUM";
            "Azure Information Protection Plan 1" = "RMS_S_PREMIUM";
            "Azure Information Protection Premium P2" = "RMS_S_PREMIUM2";
            "Azure Multi-Factor Authentication" = "MFA_PREMIUM";
            "Azure Rights Management" = "RMS_S_ENTERPRISE";
            "CRM for Partners" = "CRMIUR";
            "CRM Online" = "CRMSTANDARD";
            "CRM Test Instance" = "CRMTESTINSTANCE";
            "Customer Lockbox" = "LOCKBOX_ENTERPRISE";
            "Exchange Foundation for certain SKUs" = "EXCHANGE_S_FOUNDATION";
            "Exchange Kiosk" = "EXCHANGE_S_DESKLESS_GOV";
            "Exchange Online (Plan 1) for Students" = "EXCHANGESTANDARD_STUDENT";
            "Exchange Online (Plan 1)" = "EXCHANGE_S_STANDARD_MIDMARKET";
            "Exchange Online (Plan 2) Ent" = "EXCHANGE_S_ENTERPRISE";
            "Exchange Online (Plan 2)" = "EXCHANGE_S_STANDARD";
            "Exchange Online Advanced Threat Protection" = "ATP_ENTERPRISE";
            "Exchange Online Archiving Govt" = "EXCHANGE_S_ARCHIVE_ADDON_GOV";
            "Exchange Online Archiving" = "EXCHANGEARCHIVE";
            "Exchange Online Kiosk" = "EXCHANGE_S_DESKLESS";
            "Exchange Online POP" = "EXCHANGETELCO";
            "Exchange Online Protection for Faculty" = "EOP_ENTERPRISE_FACULTY";
            "Exchange Online Protection" = "EOP_ENTERPRISE";
            "Exchange Plan 2G" = "EXCHANGE_S_ENTERPRISE_GOV";
            "Flow for Office 365" = "FLOW_O365_P3";
            "Flow" = "FLOW_O365_P2";
            "Intune for Office 365" = "INTUNE_A";
            "Lync Online (Plan 1)" = "MCOSTANDARD_MIDMARKET";
            "Lync Online (Plan 3)" = "MCVOICECONF";
            "Lync Plan 2G" = "MCOSTANDARD_GOV";
            "Microsoft Business Center" = "MICROSOFT_BUSINESS_CENTER";
            "Microsoft Cloud App Security" = "ADALLOM_S_STANDALONE";
            "Microsoft Dynamics CRM Online Additional Storage" = "CRMSTORAGE";
            "Microsoft Dynamics Marketing Sales Collaboration" = "MDM_SALES_COLLABORATION";
            "Microsoft Forms (Plan 2)" = "OFFICE_FORMS_PLAN_2";
            "Microsoft Forms (Plan E3)" = "FORMS_PLAN_E3";
            "Microsoft Forms (Plan E5)" = "FORMS_PLAN_E5";
            "Microsoft Imagine Academy" = "IT_ACADEMY_AD";
            "Microsoft MyAnalytics" = "EXCHANGE_ANALYTICS";
            "Microsoft Office 365 (Plan A1) for Faculty" = "STANDARDPACK_FACULTY";
            "Microsoft Office 365 (Plan A1) for Students" = "STANDARDPACK_STUDENT";
            "Microsoft Office 365 (Plan A2) for Students" = "STANDARDWOFFPACK_STUDENT";
            "Microsoft Office 365 (Plan E1)" = "STANDARDPACK";
            "Microsoft Office 365 (Plan E2)" = "STANDARDWOFFPACK";
            "Microsoft Office 365 (Plan G1) for Government" = "STANDARDPACK_GOV";
            "Microsoft Office 365 (Plan G2) for Government" = "STANDARDWOFFPACK_GOV";
            "Microsoft Office 365 (Plan G3) for Government" = "ENTERPRISEPACK_GOV";
            "Microsoft Office 365 (Plan G4) for Government" = "ENTERPRISEWITHSCAL_GOV";
            "Microsoft Office 365 (Plan K1) for Government" = "DESKLESSPACK_GOV";
            "Microsoft Office 365 (Plan K2) for Government" = "DESKLESSWOFFPACK_GOV";
            "Microsoft Office 365 Exchange Online (Plan 1) only for Government" = "EXCHANGESTANDARD_GOV";
            "Microsoft Office 365 Exchange Online (Plan 2) only for Government" = "EXCHANGEENTERPRISE_GOV";
            "Microsoft Planner" = "PROJECTWORKMANAGEMENT";
            "Microsoft Social Listening Professional" = "NBPROFESSIONALFORCRM";
            "Microsoft StaffHub" = "Deskless";
            "Microsoft Stream for O365 E3 SKU" = "STREAM_O365_E3";
            "Microsoft Stream for O365 E5 SKU" = "STREAM_O365_E5";
            "Microsoft Teams" = "TEAMS1";
            "Minecraft Education Edition Faculty" = "MINECRAFT_EDUCATION_EDITION";
            "Mobile Device Management for Office 365" = "INTUNE_O365";
            "Office 365 (Plan P1)" = "LITEPACK";
            "Office 365 Advanced eDiscovery" = "EQUIVIO_ANALYTICS";
            "Office 365 Advanced Security Management" = "ADALLOM_S_O365";
            "Office 365 Education E1 for Faculty" = "STANDARDWOFFPACK_FACULTY";
            "Office 365 Education for Faculty" = "STANDARDWOFFPACK_IW_FACULTY";
            "Office 365 Education for Students" = "STANDARDWOFFPACK_IW_STUDENT";
            "Office 365 ProPlus" = "OFFICESUBSCRIPTION";
            "Office 365 Threat Intelligence" = "THREAT_INTELLIGENCE";
            "Office Online for Education" = "SHAREPOINTWAC_EDU";
            "Office Online for Government" = "SHAREPOINTWAC_GOV";
            "Office Online" = "SHAREPOINTWAC";
            "Office ProPlus Student Benefit" = "OFFICESUBSCRIPTION_STUDENT";
            "Office ProPlus" = "OFFICESUBSCRIPTION_GOV";
            "OneDrive Pack" = "WACONEDRIVESTANDARD";
            "OneDrive" = "ONEDRIVESTANDARD";
            "Power BI (free)" = "BI_AZURE_P0";
            "Power BI Information Services" = "SQL_IS_SSIM";
            "Power BI Pro" = "BI_AZURE_P2";
            "Power BI Reporting and Analytics" = "BI_AZURE_P1";
            "PowerApps for Office 365" = "POWERAPPS_O365_P3";
            "PowerApps" = "POWERAPPS_O365_P2";
            "Project Lite" = "PROJECT_ESSENTIALS";
            "Project Online (Plan 1)" = "PROJECTONLINE_PLAN_1";
            "Project Online (Plan 2)" = "PROJECTONLINE_PLAN_2";
            "Project Online Service for Education" = "SHAREPOINT_PROJECT_EDU";
            "Project Pro for Office 365" = "PROJECT_CLIENT_SUBSCRIPTION";
            "School Data Sync (Plan 1)" = "SCHOOL_DATA_SYNC_P1";
            "SharePoint Online (Plan 1)" = "SHAREPOINTENTERPRISE_MIDMARKET";
            "SharePoint Online (Plan 2) Project" = "SHAREPOINT_PROJECT";
            "SharePoint Online (Plan 2)" = "SHAREPOINTENTERPRISE";
            "SharePoint Online Kiosk Gov" = "SHAREPOINTDESKLESS_GOV";
            "SharePoint Online Kiosk" = "SHAREPOINTDESKLESS";
            "SharePoint Online Partner Access" = "SHAREPOINTPARTNER";
            "SharePoint Online Storage" = "SHAREPOINTSTORAGE";
            "SharePoint Plan 1 for EDU" = "SHAREPOINTSTANDARD_EDU";
            "SharePoint Plan 2 for EDU" = "SHAREPOINTENTERPRISE_EDU";
            "SharePoint Plan 2G" = "SHAREPOINTENTERPRISE_GOV";
            "Skype for Business Cloud PBX" = "MCOEV";
            "Skype for Business Online (Plan 2)" = "MCOSTANDARD";
            "Skype for Business PSTN Conferencing" = "MCOMEETADV";
            "Sway" = "SWAY";
            "Visio Pro for Office 365 Subscription" = "VISIO_CLIENT_SUBSCRIPTION";
            "Visio Pro for Office 365" = "VISIOCLIENT";
            "Windows 10 Enterprise E3" = "WIN10_PRO_ENT_SUB";
            "Windows Azure Active Directory Rights Management" = "RMS_S_ENTERPRISE_GOV";
            "Yammer Enterprise" = "YAMMER_ENTERPRISE";
            "Yammer for Academic" = "YAMMER_EDU";
            "Yammer" = "YAMMER_MIDSIZE"
        }
        $RootPath = $env:USERPROFILE + "\ps\"
        $User = $env:USERNAME
    
        if (!(Test-Path $RootPath)) {
            try {
                New-Item -ItemType Directory -Path $RootPath -ErrorAction STOP | Out-Null
            }
            catch {
                throw $_.Exception.Message
            }           
        }        
        While (!(Get-Content ($RootPath + "$($user).ADConnectServer") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-ADConnectServer
        }
            
        While (!(Get-Content ($RootPath + "$($user).EXCHServer") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-ExchangeServer
        }
        $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")
    
        While (!(Get-Content ($RootPath + "$($user).TargetAddressSuffix") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-TargetAddressSuffix
        }
        $targetAddressSuffix = Get-Content ($RootPath + "$($user).TargetAddressSuffix")
              
        While (!(Get-Content ($RootPath + "$($user).DomainController") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-DomainController
        }
        $DomainController = Get-Content ($RootPath + "$($user).DomainController")   

        try {
            (Get-OnPremExchangeServer -erroraction stop)[0] | Out-Null
        }
        catch {
            Connect-ToExchange -ExchangeServer $ExchangeServer  
        }
        try {
            Get-AzureADTenantDetail -erroraction stop | Out-Null
        }
        catch {
            Connect-ToCloud $targetAddressSuffix -AzureADver2
        }
        try {
            (Get-CloudAcceptedDomain -erroraction stop)[0] | Out-Null
        }
        catch {
            Connect-ToCloud $targetAddressSuffix -ExchangeOnline -EXOPrefix
        }
        [string[]]$skusToRemove = Get-CloudSku
    }
    Process {
        # Convert Cloud Mailbox to type, Shared.
        Set-CloudMailbox -Identity $UserToConvert -Type Shared
        Write-Output "$UserToConvert is being converted to a Shared Mailbox"

        # Modify OnPrem AD Attributes to that of a Remote Shared Mailbox
        if ($UserToConvert -like "*@*") {
            Get-ADUser -LDAPFilter "(Userprincipalname=$UserToConvert)" -Server $domainController | 
                Set-ADUser -Enabled:$False -replace @{msExchRemoteRecipientType = "100";
                msExchRecipientTypeDetails = "34359738368"
            }
            $UPN = (Get-ADUser -LDAPFilter "(Userprincipalname=$UserToConvert)" -Server $domainController).userprincipalname
        }
        else {
            Get-ADUser -LDAPFilter "(samaccountname=$UserToConvert)" -erroraction stop -Server $domainController | 
                Set-ADUser -Enabled:$False -replace @{msExchRemoteRecipientType = "100";
                msExchRecipientTypeDetails = "34359738368"
            }

            $UPN = (Get-ADUser -LDAPFilter "(samaccountname=$UserToConvert)" -Server $domainController).userprincipalname  
        }
        Write-Output "$UserToConvert is being converted to a Remote Shared Mailbox in Active Directory"

        # Remove any Licenses that the mailbox may have had
        $removeSkuGroup = @()
        $userL = Get-AzureADUser -ObjectId $UPN
        $userLicense = Get-AzureADUserLicenseDetail -ObjectId $UPN
        if ($skusToRemove) {
            Foreach ($removeSku in $skusToRemove) {
                if ($f2uSku.$removeSku) {
                    if ($f2uSku.$removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $UPN).skupartnumber) {
                        $removeSkuGroup += $f2uSku.$removeSku 
                    } 
                }
                else {
                    if ($removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $UPN).skupartnumber) {
                        $removeSkuGroup += $removeSku 
                    } 
                }
            }
            if ($removeSkuGroup) {
                Write-Output "$UserToConvert has the following Skus, removing these Sku now: $removeSkuGroup "
                $licensesToAssign = Set-SkuChange -remove -skus $removeSkuGroup
                Set-AzureADUserLicense -ObjectId $UserL.ObjectId -AssignedLicenses $licensesToAssign
            }
            Else {
                Write-Output "$UserToConvert licenses have been removed"
            }
        }
    }

    End {
    
    }
}    
