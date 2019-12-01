function Get-Sku2Service {
    Param (
        [Parameter()]
        [switch] $friendly,

        [Parameter()]
        [switch] $ugly,

        [Parameter()]
        [switch] $both
    )

    $u2fSku = @{
        "ATA"                                = "Azure Advanced Threat Protection for Users"
        "ADALLOM_STANDALONE"                 = "Microsoft Cloud App Security"
        "RIGHTSMANAGEMENT"                   = "AZURE INFORMATION PROTECTION PLAN 1"
        "THREAT_INTELLIGENCE"                = "OFFICE 365 ADVANCED THREAT PROTECTION (PLAN 2)"
        "AX_ENTERPRISE_USER"                 = "AX ENTERPRISE USER";
        "AX_SELF-SERVE_USER"                 = "AX SELF-SERVE USER";
        "AX_SANDBOX_INSTANCE_TIER2"          = "AX_SANDBOX_INSTANCE_TIER2";
        "AX_TASK_USER"                       = "AX_TASK_USER";
        "AAD_PREMIUM"                        = "Azure Active Directory Premium P1";
        "RMS_S_ENTERPRISE"                   = "Azure Active Directory Rights Management";
        "RIGHTSMANAGEMENT_ADHOC"             = "Azure Rights Management Services Ad-hoc";
        "CRMPLAN2"                           = "Dynamics CRM Online Plan 2";
        "EMS"                                = "Enterprise Mobility + Security E3";
        "EMSPREMIUM"                         = "Enterprise Mobility + Security E5";
        "ENTERPRISEPACK_B_PILOT"             = "ENTERPRISEPACK_B_PILOT";
        "EXCHANGEENTERPRISE_FACULTY"         = "Exch Online Plan 2 for Faculty";
        "EXCHANGE_L_STANDARD"                = "Exchange Online (Plan 1)";
        "ATP_ENTERPRISE_FACULTY"             = "Exchange Online Advanced Threat Protection";
        "ATP_ENTERPRISE"                     = "Exchange Online ATP";
        "EXCHANGESTANDARD"                   = "Exchange Online Plan 1";
        "EXCHANGE_S_ENTERPRISE"              = "Exchange Online Plan 2 S";
        "EXCHANGEENTERPRISE"                 = "Exchange Online Plan 2";
        "RIGHTSMANAGEMENT_STANDARD_FACULTY"  = "Information Rights Management for Faculty";
        "RIGHTSMANAGEMENT_STANDARD_STUDENT"  = "Information Rights Management for Students";
        "INTUNE_A_VL"                        = "Intune (Volume License)";
        "MCOLITE"                            = "Lync Online (Plan 1)";
        "CRMSTORAGE"                         = "Microsoft Dynamics CRM Online Additional Storage";
        "FLOW_FREE"                          = "Microsoft Flow Free";
        "IT_ACADEMY_AD"                      = "Microsoft Imagine Academy";
        "POWERAPPS_INDIVIDUAL_USER"          = "Microsoft PowerApps and Logic flows";
        "STREAM"                             = "Microsoft Stream";
        "MICROSOFT_BUSINESS_CENTER"          = "MICROSOFT_BUSINESS_CENTER";
        "MEE_FACULTY"                        = "Minecraft Education Edition Faculty";
        "MEE_STUDENT"                        = "Minecraft Education Edition Student";
        "STANDARDWOFFPACK_STUDENT"           = "O365 Education E1 for Students";
        "STANDARDWOFFPACK_IW_FACULTY"        = "O365 Education for Faculty";
        "STANDARDWOFFPACK_IW_STUDENT"        = "O365 Education for Students";
        "STANDARDPACK_STUDENT"               = "Office 365 (Plan A1) for Students";
        "ENTERPRISEPACKLRG"                  = "Office 365 (Plan E3)";
        "EQUIVIO_ANALYTICS_FACULTY"          = "Office 365 Advanced Compliance for faculty";
        "STANDARDWOFFPACK_FACULTY"           = "Office 365 Education E1 for Faculty";
        "ENTERPRISEWITHSCAL_FACULTY"         = "Office 365 Education E4 for Faculty";
        "ENTERPRISEWITHSCAL_STUDENT"         = "Office 365 Education E4 for Students";
        "STANDARDPACK"                       = "Office 365 Enterprise E1";
        "STANDARDWOFFPACK"                   = "Office 365 Enterprise E2";
        "ENTERPRISEPACKWITHOUTPROPLUS"       = "Office 365 Enterprise E3 without ProPlus Add-on";
        "ENTERPRISEPACK"                     = "Office 365 Enterprise E3";
        "ENTERPRISEWITHSCAL"                 = "Office 365 Enterprise E4";
        "ENTERPRISEPREMIUM"                  = "Office 365 Enterprise E5";
        "DESKLESSPACK_YAMMER"                = "Office 365 Enterprise K1 with Yammer";
        "DESKLESSPACK"                       = "Office 365 Enterprise K1 without Yammer";
        "DESKLESSWOFFPACK"                   = "Office 365 Enterprise K2";
        "MIDSIZEPACK"                        = "Office 365 Midsize Business";
        "STANDARDWOFFPACKPACK_FACULTY"       = "Office 365 Plan A2 for Faculty";
        "STANDARDWOFFPACKPACK_STUDENT"       = "Office 365 Plan A2 for Students";
        "ENTERPRISEPACK_FACULTY"             = "Office 365 Plan A3 for Faculty";
        "ENTERPRISEPACK_STUDENT"             = "Office 365 Plan A3 for Students";
        "OFFICESUBSCRIPTION_FACULTY"         = "Office 365 ProPlus for Faculty";
        "LITEPACK_P2"                        = "Office 365 Small Business Premium";
        "WACSHAREPOINTSTD"                   = "Office Online STD";
        "SHAREPOINTWAC"                      = "Office Online";
        "OFFICESUBSCRIPTION_STUDENT"         = "Office ProPlus Student Benefit";
        "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ" = "Office ProPlus";
        "POWER_BI_INDIVIDUAL_USER"           = "Power BI for Office 365 Individual";
        "POWER_BI_STANDALONE"                = "Power BI for Office 365 Standalone";
        "POWER_BI_STANDARD"                  = "Power BI for Office 365 Standard";
        "POWER_BI_PRO"                       = "POWER_BI_PRO";
        "PROJECTESSENTIALS"                  = "Project Lite";
        "PROJECTONLINE_PLAN_1_FACULTY"       = "Project Online for Faculty Plan 1";
        "PROJECTONLINE_PLAN_2_FACULTY"       = "Project Online for Faculty Plan 2";
        "PROJECTONLINE_PLAN_1_STUDENT"       = "Project Online for Students Plan 1";
        "PROJECTONLINE_PLAN_2_STUDENT"       = "Project Online for Students Plan 2";
        "PROJECTPREMIUM"                     = "Project Online Premium";
        "PROJECTPROFESSIONAL"                = "Project Online Professional";
        "PROJECTONLINE_PLAN_1"               = "Project Online with Project for Office 365";
        "PROJECTCLIENT"                      = "Project Pro for Office 365";
        "PROJECT_MADEIRA_PREVIEW_IW_SKU"     = "PROJECT_MADEIRA_PREVIEW_IW";
        "SPE_E3"                             = "MICROSOFT 365 E3";
        "SPE_E5"                             = "MICROSOFT 365 E5";
        "SHAREPOINTLITE"                     = "SharePoint Online (Plan 1) Lite";
        "SHAREPOINTENTERPRISE_MIDMARKET"     = "SharePoint Online (Plan 1) MidMarket";
        "SHAREPOINTENTERPRISE"               = "SharePoint Online (Plan 2)";
        "SHAREPOINTSTANDARD"                 = "SharePoint Online Plan 1";
        "STANDARD_B_PILOT"                   = "STANDARD_B_PILOT";
        "STANDARDPACK_FACULTY"               = "STANDARDPACK_FACULTY";
        "VISIOCLIENT"                        = "Visio Pro for Office 365";
        "YAMMER_ENTERPRISE"                  = "Yammer Enterprise";
        "YAMMER_MIDSIZE"                     = "Yammer Midsize";
        "SPB"                                = "Microsoft 365 Business"
    }
    $u2fOpt = @{
        "FLOW_P2_VIRAL"                  = "Flow Free"
        "DYN365_CDS_VIRAL"               = "Common Data Service"
        "ATA"                            = "Azure Advanced Threat Protection"
        "AAD_PREMIUM"                    = "Azure Active Directory Premium Plan 1";
        "AAD_PREMIUM_P2"                 = "Azure Active Directory Premium P2";
        "IT_ACADEMY_AD"                  = "Microsoft Imagine Academy";
        "ADALLOM_S_O365"                 = "Office 365 Advanced Security Management";
        "ADALLOM_S_STANDALONE"           = "Microsoft Cloud App Security";
        "ATP_ENTERPRISE"                 = "Exchange Online Advanced Threat Protection";
        "BI_AZURE_P0"                    = "Power BI (free)";
        "BI_AZURE_P1"                    = "Power BI Reporting and Analytics";
        "BI_AZURE_P2"                    = "Power BI Pro";
        "CRMIUR"                         = "CRM for Partners";
        "CRMSTANDARD"                    = "CRM Online";
        "CRMSTORAGE"                     = "Microsoft Dynamics CRM Online Additional Storage";
        "CRMTESTINSTANCE"                = "CRM Test Instance";
        "Deskless"                       = "Microsoft StaffHub";
        "DESKLESSPACK_GOV"               = "Microsoft Office 365 (Plan K1) for Government";
        "DESKLESSWOFFPACK_GOV"           = "Microsoft Office 365 (Plan K2) for Government";
        "ENTERPRISEPACK_GOV"             = "Microsoft Office 365 (Plan G3) for Government";
        "ENTERPRISEWITHSCAL_GOV"         = "Microsoft Office 365 (Plan G4) for Government";
        "EOP_ENTERPRISE"                 = "Exchange Online Protection";
        "EOP_ENTERPRISE_FACULTY"         = "Exchange Online Protection for Faculty";
        "EQUIVIO_ANALYTICS"              = "Office 365 Advanced eDiscovery";
        "EXCHANGE_ANALYTICS"             = "Microsoft MyAnalytics";
        "EXCHANGE_S_ARCHIVE_ADDON_GOV"   = "Exchange Online Archiving Govt";
        "EXCHANGE_S_DESKLESS"            = "Exchange Online Kiosk";
        "EXCHANGE_S_DESKLESS_GOV"        = "Exchange Kiosk";
        "EXCHANGE_S_ENTERPRISE"          = "Exchange Online (Plan 2) Ent";
        "EXCHANGE_S_ENTERPRISE_GOV"      = "Exchange Plan 2G";
        "EXCHANGE_S_FOUNDATION"          = "Exchange Foundation for certain SKUs";
        "EXCHANGE_S_STANDARD"            = "Exchange Online (Plan 2)";
        "EXCHANGE_S_STANDARD_MIDMARKET"  = "Exchange Online (Plan 1)";
        "EXCHANGEARCHIVE"                = "Exchange Online Archiving";
        "EXCHANGEENTERPRISE_GOV"         = "Microsoft Office 365 Exchange Online (Plan 2) only for Government";
        "EXCHANGESTANDARD_GOV"           = "Microsoft Office 365 Exchange Online (Plan 1) only for Government";
        "EXCHANGESTANDARD_STUDENT"       = "Exchange Online (Plan 1) for Students";
        "EXCHANGETELCO"                  = "Exchange Online POP";
        "FLOW_O365_P2"                   = "Flow";
        "FLOW_O365_P3"                   = "Flow for Office 365";
        "FORMS_PLAN_E3"                  = "Microsoft Forms (Plan E3)";
        "FORMS_PLAN_E5"                  = "Microsoft Forms (Plan E5)";
        "INTUNE_A"                       = "Intune for Office 365";
        "INTUNE_O365"                    = "Mobile Device Management for Office 365";
        "LITEPACK"                       = "Office 365 (Plan P1)";
        "LOCKBOX_ENTERPRISE"             = "Customer Lockbox";
        "MCOEV"                          = "Skype for Business Cloud PBX";
        "MCOMEETADV"                     = "Skype for Business PSTN Conferencing";
        "MCOSTANDARD"                    = "Skype for Business Online (Plan 2)";
        "MCOSTANDARD_GOV"                = "Lync Plan 2G";
        "MCOSTANDARD_MIDMARKET"          = "Lync Online (Plan 1)";
        "MCVOICECONF"                    = "Lync Online (Plan 3)";
        "MDM_SALES_COLLABORATION"        = "Microsoft Dynamics Marketing Sales Collaboration";
        "MFA_PREMIUM"                    = "Azure Multi-Factor Authentication";
        "MICROSOFT_BUSINESS_CENTER"      = "Microsoft Business Center";
        "MINECRAFT_EDUCATION_EDITION"    = "Minecraft Education Edition Faculty";
        "NBPROFESSIONALFORCRM"           = "Microsoft Social Listening Professional";
        "OFFICE_FORMS_PLAN_2"            = "Microsoft Forms (Plan 2)";
        "OFFICESUBSCRIPTION"             = "Office 365 ProPlus";
        "OFFICESUBSCRIPTION_GOV"         = "Office ProPlus";
        "OFFICESUBSCRIPTION_STUDENT"     = "Office ProPlus Student Benefit";
        "ONEDRIVESTANDARD"               = "OneDrive";
        "POWERAPPS_O365_P2"              = "PowerApps";
        "POWERAPPS_O365_P3"              = "PowerApps for Office 365";
        "PROJECT_CLIENT_SUBSCRIPTION"    = "Project Pro for Office 365";
        "PROJECT_ESSENTIALS"             = "Project Lite";
        "PROJECTONLINE_PLAN_1"           = "Project Online (Plan 1)";
        "PROJECTONLINE_PLAN_2"           = "Project Online (Plan 2)";
        "PROJECTWORKMANAGEMENT"          = "Microsoft Planner";
        "RMS_S_ENTERPRISE"               = "Azure Rights Management";
        "RMS_S_ENTERPRISE_GOV"           = "Windows Azure Active Directory Rights Management";
        "RMS_S_PREMIUM"                  = "Azure Information Protection Plan 1";
        "RMS_S_PREMIUM2"                 = "Azure Information Protection Premium P2";
        "SCHOOL_DATA_SYNC_P1"            = "School Data Sync (Plan 1)";
        "SHAREPOINT_PROJECT"             = "SharePoint Online (Plan 2) Project";
        "SHAREPOINT_PROJECT_EDU"         = "Project Online Service for Education";
        "SHAREPOINTDESKLESS"             = "SharePoint Online Kiosk";
        "SHAREPOINTDESKLESS_GOV"         = "SharePoint Online Kiosk Gov";
        "SHAREPOINTENTERPRISE"           = "SharePoint Online (Plan 2)";
        "SHAREPOINTENTERPRISE_EDU"       = "SharePoint Plan 2 for EDU";
        "SHAREPOINTENTERPRISE_GOV"       = "SharePoint Plan 2G";
        "SHAREPOINTENTERPRISE_MIDMARKET" = "SharePoint Online (Plan 1)";
        "SHAREPOINTPARTNER"              = "SharePoint Online Partner Access";
        "SHAREPOINTSTANDARD_EDU"         = "SharePoint Plan 1 for EDU";
        "SHAREPOINTSTORAGE"              = "SharePoint Online Storage";
        "SHAREPOINTWAC"                  = "Office Online";
        "SHAREPOINTWAC_EDU"              = "Office Online for Education";
        "SHAREPOINTWAC_GOV"              = "Office Online for Government";
        "SQL_IS_SSIM"                    = "Power BI Information Services";
        "STANDARDPACK"                   = "Microsoft Office 365 (Plan E1)";
        "STANDARDPACK_FACULTY"           = "Microsoft Office 365 (Plan A1) for Faculty";
        "STANDARDPACK_GOV"               = "Microsoft Office 365 (Plan G1) for Government";
        "STANDARDPACK_STUDENT"           = "Microsoft Office 365 (Plan A1) for Students";
        "STANDARDWOFFPACK"               = "Microsoft Office 365 (Plan E2)";
        "STANDARDWOFFPACK_FACULTY"       = "Office 365 Education E1 for Faculty";
        "STANDARDWOFFPACK_GOV"           = "Microsoft Office 365 (Plan G2) for Government";
        "STANDARDWOFFPACK_IW_FACULTY"    = "Office 365 Education for Faculty";
        "STANDARDWOFFPACK_IW_STUDENT"    = "Office 365 Education for Students";
        "STANDARDWOFFPACK_STUDENT"       = "Microsoft Office 365 (Plan A2) for Students";
        "STREAM_O365_E3"                 = "Microsoft Stream for O365 E3 SKU";
        "STREAM_O365_E5"                 = "Microsoft Stream for O365 E5 SKU";
        "SWAY"                           = "Sway";
        "TEAMS1"                         = "Microsoft Teams";
        "THREAT_INTELLIGENCE"            = "Office 365 Threat Intelligence";
        "VISIO_CLIENT_SUBSCRIPTION"      = "Visio Pro for Office 365 Subscription";
        "VISIOCLIENT"                    = "Visio Pro for Office 365";
        "WACONEDRIVESTANDARD"            = "OneDrive Pack";
        "WIN10_PRO_ENT_SUB"              = "Windows 10 Enterprise E3";
        "YAMMER_EDU"                     = "Yammer for Academic";
        "YAMMER_ENTERPRISE"              = "Yammer Enterprise";
        "YAMMER_MIDSIZE"                 = "Yammer"
    }
    $resultArray = @()
    $skus = (Get-AzureADSubscribedSku)
    if ($friendly) {
        foreach ($sku in $skus) {
            $sku2service = [ordered]@{ }
            foreach ($plan in $sku.serviceplans.serviceplanname) {
                if ($u2fSku.($sku.SkuPartNumber)) {
                    $sku2service['Sku'] = ($u2fSku.($sku.SkuPartNumber))
                }
                Else {
                    $sku2service['Sku'] = $sku.SkuPartNumber
                }
                if ($u2fOpt.$plan) {
                    $sku2service['Service'] = ($u2fOpt.$plan)
                }
                Else {
                    $sku2service['Service'] = $plan
                }
                $sku2service['Consumed'] = (($sku.prepaidunits.enabled) - ($sku.prepaidunits.enabled - $sku.consumedunits))
                $sku2service['Total'] = ($sku.prepaidunits.enabled)
                $resultArray += [psCustomObject]$sku2service
            }
        }
    }
    if ($both) {
        foreach ($sku in $skus) {
            $sku2service = [ordered]@{ }
            foreach ($plan in $sku.serviceplans.serviceplanname) {
                if ($u2fSku.($sku.SkuPartNumber)) {
                    $sku2service['FriendlySku'] = ($u2fSku.($sku.SkuPartNumber))
                }
                Else {
                    $sku2service['FriendlySku'] = $sku.SkuPartNumber
                }
                $sku2service['Sku'] = $sku.SkuPartNumber
                if ($u2fOpt.$plan) {
                    $sku2service['FriendlyService'] = ($u2fOpt.$plan)
                }
                Else {
                    $sku2service['FriendlyService'] = $plan
                }
                $sku2service['Service'] = $plan
                $sku2service['Consumed'] = (($sku.prepaidunits.enabled) - ($sku.prepaidunits.enabled - $sku.consumedunits))
                $sku2service['Total'] = ($sku.prepaidunits.enabled)
                $resultArray += [psCustomObject]$sku2service
            }
        }
    }
    If ($ugly) {
        foreach ($sku in $skus) {
            $sku2service = [ordered]@{ }
            foreach ($plan in $sku.serviceplans.serviceplanname) {
                $sku2service['Sku'] = $sku.SkuPartNumber
                $sku2service['Service'] = $plan
                $sku2service['Consumed'] = (($sku.prepaidunits.enabled) - ($sku.prepaidunits.enabled - $sku.consumedunits))
                $sku2service['Total'] = ($sku.prepaidunits.enabled)
                $resultArray += [psCustomObject]$sku2service
            }
        }
    }
    $resultArray
}
