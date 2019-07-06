function Get-CloudLicense {
    <#
    .SYNOPSIS
    Report on Office 365 Licenses
    Credit: Original script developed by Alan Byrne.

    .DESCRIPTION
    Report on Office 365 License SKUs and Options assigned to each user

    .PARAMETER DomainFilter
    Reports on licenses for users with an email address with the domain name(s) passed at the pipeline.  One report per domain.
    Without DomainFilter, reports on all licensed users.

    .EXAMPLE
    Get-CloudLicense

    .EXAMPLE
    'contoso.com' | Get-CloudLicense

    .EXAMPLE
    'contoso.com','fabrikam.com' | Get-CloudLicense

    .EXAMPLE
    MACRO TO SEPARATE EACH SKU INTO ITS OWN EXCEL TAB

    #############################################################
    Below is Excel Macro to separate each SKU into its own tab
    ALT + F11 / Right-Click Sheet1 > Insert > Module /
    Copy & Paste text below (from Option Explicit to End Sub) /
    ALT + Q / ALT + F8 / Click Run (large tenants take some time)
    #############################################################


        Option Explicit
    Sub createsheetabs()
        Application.ScreenUpdating = False
        Dim ws As Worksheet, lrow As Long, wk As Worksheet
        Dim ws1 As Worksheet
        Dim i As Long
        Dim rwIn As Long, rwOut As Long
        Dim EmptyCount As Integer

        Set ws = ActiveSheet
        For Each wk In ActiveWorkbook.Worksheets
            Application.DisplayAlerts = False
            If wk.Name <> ws.Name Then
                wk.Delete
            End If
            Application.DisplayAlerts = True
        Next wk
        lrow = ws.Cells(Cells.Rows.Count, "A").End(xlUp).Row
        rwIn = 1
        While rwIn < lrow
            If InStr(1, ws.Range("C" & rwIn), "AccountSku", vbTextCompare) > 0 And InStr(1, ws.Range("C" & rwIn + 1), "AccountSku", vbTextCompare) = 0 Then
                'Make sheet
                Sheets.Add after:=Sheets(Sheets.Count)
                Set ws1 = ActiveSheet
                If ws.Range("C" & rwIn + 1) = "" Then
                    EmptyCount = EmptyCount + 1
                    ws1.Name = "Empty" & EmptyCount
                Else
                    ws1.Name = Left(ws.Range("C" & rwIn + 1), 25)
                End If
                ws.Range("C" & rwIn).EntireRow.Copy ws1.Range("a1")
                rwOut = 1
                i = 0
                'Add data
                While InStr(1, ws.Range("C" & rwIn + 1), "AccountSku", vbTextCompare) = 0 And rwIn < lrow
                    rwIn = rwIn + 1
                    rwOut = rwOut + 1
                    ws.Range("C" & rwIn).EntireRow.Copy ws1.Range("A" & rwOut)
                    i = i + 1
                Wend
                ws1.Cells.EntireColumn.AutoFit
                ws1.Name = ws1.Name & "-" & i
            End If
            rwIn = rwIn + 1
        Wend
        Application.ScreenUpdating = True
    End Sub

    #>

    Param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $false)]
        [string] $DomainFilter

    )

    Begin {


    }
    Process {
        # Define Hashtables for lookup
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
            "YAMMER_MIDSIZE"                     = "Yammer Midsize"
        }

        # The Output will be written to this file in the current working directory
        if ($DomainFilter) {
            $LogFile = ($(get-date -Format yyyy-MM-dd_HH-mm-ss) + "-" + $DomainFilter + "-licenses.csv")
        }
        else {
            $LogFile = ($(get-date -Format yyyy-MM-dd_HH-mm-ss) + "-licenses.csv")
        }

        # Get a list of all Licenses that exist within the tenant
        $licensetype = Get-MsolAccountSku # | Where {$_.SkuPartNumber -eq "STANDARDWOFFPACK_IW_STUDENT"}
        # $licensetype = Get-MsolAccountSku | Where {$_.AccountSkuId -eq "TENANT:ENTERPRISEPACK"}

        # Loop through all License types found in the tenant
        foreach ($license in $licensetype) {

            # Build and write the Header for the CSV file
            $headerstring = "DisplayName,UserPrincipalName,AccountSku"

            foreach ($row in $($license.ServiceStatus)) {

                # Build header string
                switch -wildcard ($($row.ServicePlan.servicename)) {
                    "AAD_PREMIUM" { $thisLicense = "Azure Active Directory Premium Plan 1" }
                    "AAD_PREMIUM_P2" { $thisLicense = "Azure Active Directory Premium P2" }
                    "IT_ACADEMY_AD" { $thisLicense = "Microsoft Imagine Academy" }
                    "ADALLOM_S_O365" { $thisLicense = "Office 365 Advanced Security Management" }
                    "ADALLOM_S_STANDALONE" { $thisLicense = "Microsoft Cloud App Security" }
                    "ATP_ENTERPRISE" { $thisLicense = "Exchange Online Advanced Threat Protection" }
                    "BI_AZURE_P0" { $thisLicense = "Power BI (free)" }
                    "BI_AZURE_P1" { $thisLicense = "Power BI Reporting and Analytics" }
                    "BI_AZURE_P2" { $thisLicense = "Power BI Pro" }
                    "CRMIUR" { $thisLicense = "CRM for Partners" }
                    "CRMSTANDARD" { $thisLicense = "CRM Online" }
                    "CRMSTORAGE" { $thisLicense = "Microsoft Dynamics CRM Online Additional Storage" }
                    "CRMTESTINSTANCE" { $thisLicense = "CRM Test Instance" }
                    "Deskless" { $thisLicense = "Microsoft StaffHub" }
                    "DESKLESSPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan K1) for Government" }
                    "DESKLESSWOFFPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan K2) for Government" }
                    "ENTERPRISEPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan G3) for Government" }
                    "ENTERPRISEWITHSCAL_GOV" { $thisLicense = "Microsoft Office 365 (Plan G4) for Government" }
                    "EOP_ENTERPRISE" { $thisLicense = "Exchange Online Protection" }
                    "EOP_ENTERPRISE_FACULTY" { $thisLicense = "Exchange Online Protection for Faculty" }
                    "EQUIVIO_ANALYTICS" { $thisLicense = "Office 365 Advanced eDiscovery" }
                    "EXCHANGE_ANALYTICS" { $thisLicense = "Microsoft MyAnalytics" }
                    "EXCHANGE_S_ARCHIVE_ADDON_GOV" { $thisLicense = "Exchange Online Archiving Govt" }
                    "EXCHANGE_S_DESKLESS" { $thisLicense = "Exchange Online Kiosk" }
                    "EXCHANGE_S_DESKLESS_GOV" { $thisLicense = "Exchange Kiosk" }
                    "EXCHANGE_S_ENTERPRISE" { $thisLicense = "Exchange Online (Plan 2) Ent" }
                    "EXCHANGE_S_ENTERPRISE_GOV" { $thisLicense = "Exchange Plan 2G" }
                    "EXCHANGE_S_FOUNDATION" { $thisLicense = "Exchange Foundation for certain SKUs" }
                    "EXCHANGE_S_STANDARD" { $thisLicense = "Exchange Online (Plan 2)" }
                    "EXCHANGE_S_STANDARD_MIDMARKET" { $thisLicense = "Exchange Online (Plan 1)" }
                    "EXCHANGEARCHIVE" { $thisLicense = "Exchange Online Archiving" }
                    "EXCHANGEENTERPRISE_GOV" { $thisLicense = "Microsoft Office 365 Exchange Online (Plan 2) only for Government" }
                    "EXCHANGESTANDARD_GOV" { $thisLicense = "Microsoft Office 365 Exchange Online (Plan 1) only for Government" }
                    "EXCHANGESTANDARD_STUDENT" { $thisLicense = "Exchange Online (Plan 1) for Students" }
                    "EXCHANGETELCO" { $thisLicense = "Exchange Online POP" }
                    "FLOW_O365_P2" { $thisLicense = "Flow" }
                    "FLOW_O365_P3" { $thisLicense = "Flow for Office 365" }
                    "FORMS_PLAN_E3" { $thisLicense = "Microsoft Forms (Plan E3)" }
                    "FORMS_PLAN_E5" { $thisLicense = "Microsoft Forms (Plan E5)" }
                    "INTUNE_A" { $thisLicense = "Intune for Office 365" }
                    "INTUNE_O365" { $thisLicense = "Mobile Device Management for Office 365" }
                    "LITEPACK" { $thisLicense = "Office 365 (Plan P1)" }
                    "LOCKBOX_ENTERPRISE" { $thisLicense = "Customer Lockbox" }
                    "MCOEV" { $thisLicense = "Skype for Business Cloud PBX" }
                    "MCOMEETADV" { $thisLicense = "Skype for Business PSTN Conferencing" }
                    "MCOSTANDARD" { $thisLicense = "Skype for Business Online (Plan 2)" }
                    "MCOSTANDARD_GOV" { $thisLicense = "Lync Plan 2G" }
                    "MCOSTANDARD_MIDMARKET" { $thisLicense = "Lync Online (Plan 1)" }
                    "MCVOICECONF" { $thisLicense = "Lync Online (Plan 3)" }
                    "MDM_SALES_COLLABORATION" { $thisLicense = "Microsoft Dynamics Marketing Sales Collaboration" }
                    "MFA_PREMIUM" { $thisLicense = "Azure Multi-Factor Authentication" }
                    "MICROSOFT_BUSINESS_CENTER" { $thisLicense = "Microsoft Business Center" }
                    "MINECRAFT_EDUCATION_EDITION" { $thisLicense = "Minecraft Education Edition Faculty" }
                    "NBPROFESSIONALFORCRM" { $thisLicense = "Microsoft Social Listening Professional" }
                    "OFFICE_FORMS_PLAN_2" { $thisLicense = "Microsoft Forms (Plan 2)" }
                    "OFFICESUBSCRIPTION" { $thisLicense = "Office 365 ProPlus" }
                    "OFFICESUBSCRIPTION_GOV" { $thisLicense = "Office ProPlus" }
                    "OFFICESUBSCRIPTION_STUDENT" { $thisLicense = "Office ProPlus Student Benefit" }
                    "ONEDRIVESTANDARD" { $thisLicense = "OneDrive" }
                    "POWERAPPS_O365_P2" { $thisLicense = "PowerApps" }
                    "POWERAPPS_O365_P3" { $thisLicense = "PowerApps for Office 365" }
                    "PROJECT_CLIENT_SUBSCRIPTION" { $thisLicense = "Project Pro for Office 365" }
                    "PROJECT_ESSENTIALS" { $thisLicense = "Project Lite" }
                    "PROJECTONLINE_PLAN_1" { $thisLicense = "Project Online (Plan 1)" }
                    "PROJECTONLINE_PLAN_2" { $thisLicense = "Project Online (Plan 2)" }
                    "PROJECTWORKMANAGEMENT" { $thisLicense = "Microsoft Planner" }
                    "RMS_S_ENTERPRISE" { $thisLicense = "Azure Rights Management" }
                    "RMS_S_ENTERPRISE_GOV" { $thisLicense = "Windows Azure Active Directory Rights Management" }
                    "RMS_S_PREMIUM" { $thisLicense = "Azure Information Protection Plan 1" }
                    "RMS_S_PREMIUM2" { $thisLicense = "Azure Information Protection Premium P2" }
                    "SCHOOL_DATA_SYNC_P1" { $thisLicense = "School Data Sync (Plan 1)" }
                    "SHAREPOINT_PROJECT" { $thisLicense = "SharePoint Online (Plan 2) Project" }
                    "SHAREPOINT_PROJECT_EDU" { $thisLicense = "Project Online Service for Education" }
                    "SHAREPOINTDESKLESS" { $thisLicense = "SharePoint Online Kiosk" }
                    "SHAREPOINTDESKLESS_GOV" { $thisLicense = "SharePoint Online Kiosk Gov" }
                    "SHAREPOINTENTERPRISE" { $thisLicense = "SharePoint Online (Plan 2)" }
                    "SHAREPOINTENTERPRISE_EDU" { $thisLicense = "SharePoint Plan 2 for EDU" }
                    "SHAREPOINTENTERPRISE_GOV" { $thisLicense = "SharePoint Plan 2G" }
                    "SHAREPOINTENTERPRISE_MIDMARKET" { $thisLicense = "SharePoint Online (Plan 1)" }
                    "SHAREPOINTPARTNER" { $thisLicense = "SharePoint Online Partner Access" }
                    "SHAREPOINTSTANDARD_EDU" { $thisLicense = "SharePoint Plan 1 for EDU" }
                    "SHAREPOINTSTORAGE" { $thisLicense = "SharePoint Online Storage" }
                    "SHAREPOINTWAC" { $thisLicense = "Office Online" }
                    "SHAREPOINTWAC_EDU" { $thisLicense = "Office Online for Education" }
                    "SHAREPOINTWAC_GOV" { $thisLicense = "Office Online for Government" }
                    "SQL_IS_SSIM" { $thisLicense = "Power BI Information Services" }
                    "STANDARDPACK" { $thisLicense = "Microsoft Office 365 (Plan E1)" }
                    "STANDARDPACK_FACULTY" { $thisLicense = "Microsoft Office 365 (Plan A1) for Faculty" }
                    "STANDARDPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan G1) for Government" }
                    "STANDARDPACK_STUDENT" { $thisLicense = "Microsoft Office 365 (Plan A1) for Students" }
                    "STANDARDWOFFPACK" { $thisLicense = "Microsoft Office 365 (Plan E2)" }
                    "STANDARDWOFFPACK_FACULTY" { $thisLicense = "Office 365 Education E1 for Faculty" }
                    "STANDARDWOFFPACK_GOV" { $thisLicense = "Microsoft Office 365 (Plan G2) for Government" }
                    "STANDARDWOFFPACK_IW_FACULTY" { $thisLicense = "Office 365 Education for Faculty" }
                    "STANDARDWOFFPACK_IW_STUDENT" { $thisLicense = "Office 365 Education for Students" }
                    "STANDARDWOFFPACK_STUDENT" { $thisLicense = "Microsoft Office 365 (Plan A2) for Students" }
                    "STREAM_O365_E3" { $thisLicense = "Microsoft Stream for O365 E3 SKU" }
                    "STREAM_O365_E5" { $thisLicense = "Microsoft Stream for O365 E5 SKU" }
                    "SWAY" { $thisLicense = "Sway" }
                    "TEAMS1" { $thisLicense = "Microsoft Teams" }
                    "THREAT_INTELLIGENCE" { $thisLicense = "Office 365 Threat Intelligence" }
                    "VISIO_CLIENT_SUBSCRIPTION" { $thisLicense = "Visio Pro for Office 365 Subscription" }
                    "VISIOCLIENT" { $thisLicense = "Visio Pro for Office 365" }
                    "WACONEDRIVESTANDARD" { $thisLicense = "OneDrive Pack" }
                    "WIN10_PRO_ENT_SUB" { $thisLicense = "Windows 10 Enterprise E3" }
                    "YAMMER_EDU" { $thisLicense = "Yammer for Academic" }
                    "YAMMER_ENTERPRISE" { $thisLicense = "Yammer Enterprise" }
                    "YAMMER_MIDSIZE" { $thisLicense = "Yammer" }

                    default { $thisLicense = $row.ServicePlan.servicename }
                }

                $headerstring = ($headerstring + "," + $thisLicense)
            }
            Out-File -FilePath $LogFile -InputObject $headerstring -Encoding UTF8 -append
            write-host ("Gathering users with the following subscription: " + $license.accountskuid)
            If ($DomainFilter) {
                $users = Get-MsolUser -all -Domain $DomainFilter | where { $_.isLicensed -eq "True" }
            }
            else {
                $users = Get-MsolUser -all | where { $_.isLicensed -eq "True" }
            }
            $skuid = $license.accountskuid
            foreach ($user in $users) {
                $userLicenses = $user.Licenses
                for ($i = 0; $i -lt $($userLicenses.count); $i++) {
                    $userSkuId = $userLicenses[$i].AccountSkuId

                    if ($userSkuId -eq $skuid) {
                        write-host ("Processing " + $user.displayname)
                        if ($u2fSku.Item($userLicenses[$i].AccountSku.SkuPartNumber)) {
                            $datastring = ("`"" + $user.displayname + "`"" + "," + $user.userprincipalname + "," + $u2fSku.Item($userLicenses[$i].AccountSku.SkuPartNumber))
                        }
                        else {
                            $datastring = ("`"" + $user.displayname + "`"" + "," + $user.userprincipalname + "," + ($userLicenses[$i].AccountSku.SkuPartNumber))
                        }

                        foreach ($row in $($userLicenses[$i].servicestatus)) {
                            # Build data string
                            $datastring = ($datastring + "," + $($row.provisioningstatus))
                        }
                        Out-File -FilePath $LogFile -InputObject $datastring -Encoding UTF8 -append
                    }
                }
            }
        }
        write-host ("Script Completed.  Results available in " + $LogFile)
    }
    End {

    }
}
