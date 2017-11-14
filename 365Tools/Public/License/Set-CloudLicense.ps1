<#
.EXTERNALHELP ..\PSLicense-help.xml
#>
function Set-CloudLicense {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    Param
    (

        [Parameter(Mandatory = $false)]
        [switch] $RemoveSkus,
        
        [Parameter(Mandatory = $false)]
        [switch] $AddSkus,

        [Parameter(Mandatory = $false)]
        [switch] $RemoveOptions,

        [Parameter(Mandatory = $false)]
        [switch] $AddOptions,

        [Parameter(Mandatory = $false)]
        [switch] $MoveOptionsFromOneSkuToAnother,

        [Parameter(Mandatory = $false)]
        [switch] $MoveOptionsSourceOptionsToIgnore,
        
        [Parameter(Mandatory = $false)]
        [switch] $MoveOptionsDestOptionsToAdd,
                
        [Parameter(Mandatory = $false)]
        [switch] $TemplateMode,

        [Parameter(Mandatory = $false)]
        [switch] $ReportUserLicenses,      

        [Parameter(Mandatory = $false)]
        [switch] $ReportUserLicensesEnabled,        
        
        [Parameter(Mandatory = $false)]
        [switch] $ReportUserLicensesDisabled,        
                
        [Parameter(Mandatory = $false)]
        [switch] $DisplayTenantsSkusAndOptions,
                
        [Parameter(Mandatory = $false)]
        [switch] $DisplayTenantsSkusAndOptionsFriendlyNames,
                
        [Parameter(Mandatory = $false)]
        [switch] $DisplayTenantsSkusAndOptionsLookup,

        [Parameter(Mandatory = $false)]
        [string[]] $ExternalOptionsToAdd,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $UserPrincipalName

    )

    # Begin Block
    Begin {

        # Create hashtable from Name to SkuId lookup
        $skuIdHash = @{}
        $licenses = Get-AzureADSubscribedSku
        $licenses | Select SkuPartNumber, SkuId | ForEach-Object {
            $skuIdHash[$_.SkuPartNumber] = $_.SkuId
        }
        $planId = @{}
        foreach ($license in $licenses) {
            foreach ($row in $($license.ServicePlans)) {
                $planId[$row.serviceplanId] = $row.serviceplanname
            }
        }
        # Assign Tenant and Location to a variable
        $tenant = ((Get-AzureADTenantDetail).verifiedDomains | where {$_.initial -eq "$true"}).name.split(".")[0]
        $location = "US"
        
        # Friendly 2 Ugly hashtable Lookups
        $f2uSku = @{
            "AX ENTERPRISE USER"                               = "AX_ENTERPRISE_USER";
            "AX SELF-SERVE USER"                               = "AX_SELF-SERVE_USER";
            "AX_SANDBOX_INSTANCE_TIER2"                        = "AX_SANDBOX_INSTANCE_TIER2";
            "AX_TASK_USER"                                     = "AX_TASK_USER";
            "Azure Active Directory Premium P1"                = "AAD_PREMIUM";
            "Azure Active Directory Rights Management"         = "RMS_S_ENTERPRISE";
            "Azure Rights Management Services Ad-hoc"          = "RIGHTSMANAGEMENT_ADHOC";
            "Dynamics CRM Online Plan 2"                       = "CRMPLAN2";
            "Enterprise Mobility + Security E3"                = "EMS";
            "Enterprise Mobility + Security E5"                = "EMSPREMIUM";
            "ENTERPRISEPACK_B_PILOT"                           = "ENTERPRISEPACK_B_PILOT";
            "Exch Online Plan 2 for Faculty"                   = "EXCHANGEENTERPRISE_FACULTY";
            "Exchange Online (Plan 1)"                         = "EXCHANGE_L_STANDARD";
            "Exchange Online Advanced Threat Protection"       = "ATP_ENTERPRISE_FACULTY";
            "Exchange Online ATP"                              = "ATP_ENTERPRISE";
            "Exchange Online Plan 1"                           = "EXCHANGESTANDARD";
            "Exchange Online Plan 2 S"                         = "EXCHANGE_S_ENTERPRISE";
            "Exchange Online Plan 2"                           = "EXCHANGEENTERPRISE";
            "Information Rights Management for Faculty"        = "RIGHTSMANAGEMENT_STANDARD_FACULTY";
            "Information Rights Management for Students"       = "RIGHTSMANAGEMENT_STANDARD_STUDENT";
            "Intune (Volume License)"                          = "INTUNE_A_VL";
            "Lync Online (Plan 1)"                             = "MCOLITE";
            "Microsoft Dynamics CRM Online Additional Storage" = "CRMSTORAGE";
            "Microsoft Flow Free"                              = "FLOW_FREE";
            "Microsoft Imagine Academy"                        = "IT_ACADEMY_AD";
            "Microsoft PowerApps and Logic flows"              = "POWERAPPS_INDIVIDUAL_USER";
            "Microsoft Stream"                                 = "STREAM";
            "MICROSOFT_BUSINESS_CENTER"                        = "MICROSOFT_BUSINESS_CENTER";
            "Minecraft Education Edition Faculty"              = "MEE_FACULTY";
            "Minecraft Education Edition Student"              = "MEE_STUDENT";
            "O365 Education E1 for Students"                   = "STANDARDWOFFPACK_STUDENT";
            "O365 Education for Faculty"                       = "STANDARDWOFFPACK_IW_FACULTY";
            "O365 Education for Students"                      = "STANDARDWOFFPACK_IW_STUDENT";
            "Office 365 (Plan A1) for Students"                = "STANDARDPACK_STUDENT";
            "Office 365 (Plan E3)"                             = "ENTERPRISEPACKLRG";
            "Office 365 Advanced Compliance for faculty"       = "EQUIVIO_ANALYTICS_FACULTY";
            "Office 365 Education E1 for Faculty"              = "STANDARDWOFFPACK_FACULTY";
            "Office 365 Education E4 for Faculty"              = "ENTERPRISEWITHSCAL_FACULTY";
            "Office 365 Education E4 for Students"             = "ENTERPRISEWITHSCAL_STUDENT";
            "Office 365 Enterprise E1"                         = "STANDARDPACK";
            "Office 365 Enterprise E2"                         = "STANDARDWOFFPACK";
            "Office 365 Enterprise E3 without ProPlus Add-on"  = "ENTERPRISEPACKWITHOUTPROPLUS";
            "Office 365 Enterprise E3"                         = "ENTERPRISEPACK";
            "Office 365 Enterprise E4"                         = "ENTERPRISEWITHSCAL";
            "Office 365 Enterprise E5"                         = "ENTERPRISEPREMIUM";
            "Office 365 Enterprise K1 with Yammer"             = "DESKLESSPACK_YAMMER";
            "Office 365 Enterprise K1 without Yammer"          = "DESKLESSPACK";
            "Office 365 Enterprise K2"                         = "DESKLESSWOFFPACK";
            "Office 365 Midsize Business"                      = "MIDSIZEPACK";
            "Office 365 Plan A2 for Faculty"                   = "STANDARDWOFFPACKPACK_FACULTY";
            "Office 365 Plan A2 for Students"                  = "STANDARDWOFFPACKPACK_STUDENT";
            "Office 365 Plan A3 for Faculty"                   = "ENTERPRISEPACK_FACULTY";
            "Office 365 Plan A3 for Students"                  = "ENTERPRISEPACK_STUDENT";
            "Office 365 ProPlus for Faculty"                   = "OFFICESUBSCRIPTION_FACULTY";
            "Office 365 Small Business Premium"                = "LITEPACK_P2";
            "Office Online STD"                                = "WACSHAREPOINTSTD";
            "Office Online"                                    = "SHAREPOINTWAC";
            "Office ProPlus Student Benefit"                   = "OFFICESUBSCRIPTION_STUDENT";
            "Office ProPlus"                                   = "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ";
            "Power BI for Office 365 Individual"               = "POWER_BI_INDIVIDUAL_USER";
            "Power BI for Office 365 Standalone"               = "POWER_BI_STANDALONE";
            "Power BI for Office 365 Standard"                 = "POWER_BI_STANDARD";
            "POWER_BI_PRO"                                     = "POWER_BI_PRO";
            "Project Lite"                                     = "PROJECTESSENTIALS";
            "Project Online for Faculty Plan 1"                = "PROJECTONLINE_PLAN_1_FACULTY";
            "Project Online for Faculty Plan 2"                = "PROJECTONLINE_PLAN_2_FACULTY";
            "Project Online for Students Plan 1"               = "PROJECTONLINE_PLAN_1_STUDENT";
            "Project Online for Students Plan 2"               = "PROJECTONLINE_PLAN_2_STUDENT";
            "Project Online Premium"                           = "PROJECTPREMIUM";
            "Project Online Professional"                      = "PROJECTPROFESSIONAL";
            "Project Online with Project for Office 365"       = "PROJECTONLINE_PLAN_1";
            "Project Pro for Office 365"                       = "PROJECTCLIENT";
            "PROJECT_MADEIRA_PREVIEW_IW"                       = "PROJECT_MADEIRA_PREVIEW_IW_SKU";
            "Secure Productive Enterprise E3"                  = "SPE_E3";
            "SharePoint Online (Plan 1) Lite"                  = "SHAREPOINTLITE";
            "SharePoint Online (Plan 1) MidMarket"             = "SHAREPOINTENTERPRISE_MIDMARKET";
            "SharePoint Online (Plan 2)"                       = "SHAREPOINTENTERPRISE";
            "SharePoint Online Plan 1"                         = "SHAREPOINTSTANDARD";
            "STANDARD_B_PILOT"                                 = "STANDARD_B_PILOT";
            "STANDARDPACK_FACULTY"                             = "STANDARDPACK_FACULTY";
            "Visio Pro for Office 365"                         = "VISIOCLIENT";
            "Yammer Enterprise"                                = "YAMMER_ENTERPRISE";
            "Yammer Midsize"                                   = "YAMMER_MIDSIZE"
        }

        $f2uOpt = @{
            "Azure Active Directory Premium P2"                                 = "AAD_PREMIUM_P2";
            "Azure Active Directory Premium Plan 1"                             = "AAD_PREMIUM";
            "Azure Information Protection Plan 1"                               = "RMS_S_PREMIUM";
            "Azure Information Protection Premium P2"                           = "RMS_S_PREMIUM2";
            "Azure Multi-Factor Authentication"                                 = "MFA_PREMIUM";
            "Azure Rights Management"                                           = "RMS_S_ENTERPRISE";
            "CRM for Partners"                                                  = "CRMIUR";
            "CRM Online"                                                        = "CRMSTANDARD";
            "CRM Test Instance"                                                 = "CRMTESTINSTANCE";
            "Customer Lockbox"                                                  = "LOCKBOX_ENTERPRISE";
            "Exchange Foundation for certain SKUs"                              = "EXCHANGE_S_FOUNDATION";
            "Exchange Kiosk"                                                    = "EXCHANGE_S_DESKLESS_GOV";
            "Exchange Online (Plan 1) for Students"                             = "EXCHANGESTANDARD_STUDENT";
            "Exchange Online (Plan 1)"                                          = "EXCHANGE_S_STANDARD_MIDMARKET";
            "Exchange Online (Plan 2) Ent"                                      = "EXCHANGE_S_ENTERPRISE";
            "Exchange Online (Plan 2)"                                          = "EXCHANGE_S_STANDARD";
            "Exchange Online Advanced Threat Protection"                        = "ATP_ENTERPRISE";
            "Exchange Online Archiving Govt"                                    = "EXCHANGE_S_ARCHIVE_ADDON_GOV";
            "Exchange Online Archiving"                                         = "EXCHANGEARCHIVE";
            "Exchange Online Kiosk"                                             = "EXCHANGE_S_DESKLESS";
            "Exchange Online POP"                                               = "EXCHANGETELCO";
            "Exchange Online Protection for Faculty"                            = "EOP_ENTERPRISE_FACULTY";
            "Exchange Online Protection"                                        = "EOP_ENTERPRISE";
            "Exchange Plan 2G"                                                  = "EXCHANGE_S_ENTERPRISE_GOV";
            "Flow for Office 365"                                               = "FLOW_O365_P3";
            "Flow"                                                              = "FLOW_O365_P2";
            "Intune for Office 365"                                             = "INTUNE_A";
            "Lync Online (Plan 1)"                                              = "MCOSTANDARD_MIDMARKET";
            "Lync Online (Plan 3)"                                              = "MCVOICECONF";
            "Lync Plan 2G"                                                      = "MCOSTANDARD_GOV";
            "Microsoft Business Center"                                         = "MICROSOFT_BUSINESS_CENTER";
            "Microsoft Cloud App Security"                                      = "ADALLOM_S_STANDALONE";
            "Microsoft Dynamics CRM Online Additional Storage"                  = "CRMSTORAGE";
            "Microsoft Dynamics Marketing Sales Collaboration"                  = "MDM_SALES_COLLABORATION";
            "Microsoft Forms (Plan 2)"                                          = "OFFICE_FORMS_PLAN_2";
            "Microsoft Forms (Plan E3)"                                         = "FORMS_PLAN_E3";
            "Microsoft Forms (Plan E5)"                                         = "FORMS_PLAN_E5";
            "Microsoft Imagine Academy"                                         = "IT_ACADEMY_AD";
            "Microsoft MyAnalytics"                                             = "EXCHANGE_ANALYTICS";
            "Microsoft Office 365 (Plan A1) for Faculty"                        = "STANDARDPACK_FACULTY";
            "Microsoft Office 365 (Plan A1) for Students"                       = "STANDARDPACK_STUDENT";
            "Microsoft Office 365 (Plan A2) for Students"                       = "STANDARDWOFFPACK_STUDENT";
            "Microsoft Office 365 (Plan E1)"                                    = "STANDARDPACK";
            "Microsoft Office 365 (Plan E2)"                                    = "STANDARDWOFFPACK";
            "Microsoft Office 365 (Plan G1) for Government"                     = "STANDARDPACK_GOV";
            "Microsoft Office 365 (Plan G2) for Government"                     = "STANDARDWOFFPACK_GOV";
            "Microsoft Office 365 (Plan G3) for Government"                     = "ENTERPRISEPACK_GOV";
            "Microsoft Office 365 (Plan G4) for Government"                     = "ENTERPRISEWITHSCAL_GOV";
            "Microsoft Office 365 (Plan K1) for Government"                     = "DESKLESSPACK_GOV";
            "Microsoft Office 365 (Plan K2) for Government"                     = "DESKLESSWOFFPACK_GOV";
            "Microsoft Office 365 Exchange Online (Plan 1) only for Government" = "EXCHANGESTANDARD_GOV";
            "Microsoft Office 365 Exchange Online (Plan 2) only for Government" = "EXCHANGEENTERPRISE_GOV";
            "Microsoft Planner"                                                 = "PROJECTWORKMANAGEMENT";
            "Microsoft Social Listening Professional"                           = "NBPROFESSIONALFORCRM";
            "Microsoft StaffHub"                                                = "Deskless";
            "Microsoft Stream for O365 E3 SKU"                                  = "STREAM_O365_E3";
            "Microsoft Stream for O365 E5 SKU"                                  = "STREAM_O365_E5";
            "Microsoft Teams"                                                   = "TEAMS1";
            "Minecraft Education Edition Faculty"                               = "MINECRAFT_EDUCATION_EDITION";
            "Mobile Device Management for Office 365"                           = "INTUNE_O365";
            "Office 365 (Plan P1)"                                              = "LITEPACK";
            "Office 365 Advanced eDiscovery"                                    = "EQUIVIO_ANALYTICS";
            "Office 365 Advanced Security Management"                           = "ADALLOM_S_O365";
            "Office 365 Education E1 for Faculty"                               = "STANDARDWOFFPACK_FACULTY";
            "Office 365 Education for Faculty"                                  = "STANDARDWOFFPACK_IW_FACULTY";
            "Office 365 Education for Students"                                 = "STANDARDWOFFPACK_IW_STUDENT";
            "Office 365 ProPlus"                                                = "OFFICESUBSCRIPTION";
            "Office 365 Threat Intelligence"                                    = "THREAT_INTELLIGENCE";
            "Office Online for Education"                                       = "SHAREPOINTWAC_EDU";
            "Office Online for Government"                                      = "SHAREPOINTWAC_GOV";
            "Office Online"                                                     = "SHAREPOINTWAC";
            "Office ProPlus Student Benefit"                                    = "OFFICESUBSCRIPTION_STUDENT";
            "Office ProPlus"                                                    = "OFFICESUBSCRIPTION_GOV";
            "OneDrive Pack"                                                     = "WACONEDRIVESTANDARD";
            "OneDrive"                                                          = "ONEDRIVESTANDARD";
            "Power BI (free)"                                                   = "BI_AZURE_P0";
            "Power BI Information Services"                                     = "SQL_IS_SSIM";
            "Power BI Pro"                                                      = "BI_AZURE_P2";
            "Power BI Reporting and Analytics"                                  = "BI_AZURE_P1";
            "PowerApps for Office 365"                                          = "POWERAPPS_O365_P3";
            "PowerApps"                                                         = "POWERAPPS_O365_P2";
            "Project Lite"                                                      = "PROJECT_ESSENTIALS";
            "Project Online (Plan 1)"                                           = "PROJECTONLINE_PLAN_1";
            "Project Online (Plan 2)"                                           = "PROJECTONLINE_PLAN_2";
            "Project Online Service for Education"                              = "SHAREPOINT_PROJECT_EDU";
            "Project Pro for Office 365"                                        = "PROJECT_CLIENT_SUBSCRIPTION";
            "School Data Sync (Plan 1)"                                         = "SCHOOL_DATA_SYNC_P1";
            "SharePoint Online (Plan 1)"                                        = "SHAREPOINTENTERPRISE_MIDMARKET";
            "SharePoint Online (Plan 2) Project"                                = "SHAREPOINT_PROJECT";
            "SharePoint Online (Plan 2)"                                        = "SHAREPOINTENTERPRISE";
            "SharePoint Online Kiosk Gov"                                       = "SHAREPOINTDESKLESS_GOV";
            "SharePoint Online Kiosk"                                           = "SHAREPOINTDESKLESS";
            "SharePoint Online Partner Access"                                  = "SHAREPOINTPARTNER";
            "SharePoint Online Storage"                                         = "SHAREPOINTSTORAGE";
            "SharePoint Plan 1 for EDU"                                         = "SHAREPOINTSTANDARD_EDU";
            "SharePoint Plan 2 for EDU"                                         = "SHAREPOINTENTERPRISE_EDU";
            "SharePoint Plan 2G"                                                = "SHAREPOINTENTERPRISE_GOV";
            "Skype for Business Cloud PBX"                                      = "MCOEV";
            "Skype for Business Online (Plan 2)"                                = "MCOSTANDARD";
            "Skype for Business PSTN Conferencing"                              = "MCOMEETADV";
            "Sway"                                                              = "SWAY";
            "Visio Pro for Office 365 Subscription"                             = "VISIO_CLIENT_SUBSCRIPTION";
            "Visio Pro for Office 365"                                          = "VISIOCLIENT";
            "Windows 10 Enterprise E3"                                          = "WIN10_PRO_ENT_SUB";
            "Windows Azure Active Directory Rights Management"                  = "RMS_S_ENTERPRISE_GOV";
            "Yammer Enterprise"                                                 = "YAMMER_ENTERPRISE";
            "Yammer for Academic"                                               = "YAMMER_EDU";
            "Yammer"                                                            = "YAMMER_MIDSIZE"
        }

        # Based on Runtime switches, Out-GridView(s) are presented for user input
        if ($RemoveSkus) {
            [string[]]$skusToRemove = (Get-CloudSku | Out-GridView -Title "SKUs to Remove" -PassThru)
        }
        if ($AddSkus) {
            $skusToAdd = (Get-CloudSku | Out-GridView -Title "SKUs to Add" -PassThru)
        }
        if ($RemoveOptions) {
            [string[]]$optionsToRemove = (Get-CloudSkuTable -all | Out-GridView -Title "Options to Remove" -PassThru)
        }
        if ($AddOptions) {
            [string[]]$optionsToAdd = (Get-CloudSkuTable -all | Out-GridView -Title "Options to Add" -PassThru)
        } 
        if ($MoveOptionsFromOneSkuToAnother) {
            $swapSource = (Get-CloudSku | Out-GridView -Title "Swap Sku - SOURCE" -PassThru)
            $swapDest = (Get-CloudSku | Out-GridView -Title "Swap Sku - DESTINATION" -PassThru)
        }
        if ($MoveOptionsSourceOptionsToIgnore) {
            if ($f2uSku.$swapSource) {
                [string[]]$sourceIgnore = (Get-CloudSkuTable -sIgnore -sourceSku $f2uSku.$swapSource | Out-GridView -Title "SOURCE Options to Ignore" -PassThru)
            }
            else {
                [string[]]$sourceIgnore = (Get-CloudSkuTable -sIgnore -sourceSku $swapSource | Out-GridView -Title "SOURCE Options to Ignore" -PassThru)
            }
            if ($sourceIgnore) {
                $sourceIgnore = $sourceIgnore | % {
                    if ($f2uOpt[($_).split("*")[1]]) {
                        $f2uOpt[($_).split("*")[1]]
                    }
                    else {
                        ($_).split("*")[1]
                    }
                } 
            }
        }
        if ($MoveOptionsDestOptionsToAdd) {
            if ($f2uSku.$swapDest) {
                $destOptAdd = (Get-CloudSkuTable -destAdd -destSku $f2uSku.$swapDest | Out-GridView -Title "DESTINATION Options to add" -PassThru)
            }
            else {
                $destOptAdd = (Get-CloudSkuTable -destAdd -destSku $swapDest | Out-GridView -Title "DESTINATION Options to add" -PassThru)
            }
        }
        if ($TemplateMode) {
            [string[]]$template = (Get-CloudSkuTable -all | Out-GridView -Title "Create a Template to Apply - All existing Options will be replaced if Sku is selected here" -PassThru)
        }
        if ($DisplayTenantsSkusAndOptions) {
            [string[]]$allSkusOptions = (Get-Sku2Service -ugly | Out-GridView -Title "All Skus and Options")
        }
        if ($DisplayTenantsSkusAndOptionsFriendlyNames) {
            [string[]]$allSkusOptions = (Get-Sku2Service -friendly | Out-GridView -Title "All Skus and Options Friendly Names")
        }
        if ($DisplayTenantsSkusAndOptionsLookup) {
            [string[]]$allSkusOptions = (Get-Sku2Service -both | Out-GridView -Title "All Skus and Options Friendly and Ugly Name Lookup")
        }
    }

    Process {
        if ($ExternalOptionsToAdd) {
            $optionsToAdd = $ExternalOptionsToAdd
        }

        # Define Arrays
        $removeSkuGroup = @() 
        $addSkuGroup = @()
        $addAlreadySkuGroup = @()
        $enabled = @()
        $disabled = @()
        $sKey = @()

        # Set user-specific variables
        $user = Get-AzureADUser -ObjectId $_
        $userLicense = Get-AzureADUserLicenseDetail -ObjectId $_
        Set-AzureADUser -ObjectId $_ -UsageLocation $location
        
        # Remove Sku(s)
        if ($skusToRemove) {
            Foreach ($removeSku in $skusToRemove) {
                if ($f2uSku.$removeSku) {
                    if ($f2uSku.$removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $removeSkuGroup += $f2uSku.$removeSku 
                    } 
                }
                else {
                    if ($removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $removeSkuGroup += $removeSku 
                    } 
                }
            }
            if ($removeSkuGroup) {
                Write-Output "$($_) has the following Skus, removing these Sku now: $removeSkuGroup "
                $licensesToAssign = Set-SkuChange -remove -skus $removeSkuGroup
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
            }
            Else {
                Write-Output "$($_) does not have any of the Skus requested for removal"
            }
        }
        # Add Sku(s).  If user has Sku already, all options will be added        
        if ($skusToAdd) {
            Foreach ($addSku in $skusToAdd) {
                if ($f2uSku.$addSku) {
                    if ($f2uSku.$addSku -notin (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $addSkuGroup += $f2uSku.$addSku 
                    } 
                    if ($f2uSku.$addSku -in (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $addAlreadySkuGroup += $f2uSku.$addSku
                    } 
                }
                else {
                    if ($addSku -notin (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $addSkuGroup += $addSku 
                    } 
                    if ($addSku -in (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $addAlreadySkuGroup += $addSku
                    } 
                }
            }
            # Add fresh Sku(s)
            if ($addSkuGroup) {
                Write-Output "$($_) does not have the following Skus, adding these Sku now: $addSkuGroup "
                $licensesToAssign = Set-SkuChange -add -skus $addSkuGroup
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
            }
            # Backfill already assigned Sku(s) with any missing options
            if ($addAlreadySkuGroup) {
                Write-Output "$($_) already has the following Skus, adding any options not currently assigned: $addAlreadySkuGroup "
                $licensesToAssign = Set-SkuChange -addAlready -skus $addAlreadySkuGroup
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
            }
        }
        # Remove Options.  Only if user is assigned Sku.
        if ($optionsToRemove) {
            $hashRem = @{}
            for ($i = 0; $i -lt $optionsToRemove.count; $i++) {
                if ($optionsToRemove[$i]) {
                    if ($f2uSku[$optionsToRemove[$i].split("*")[0]]) {
                        # FRIENDLY SKU TRACT 
                        if ($hashRem.containskey($f2uSku[$optionsToRemove[$i].split("*")[0]])) {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) += @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    EXISTING
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) += @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) = @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    FRESH!
                                $hashRem.($f2uSku[$optionsToRemove[$i].split("*")[0]]) = @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                    }
                    # UGLY SKU TRACT 
                    else {
                        if ($hashRem.containskey($optionsToRemove[$i].split("*")[0])) {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashRem.($optionsToRemove[$i].split("*")[0]) += @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    EXISTING
                                $hashRem.($optionsToRemove[$i].split("*")[0]) += @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToRemove[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashRem.($optionsToRemove[$i].split("*")[0]) = @($f2uOpt[$optionsToRemove[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    FRESH!
                                $hashRem.($optionsToRemove[$i].split("*")[0]) = @($optionsToRemove[$i].split("*")[1])
                            }
                        }
                    }
                }
            }
            $hashRem.GetEnumerator() | ForEach-Object { 
                Write-Output "$($user.UserPrincipalName) : $($_.key) : $($_.value) "
                # User already has Sku
                $sKey = $_.key
                if ($sKey -in $userLicense.skupartnumber) {
                    $disabled = $_.Value + ((($userLicense | Where {$_.skupartnumber -contains $sKey}).serviceplans | where {$_.provisioningStatus -eq 'Disabled'}).serviceplanname)
                    $completed = $false
                    $retry = 0
                    While ((! $completed) -and ($retry -le 5)) {
                        Try {
                            $retry++
                            $licensesToAssign = Set-SkuChange -removeTheOptions -skus $sKey -options $disabled
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                            Write-Output "Options from Sku: $sKey to remove + options currently disabled: $disabled "
                            $completed = $true
                        }
                        Catch {
                            $_.exception.Message -match "\bplan\s+([-0-9a-f]{36})" | Out-Null
                            $matches[1] -split (' ') | % {$disabled += ($planId[($_).trim()])}
                        }
                    }
                    if (! $completed) {
                        Write-Output "$($user.UserPrincipalName) unable to remove options to Sku: $sKey "
                    }
                }
                # User does not have Sku so do nothing
                else {
                    Write-Output "User does not have SKU $sKey, no options to remove"
                }   
            }
        }
        # Add Option(s). User will be assigned Sku with the options if user has yet to have Sku assigned 
        if ($optionsToAdd -or $ExternalOptionsToAdd) {
            $hashAdd = @{}
            for ($i = 0; $i -lt $optionsToAdd.count; $i++) {
                if ($optionsToAdd[$i]) {
                    if ($f2uSku[$optionsToAdd[$i].split("*")[0]]) {
                        # FRIENDLY SKU TRACT 
                        if ($hashAdd.containskey($f2uSku[$optionsToAdd[$i].split("*")[0]])) {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) += @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    EXISTING
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) += @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) = @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    FRESH!
                                $hashAdd.($f2uSku[$optionsToAdd[$i].split("*")[0]]) = @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                    }
                    # UGLY SKU TRACT 
                    else {
                        if ($hashAdd.containskey($optionsToAdd[$i].split("*")[0])) {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) += @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    EXISTING
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) += @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$optionsToAdd[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) = @($f2uOpt[$optionsToAdd[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    FRESH!
                                $hashAdd.($optionsToAdd[$i].split("*")[0]) = @($optionsToAdd[$i].split("*")[1])
                            }
                        }
                    }
                }
            }
            $hashAdd.GetEnumerator() | ForEach-Object { 
                Write-Output "$($user.UserPrincipalName) : $($_.key) : $($_.value) "
                # User already has Sku
                $sKey = $_.key
                if ($sKey -in $userLicense.skupartnumber) {
                    $enabled = [pscustomobject]$_.Value + ((($userLicense | Where {$_.skupartnumber -contains $sKey}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname)
                    $completed = $false
                    $retry = 0
                    While ((! $completed) -and ($retry -le 5)) {
                        Try {
                            $retry++
                            $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            Write-Output "Options from Sku: $sKey to add + options currently enabled: $enabled "
                            $completed = $true
                        }
                        Catch {
                            $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                            $matches[1] -split (' ') | % {$enabled += ($planId[($_).trim()])}
                        }
                    }
                    if (! $completed) {
                        Write-Output "$($user.UserPrincipalName) unable to apply options to Sku: $sKey "
                    }
                }
                # User does not have Sku yet
                else {
                    $enabled = [pscustomobject]$_.Value
                    $completed = $false
                    $retry = 0
                    While ((! $completed) -and ($retry -le 5)) {
                        Try {
                            $retry++
                            $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            Write-Output "User does not have SKU: $sKey, adding Sku with options: $enabled "
                            $completed = $true
                        }
                        Catch {
                            $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                            $matches[1] -split (' ') | % {$enabled += ($planId[($_).trim()])}
                        }
                    }
                    if (! $completed) {
                        Write-Output "$($user.UserPrincipalName) unable to apply options to Sku: $sKey "
                    }
                }
            }
        }
        if ($MoveOptionsFromOneSkuToAnother) {
            if (($userLicense.skupartnumber.Contains($swapSource)) -or ($userLicense.skupartnumber.Contains($f2uSku.$swapSource))) {
                if (($f2uSku.$swapDest) -and ($f2uSku.$swapSource)) {
                    if (($f2uSku.$swapDest) -eq ($f2uSku.$swapSource)) {
                        Write-Output "Source and Destination Skus are identical"
                        Write-Output "Source Sku: $($f2uSku.$swapSource) and Destination Sku: $($f2uSku.$swapDest) are identical."
                        Write-Output "Please choose a different Source or Destination Sku"                
                        Break
                    }
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $f2uSku.$swapDest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $($f2uSku.$swapDest) licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $f2uSku.$swapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            $source = $source | Where {$sourceIgnore -notcontains $_}
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -contains $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        if ($destOptAdd) {
                            $doa = $destOptAdd | % {
                                if ($f2uOpt[($_).split("*")[1]]) {
                                    $f2uOpt[($_).split("*")[1]]
                                }
                                else {
                                    ($_).split("*")[1]
                                }
                            } 
                            $options2swap += $doa
                        }   
                        $completed = $false
                        $retry = 0
                        While ((! $completed) -and ($retry -le 5)) {
                            Try {
                                $retry++
                                $licensesToAssign = Set-SkuChange -addTheOptions -skus $f2uSku.$swapDest -options $options2swap
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                                $licensesToAssign = Set-SkuChange -remove -skus $f2uSku.$swapSource
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                                Write-Output "$($user.UserPrincipalName) Source: $($f2uSku.$swapSource) Dest: $($f2uSku.$swapDest) Moved Options: $options2swap "
                                $completed = $true
                            }
                            Catch {
                                $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                                $matches[1] -split (' ') | % {$options2swap += ($planId[($_).trim()])}
                            }
                        }
                        if (! $completed) {
                            Write-Output "Unable to properly add some or all of Options for destination Sku: $($f2uSku.$swapDest) Did not remove Sku: $($f2uSku.$swapSource) "
                            Write-Output "FAILED: $($user.UserPrincipalName) Source: $($f2uSku.$swapSource) Dest: $($f2uSku.$swapDest) Options: $options2swap "
                        }
                    }
                }
                if ((!($f2uSku.$swapDest)) -and ($f2uSku.$swapSource)) {
                    if (($swapDest) -eq ($f2uSku.$swapSource)) {
                        Write-Output "Source and Destination Skus are identical"
                        Write-Output "Source Sku: $($f2uSku.$swapSource) and Destination Sku: $($swapDest) are identical."
                        Write-Output "Please choose a different Source or Destination Sku"                
                        Break
                    }
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $swapDest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $swapDest licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $f2uSku.$swapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            $source = $source | Where {$sourceIgnore -notcontains $_}
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -contains $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        if ($destOptAdd) {
                            $doa = $destOptAdd | % {
                                if ($f2uOpt[($_).split("*")[1]]) {
                                    $f2uOpt[($_).split("*")[1]]
                                }
                                else {
                                    ($_).split("*")[1]
                                }
                            } 
                            $options2swap += $doa
                        }
                        $completed = $false
                        $retry = 0
                        While ((! $completed) -and ($retry -le 5)) {
                            Try {
                                $retry++
                                $licensesToAssign = Set-SkuChange -addTheOptions -skus $swapDest -options $options2swap
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                                $licensesToAssign = Set-SkuChange -remove -skus $f2uSku.$swapSource
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                                Write-Output "$($user.UserPrincipalName) Source: $($f2uSku.$swapSource) Dest: $swapDest Moved Options: $options2swap "
                                $completed = $true
                            }
                            Catch {
                                $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                                $matches[1] -split (' ') | % {$options2swap += ($planId[($_).trim()])}
                            }
                        }
                        if (! $completed) { 
                            Write-Output "Unable to properly add some or all of Options for destination Sku: $swapDest Did not remove Sku: $($f2uSku.$swapSource) "
                            Write-Output "FAILED: $($user.UserPrincipalName) Source: $($f2uSku.$swapSource) Dest: $swapDest Options: $options2swap "
                        }
                    }
                }
                if (($f2uSku.$swapDest) -and (!($f2uSku.$swapSource))) {
                    if (($f2uSku.$swapDest) -eq ($swapSource)) {
                        Write-Output "Source and Destination Skus are identical"
                        Write-Output "Source Sku: $swapSource and Destination Sku: $($f2uSku.$swapDest) are identical."
                        Write-Output "Please choose a different Source or Destination Sku"                
                        Break
                    }
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $f2uSku.$swapDest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $($f2uSku.$swapDest) licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $swapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            $source = $source | Where {$sourceIgnore -notcontains $_}
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -contains $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        if ($destOptAdd) {
                            $doa = $destOptAdd | % {
                                if ($f2uOpt[($_).split("*")[1]]) {
                                    $f2uOpt[($_).split("*")[1]]
                                }
                                else {
                                    ($_).split("*")[1]
                                }
                            } 
                            $options2swap += $doa
                        }
                        $completed = $false
                        $retry = 0
                        While ((! $completed) -and ($retry -le 5)) {
                            Try {
                                $retry++
                                $licensesToAssign = Set-SkuChange -addTheOptions -skus $f2uSku.$swapDest -options $options2swap
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                                $licensesToAssign = Set-SkuChange -remove -skus $swapSource
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                                Write-Output "$($user.UserPrincipalName) Source: $swapSource Dest: $($f2uSku.$swapDest) Moved Options: $options2swap "
                                $completed = $true
                            }
                            Catch {
                                $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                                $matches[1] -split (' ') | % {$options2swap += ($planId[($_).trim()])}
                            }
                        }
                        if (! $completed) { 
                            Write-Output "Unable to properly add some or all of Options for destination Sku: $($f2uSku.$swapDest) Did not remove Sku: $swapSource "
                            Write-Output "FAILED: $($user.UserPrincipalName) Source: $swapSource Dest: $($f2uSku.$swapDest) Options: $options2swap "
                        }
                    }
                }
                if ((!($f2uSku.$swapDest)) -and (!($f2uSku.$swapSource))) {
                    if (($swapDest) -eq ($swapSource)) {
                        Write-Output "Source and Destination Skus are identical"
                        Write-Output "Source Sku: $swapSource and Destination Sku: $swapDest are identical."
                        Write-Output "Please choose a different Source or Destination Sku"                
                        Break
                    }
                    (Get-AzureADSubscribedSku | Where {$_.skupartnumber -eq $swapDest}) | ForEach-Object {
                        if (($_.prepaidunits.enabled - $_.consumedunits) -lt "1") {
                            Write-Output "Out of $swapDest licenses.  Please allocate more then rerun."
                            Break 
                        }
                        $dest = $_.serviceplans.serviceplanname
                        $source = ((Get-AzureADUserLicenseDetail -ObjectId $user.UserPrincipalName | Where {$_.skupartnumber -eq $swapSource}).serviceplans | Where {$_.provisioningstatus -ne 'Disabled'}).serviceplanname
                        if ($source) {
                            $source = $source | Where {$sourceIgnore -notcontains $_}
                        }
                        $destarray = Get-UniqueString $dest
                        $sourcearray = Get-UniqueString $source
                        $options2swap = $sourcearray.keys | Where {$destarray.keys -contains $_}
                        $options2swap = $options2swap | % {$destarray[$_]}
                        if ($destOptAdd) {
                            $doa = $destOptAdd | % {
                                if ($f2uOpt[($_).split("*")[1]]) {
                                    $f2uOpt[($_).split("*")[1]]
                                }
                                else {
                                    ($_).split("*")[1]
                                }
                            } 
                            $options2swap += $doa
                        }
                        $completed = $false
                        $retry = 0
                        While ((! $completed) -and ($retry -le 5)) {
                            Try {
                                $retry++
                                $licensesToAssign = Set-SkuChange -addTheOptions -skus $swapDest -options $options2swap
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                                $licensesToAssign = Set-SkuChange -remove -skus $swapSource
                                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
                                Write-Output "$($user.UserPrincipalName) Source: $swapSource Dest: $swapDest Moved Options: $options2swap "
                                $completed = $true
                            }
                            Catch {
                                $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                                $matches[1] -split (' ') | % {$options2swap += ($planId[($_).trim()])}
                            }
                        }
                        if (! $completed) { 
                            Write-Output "Unable to properly add some or all of Options for destination Sku: $swapDest Did not remove Sku: $swapSource "
                            Write-Output "FAILED: $($user.UserPrincipalName) Source: $swapSource Dest: $swapDest Options: $options2swap "
                        }
                    }
                }
            }
            else {
                Write-Output "$($user.UserPrincipalName) does not have source Sku:  $($f2uSku.$swapSource), no changes will be made to this user"
            }
        }
        # Template mode - applies options to any Skus used in this template - will not respect existing Options (wipes them out)
        if ($template) {
            $hashTemplate = @{}
            for ($i = 0; $i -lt $template.count; $i++) {
                if ($template[$i]) {
                    if ($f2uSku[$template[$i].split("*")[0]]) {
                        # FRIENDLY SKU TRACT 
                        if ($hashTemplate.containskey($f2uSku[$template[$i].split("*")[0]])) {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) += @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    EXISTING
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) += @($template[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   FRIENDLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) = @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   FRIENDLY SKU  --  UGLY OPTION    FRESH!
                                $hashTemplate.($f2uSku[$template[$i].split("*")[0]]) = @($template[$i].split("*")[1])
                            }
                        }
                    }
                    # UGLY SKU TRACT 
                    else {
                        if ($hashTemplate.containskey($template[$i].split("*")[0])) {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    EXISTING
                                $hashTemplate.($template[$i].split("*")[0]) += @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    EXISTING
                                $hashTemplate.($template[$i].split("*")[0]) += @($template[$i].split("*")[1])
                            }
                        }
                        else {
                            if ($f2uOpt[$template[$i].split("*")[1]]) {
                                #   UGLY SKU  --  FRIENDLY OPTION    FRESH!
                                $hashTemplate.($template[$i].split("*")[0]) = @($f2uOpt[$template[$i].split("*")[1]])
                            }
                            else {
                                #   UGLY SKU  --  UGLY OPTION    FRESH!
                                $hashTemplate.($template[$i].split("*")[0]) = @($template[$i].split("*")[1])
                            }
                        }
                    }
                }
            }
            $hashTemplate.GetEnumerator() | ForEach-Object { 
                Write-Output "$($user.UserPrincipalName) : $($_.key) : $($_.value) "
                # User already has Sku
                $sKey = $_.key
                if ($sKey -in $userLicense.skupartnumber) {
                    $enabled = [pscustomobject]$_.Value
                    $completed = $false
                    $retry = 0
                    While ((! $completed) -and ($retry -le 5)) {
                        Try {
                            $retry++
                            $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            Write-Output "User has Sku $sKey all options will be disabled except: $enabled "
                            $completed = $true
                        }
                        Catch {
                            $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                            $matches[1] -split (' ') | % {$enabled += ($planId[($_).trim()])}    
                        }
                    }
                    if (! $completed) {
                        Write-Output "$($user.UserPrincipalName) unable to apply options to Sku: $sKey "
                    }
                }
                # User does not have Sku yet
                else {
                    $enabled = [pscustomobject]$_.Value
                    $completed = $false
                    $retry = 0
                    While ((! $completed) -and ($retry -le 5)) {
                        Try {
                            $retry++
                            $licensesToAssign = Set-SkuChange -addTheOptions -skus $sKey -options $enabled
                            Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign -ErrorAction Stop
                            Write-Output "User does not have SKU: $sKey, adding Sku with options: $enabled "
                            $completed = $true
                        }
                        Catch {
                            $_.exception.Message -match "\bplan\(s\)\s+([-0-9a-f]{36})" | Out-Null
                            $matches[1] -split (' ') | % {$enabled += ($planId[($_).trim()])}
                        }
                    }
                    if (! $completed) {
                        Write-Output "$($user.UserPrincipalName) unable to apply options to Sku: $sKey "
                    }
                }
            }
        }
        if ($ReportUserLicenses) {
            (Get-UserLicense -allLicenses -usr $_ | Out-GridView -Title "User License Summary $($_)")
        }
        if ($ReportUserLicensesEnabled) {
            (Get-UserLicense -notDisabled -usr $_ | Out-GridView -Title "User License Summary $($_)")
        }
        if ($ReportUserLicensesDisabled) {
            (Get-UserLicense -onlyDisabled -usr $_ | Out-GridView -Title "User License Summary $($_)")
        }
    }
    End {

    }
}
