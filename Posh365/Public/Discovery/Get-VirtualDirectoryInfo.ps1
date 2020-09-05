function Get-VirtualDirectoryInfo {
    <#
    .SYNOPSIS
    Orginal script created by Michael Van Horenbeeck. Modified to all for Exchange PSRemoting
	This script will create an HTML-report which will gather the URL-information from different virtual directories over different Exchange Servers (currently only Exchange 2010/Exchange 2013)

	.DESCRIPTION
	This script will create an HTML-report which will gather the URL-information from different virtual directories over different Exchange Servers (currently only Exchange 2010/Exchange 2013)
    Connect to Exchange remotely prior to beginning

	.EXAMPLE
    Connect-Exchange EXServer01
    Get-VirtualDirectoryInfo -filepath c:\reports

	This command will create the report in the following directory: C:\Reports

	#>
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        #Specify the report file path
        [Parameter(Mandatory, Position = 0)]
        [Alias("ReportPath")]
        [ValidateNotNullOrEmpty()]
        $Filepath,
        #query AD instead of the IIS metabase

        [Parameter(Position = 1)]
        [Alias("ADPropertiesOnly")]
        [Switch]
        $ADProperties,
        #specify the computername to connect to. Defaults to the local host.

        [Parameter(Position = 2)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Filter = "*"

    )

    try {
        $CurrentServer = (Get-PSSession | Where-Object { $_.State -eq "Opened" }).ComputerName
        $CurrentServerVersion = (Get-ExchangeServer $currentServer).AdminDisplayVersion.toString()
        $Major = [regex]::matches($CurrentServerVersion, '(?<=Version )[^.< ]*').value
        $Minor = [regex]::matches($CurrentServerVersion, '(?<=Version \d{2}.)[^< ]*').value
        $AdminBuild = [regex]::matches($CurrentServerVersion, 'Build\s*([\d.]+)').value

        if (($Major -eq 15) -and ($Minor -eq 1) -and ($AdminBuild -ge 466) -and ($AdminBuild -ge 34)) {
            $servers = @(Get-ExchangeServer | Where-Object {
                    ($_.isClientAccessServer -eq $true) -and
                    ((($_.AdminDisplayVersion).ToString() -like "*15*") -or (($_.AdminDisplayVersion).ToString() -like "*14*")) -and
                    ($_.Name -like $Filter)
                } | Select-Object Name, AdminDisplayVersion, ServerRole, Edition)
            $runVersion = "2016CU2+"
        }
        elseif (($Major -eq 14) -or ($Major -eq 15)) {
            $servers = @(Get-ExchangeServer | Where-Object {
                    $_.ServerRole -like "*ClientAccess*" -and
                    ((($_.AdminDisplayVersion).ToString() -like "*15*") -or (($_.AdminDisplayVersion).ToString() -like "*14*") -and
                        ($_.Name -like $Filter)) } | Select-Object Name, AdminDisplayVersion, ServerRole, Edition)
            $runVersion = "2016CU2-"
        }
    }
    catch {
        Write-Warning "An error occured: could not connect to one or more Exchange servers".
        break
    }
    #Define Version Array

    $Hash = @{
        "14.0.639.21"  = "Microsoft Exchange Server 2010 RTM"
        "14.0.682.1"   = "Update Rollup 1 for Exchange Server 2010"
        "14.0.689.0"   = "Update Rollup 2 for Exchange Server 2010"
        "14.0.694.0"   = "Update Rollup 3 for Exchange Server 2010"
        "14.0.702.1"   = "Update Rollup 4 for Exchange Server 2010"
        "14.1.218.15"  = "Microsoft Exchange Server 2010 SP1"
        "14.1.255.2"   = "Update Rollup 1 for Exchange Server 2010 SP1"
        "14.1.270.1"   = "Update Rollup 2 for Exchange Server 2010 SP1"
        "14.1.289.3"   = "Update Rollup 3 for Exchange Server 2010 SP1"
        "14.1.289.7"   = "Update Rollup 3-v3 for Exchange Server 2010 SP1"
        "14.1.323.1"   = "Update Rollup 4 for Exchange Server 2010 SP1"
        "14.1.323.6"   = "Update Rollup 4-v2 for  Exchange Server 2010 SP1"
        "14.1.339.1"   = "Update Rollup 5 for  Exchange Server 2010 SP1"
        "14.1.355.2"   = "Update Rollup 6 for  Exchange Server 2010 SP1"
        "14.1.421.0"   = "Update Rollup 7 for  Exchange Server 2010 SP1"
        "14.1.421.2"   = "Update Rollup 7-v2 for  Exchange Server 2010 SP1"
        "14.1.421.3"   = "Update Rollup 7-v3 for Exchange Server 2010 SP1"
        "14.1.438.0"   = "Update Rollup 8 for Exchange Server 2010 SP1"
        "14.2.247.5"   = "Microsoft Exchange Server 2010 SP2"
        "14.2.283.3"   = "Update Rollup 1 for Exchange Server 2010 SP2"
        "14.2.298.4"   = "Update Rollup 2 for Exchange Server 2010 SP2"
        "14.2.309.2"   = "Update Rollup 3 for Exchange Server 2010 SP2"
        "14.2.318.2"   = "Update Rollup 4 for Exchange Server 2010 SP2"
        "14.2.318.4"   = "Update Rollup 4-v2 for Exchange Server 2010 SP2"
        "14.2.328.5"   = "Update Rollup 5 for Exchange Server 2010 SP2"
        "14.2.328.10"  = "Update Rollup 5-v2 for Exchange Server 2010 SP2"
        "14.2.342.3"   = "Update Rollup 6 for Exchange Server 2010 SP2"
        "14.2.375.0"   = "Update Rollup 7 for Exchange Server 2010 SP2"
        "14.2.390.3"   = "Update Rollup 8 for Exchange Server 2010 SP2"
        "14.3.123.4"   = "Microsoft Exchange Server 2010 SP3"
        "14.3.146.0"   = "Update Rollup 1 for Exchange Server 2010 SP3"
        "14.3.158.1"   = "Update Rollup 2 for Exchange Server 2010 SP3"
        "14.3.169.1"   = "Update Rollup 3 for Exchange Server 2010 SP3"
        "14.3.174.1"   = "Update Rollup 4 for Exchange Server 2010 SP3"
        "14.3.181.6"   = "Update Rollup 5 for Exchange Server 2010 SP3"
        "14.3.195.1"   = "Update Rollup 6 for Exchange Server 2010 SP3"
        "15.0.620.29"  = "Exchange Server 2013 Cumulative Update 1 (CU1)"
        "15.0.712.22"  = "Exchange Server 2013 Cumulative Update 2 (CU2)"
        "15.0.712.24"  = "Exchange Server 2013 Cumulative Update 2 (CU2-v2)"
        "15.0.775.38"  = "Exchange Server 2013 Cumulative Update 3 (CU3)"
        "15.0.847.32"  = "Exchange Server 2013 Cumulative Update 4 (SP1 - CU4)"
        "15.0.913.22"  = "Exchange Server 2013 Cumulative Update 5 (CU5)"
        "15.0.995.29"  = "Exchange Server 2013 Cumulative Update 6 (CU6)"
        "15.0.1044.25" = "Exchange Server 2013 Cumulative Update 7 (CU7)"
        "15.0.1076.9"  = "Exchange Server 2013 Cumulative Update 8 (CU8)"
        "15.0.1104.5"  = "Exchange Server 2013 Cumulative Update 9 (CU9)"
        "15.0.1130.7"  = "Exchange Server 2013 Cumulative Update 10 (CU10)"
        "15.0.1156.6"  = "Exchange Server 2013 Cumulative Update 11 (CU11)"
        "15.0.1178.4"  = "Exchange Server 2013 Cumulative Update 12 (CU12)"
        "15.0.1210.3"  = "Exchange Server 2013 Cumulative Update 13 (CU13)"
        "15.1.225.42"  = "Exchange Server 2016 RTM"
        "15.1.396.30"  = "Exchange Server 2016 Cumulative Update 1"
        "15.1.466.34"  = "Exchange Server 2016 Cumulative Update 2"
    }

    #HTML headers
    $html += "<html>"
    $html += "<head>"
    $html += "<style type='text/css'>"
    $html += "body {font-family:verdana;font-size:10pt}"
    $html += "H1 {font-family:verdana;font-size:12pt}"
    $html += "table {border:1px solid #000000;font-family:verdana; font-size:10pt;cellspacing:1;cellpadding:0}"
    $html += "tr.color {background-color:#00A2E8;color:#FFFFFF;font-weight:bold}"
    $html += "</style>"
    $html += "</head>"
    $html += "<body>"

    #Report Legend
    $html += "Get-VirtualDirectoryInfo.ps1<br/>"
    $html += "<b>Report generated on: </b>" + (Get-Date).DateTime

    #Add warning that the script pulled only the ADProperties
    if ($ADProperties) {
        $html += "<br/><b><font color='red'>Warning: The script was run using the -ADPropertiesOnly switch and might not show all information</font></b>"
    }
    $html += "<br/><br/>"

    #General Server Info

    $html += "<h1>General Client Access Server Information</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Exchange Version</td><td>Roles</td><td>Edition</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        if ($server.AdminDisplayVersion.Major) {
            $build = [string]$server.AdminDisplayVersion.Major + "." + $server.AdminDisplayVersion.Minor + "." + $server.AdminDisplayVersion.Build + "." + $server.AdminDisplayVersion.Revision
            if ($hash[$build]) {
                $Version = $hash[$build]
            }
        }
        else {
            $version = ($Server).AdminDisplayVersion.toString()
        }

        $html += "<tr>"
        $html += "<td>" + $server.name + "</td>"
        $html += "<td>" + $version + "</td>"
        $html += "<td>" + $server.ServerRole + "</td>"
        $html += "<td>" + $server.Edition + "</td>"
        $html += "</tr>"
    }

    $html += "</table>"

    #Autodiscover
    $html += "<br/><br/>"
    $html += "<h1>Autodiscover</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Internal Uri</td><td>InternalURL</td><td>ExternalUrl</td><td>Auth. (Int.)</td><td>Auth. (Ext.)</td><td>Site Scope</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        Write-Host "Getting Autodiscover URL information for server: " -NoNewLine
        Write-Host "$($server.name)" -ForegroundColor Cyan
        if ($runVersion -eq "2016CU2+") {
            $autodresult = Get-ClientAccessService -Identity $server.name | Select-Object Name, AutodiscoverServiceInternalUri, AutoDiscoverSiteScope
        }
        else {
            $autodresult = Get-ClientAccessServer -Identity $server.name | Select-Object Name, AutodiscoverServiceInternalUri, AutoDiscoverSiteScope
        }

        if ($ADProperties) {
            $autodvirdirresult = Get-AutodiscoverVirtualDirectory -Server $server.name -ADPropertiesOnly | Select-Object InternalUrl, ExternalUrl, InternalAuthenticationMethods, ExternalAuthenticationMethods, WhenChanged
        }
        else {
            $autodvirdirresult = Get-AutodiscoverVirtualDirectory -Server $server.name | Select-Object InternalUrl, ExternalUrl, InternalAuthenticationMethods, ExternalAuthenticationMethods, WhenChanged
        }

        $autodhtml += "<tr>"
        $autodhtml += "<td>" + $autodresult.Name + "</td>"
        $autodhtml += "<td>" + $autodresult.AutodiscoverServiceInternalUri + "</td>"
        $autodhtml += "<td>" + $autodvirdirresult.InternalURL.absoluteURI + "</td>"
        $autodhtml += "<td>" + $autodvirdirresult.ExternalURL.absoluteURI + "</td>"
        $autodhtml += "<td>" + $autodvirdirresult.InternalAuthenticationMethods + "</td>"
        $autodhtml += "<td>" + $autodvirdirresult.ExternalAuthenticationMethods + "</td>"
        $autodhtml += "<td>" + $autodresult.AutoDiscoverSiteScope + "</td>"
        $autodhtml += "<td>" + $autodvirdirresult.WhenChanged + "</td>"
        $autodhtml += "</tr>"

        $autodresult, $autodvirdirresult = $null

    }
    $html += $autodhtml
    $html += "</table>"

    #Outlook Web App (OWA)
    $html += "<br/><br/>"
    $html += "<h1>Outlook Web App (OWA):</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Name</td><td>InternalURL</td><td>ExternalUrl</td><td>Int. Auth.</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        Write-Host "Getting OWA virtual directory information for server: " -NoNewLine
        Write-Host "$($server.name)" -ForegroundColor Cyan
        if ($ADProperties) {
            $owaresult = Get-OWAVirtualDirectory -server $server.name -AdPropertiesOnly | Select-Object Name, Server, InternalUrl, ExternalUrl, WhenChanged, InternalAuthenticationMethods
        }
        else {
            $owaresult = Get-OWAVirtualDirectory -server $server.name | Select-Object Name, Server, InternalUrl, ExternalUrl, WhenChanged, InternalAuthenticationMethods
        }

        $owahtml += "<tr>"
        $owahtml += "<td>" + $owaresult.Server + "</td>"
        $owahtml += "<td>" + $owaresult.Name + "</td>"
        $owahtml += "<td>" + $owaresult.InternalURL.absoluteURI + "</td>"
        $owahtml += "<td>" + $owaresult.ExternalURL.absoluteURI + "</td>"
        $owahtml += "<td>" + $owaresult.InternalAuthenticationMethods + "</td>"
        $owahtml += "<td>" + $owaresult.WhenChanged + "</td>"
        $owahtml += "</tr>"

        $owaresult = $null

    }
    $html += $owahtml
    $html += "</table>"

    #Exchange Control Panel (ECP)
    $html += "<br/><br/>"
    $html += "<h1>Exchange Control Panel (ECP):</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Name</td><td>InternalURL</td><td>ExternalUrl</td><td>Int. Auth.</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        Write-Host "Getting ECP virtual directory information for server: " -NoNewline
        Write-Host "$($server.name)" -ForegroundColor Cyan
        if ($ADProperties) {
            $ecpresult = Get-ECPVirtualDirectory -server $server.name -ADPropertiesOnly | Select-Object Name, Server, InternalUrl, ExternalUrl, WhenChanged, InternalAuthenticationMethods
        }
        else {
            $ecpresult = Get-ECPVirtualDirectory -server $server.name | Select-Object Name, Server, InternalUrl, ExternalUrl, WhenChanged, InternalAuthenticationMethods
        }

        $ecphtml += "<tr.color>"
        $ecphtml += "<td>" + $ecpresult.Server + "</td>"
        $ecphtml += "<td>" + $ecpresult.Name + "</td>"
        $ecphtml += "<td>" + $ecpresult.InternalURL.absoluteURI + "</td>"
        $ecphtml += "<td>" + $ecpresult.ExternalURL.absoluteURI + "</td>"
        $ecphtml += "<td>" + $ecpresult.InternalAuthenticationMethods + "</td>"
        $ecphtml += "<td>" + $ecpresult.WhenChanged + "</td>"
        $ecphtml += "</tr>"

        Clear-Variable -Name ecpresult
    }
    $html += $ecphtml
    $html += "</table>"

    #Outlook Anywhere
    $html += "<br/><br/>"
    $html += "<h1>Outlook Anywhere:</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Internal Hostname</td><td>External Hostname</td><td>Auth.(Int.)</td><td>Auth. (Ext.)</td><td>Auth. IIS</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        Write-Host "Getting Outlook Anywhere information for server: " -NoNewLine
        Write-Host "$($server.name)" -ForegroundColor Cyan
        if ($ADProperties) {
            $oaresult = Get-OutlookAnywhere -server $server.name -ADPropertiesOnly | Select-Object Name, Server, InternalHostname, ExternalHostname, ExternalClientAuthenticationMethod, InternalClientAuthenticationMethod, IISAuthenticationMethods, WhenChanged
        }
        else {
            $oaresult = Get-OutlookAnywhere -server $server.name | Select-Object Name, Server, InternalHostname, ExternalHostname, ExternalClientAuthenticationMethod, InternalClientAuthenticationMethod, IISAuthenticationMethods, WhenChanged
        }

        if ($null -eq $oaresult) {

            $oahtml += "<tr.color>"
            $oahtml += "<td>" + $server.name + "</td>"
            $oahtml += "<td colspan='6'>"
            $oahtml += "Outlook Anywhere isn't enabled."
            $oahtml += "</td>"
            $oahtml += "</tr>"

        }
        else {
            $oahtml += "<tr.color>"
            $oahtml += "<td>" + $oaresult.Server + "</td>"
            $oahtml += "<td>" + $oaresult.InternalHostname + "</td>"
            $oahtml += "<td>" + $oaresult.ExternalHostname + "</td>"
            $oahtml += "<td>" + $oaresult.InternalClientAuthenticationMethod + "</td>"
            $oahtml += "<td>" + $oaresult.ExternalClientAuthenticationMethod + "</td>"
            $oahtml += "<td>" + $oaresult.IISAuthenticationMethods + "</td>"
            $oahtml += "<td>" + $oaresult.WhenChanged + "</td>"
            $oahtml += "</tr>"
        }

        $oaresult = $null
    }
    $html += $oahtml
    $html += "</table>"

    #MAPI/HTTP
    $html += "<br/><br/>"
    $html += "<h1>MAPI/HTTP:</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Internal URL</td><td>External URL</td><td>Auth.(Int.)</td><td>Auth. (Ext.)</td><td>Auth. IIS</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        $MapiServer = (Get-ExchangeServer $Server.name).AdminDisplayVersion.toString()
        $MapiMajor = [regex]::matches($MapiServer, '(?<=Version )[^.< ]*').value
        $MapiMinor = [regex]::matches($MapiServer, '(?<=Version \d{2}.)[^< ]*').value
        $MapiAdminBuild = [regex]::matches($MapiServer, 'Build\s*([\d.]+)').value
        if (($MapiMajor -eq "15" -and $MapiAdminBuild -ge "847") -or ($MapiMajor -eq "15" -and $MapiMinor -eq "1")) {
            Write-Host "Getting MAPI/HTTP Information for server: " -NoNewLine
            Write-Host "$($server.name)" -ForegroundColor Cyan
            if ($ADProperties) {
                $mapiresult = Get-MapiVirtualDirectory -server $server.name -ADPropertiesOnly | Select-Object Name, Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, IISAuthenticationMethods, WhenChanged
            }
            else {
                $mapiresult = Get-MapiVirtualDirectory -server $server.name | Select-Object Name, Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, IISAuthenticationMethods, WhenChanged
            }

            $mapihtml += "<tr.color>"
            $mapihtml += "<td>" + $mapiresult.Server + "</td>"
            $mapihtml += "<td>" + $mapiresult.InternalUrl + "</td>"
            $mapihtml += "<td>" + $mapiresult.ExternalUrl + "</td>"
            $mapihtml += "<td>" + $mapiresult.InternalAuthenticationMethods + "</td>"
            $mapihtml += "<td>" + $mapiresult.ExternalAuthenticationMethods + "</td>"
            $mapihtml += "<td>" + $mapiresult.IISAuthenticationMethods + "</td>"
            $mapihtml += "<td>" + $mapiresult.WhenChanged + "</td>"
            $mapihtml += "</tr>"
        }
        else {

            $mapihtml += "<tr.color>"
            $mapihtml += "<td>" + $server.name + "</td>"
            $mapihtml += "<td colspan='6'>"
            $mapihtml += "Server isn't running Exchange 2013 SP1 or later."
            $mapihtml += "</td>"
            $mapihtml += "</tr>"
        }

        $oaresult = $null
    }
    $html += $mapihtml
    $html += "</table>"

    #Offline Address Book (OAB)
    $html += "<br/><br/>"
    $html += "<h1>Offline Address Book (OAB):</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>OABs</td><td>Internal URL</td><td>External Url</td><td>Auth.(Int.)</td><td>Auth. (Ext.)</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        Write-Host "Getting Offline Address Book information for server: " -NoNewLine
        Write-Host "$($server.name)" -ForegroundColor Cyan
        if ($ADProperties) {
            $oabresult = Get-OABVirtualDirectory -server $server.name -ADPropertiesOnly | Select-Object Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, OfflineAddressBooks, WhenChanged
        }
        else {
            $oabresult = Get-OABVirtualDirectory -server $server.name | Select-Object Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, OfflineAddressBooks, WhenChanged
        }

        $oabhtml += "<tr.color>"
        $oabhtml += "<td>" + $oabresult.Server + "</td>"
        $oabhtml += "<td>" + $oabresult.OfflineAddressBooks + "</td>"
        $oabhtml += "<td>" + $oabresult.InternalURL.absoluteURI + "</td>"
        $oabhtml += "<td>" + $oabresult.ExternalURL.absoluteURI + "</td>"
        $oabhtml += "<td>" + $oabresult.InternalAuthenticationMethods + "</td>"
        $oabhtml += "<td>" + $oabresult.ExternalAuthenticationMethods + "</td>"
        $oabhtml += "<td>" + $oabresult.WhenChanged + "</td>"
        $oabhtml += "</tr>"

        $oabresult = $null
    }
    $html += $oabhtml
    $html += "</table>"

    #ActiveSync (EAS)
    $html += "<br/><br/>"
    $html += "<h1>ActiveSync (EAS):</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Internal URL</td><td>External Url</td><td>Auth. (Ext.)</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        Write-Host "Getting ActiveSync information for server: " -NoNewLine
        Write-Host "$($server.name)" -ForegroundColor Cyan
        if ($ADProperties) {
            $easresult = Get-ActiveSyncVirtualDirectory -server $server.name -ADPropertiesOnly | Select-Object Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, WhenChanged
        }
        else {
            $easresult = Get-ActiveSyncVirtualDirectory -server $server.name | Select-Object Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, WhenChanged
        }


        $eashtml += "<tr.color>"
        $eashtml += "<td>" + $easresult.Server + "</td>"
        $eashtml += "<td>" + $easresult.InternalURL.absoluteUri + "</td>"
        $eashtml += "<td>" + $easresult.ExternalURL.absoluteUri + "</td>"
        $eashtml += "<td>" + $easresult.ExternalAuthenticationMethods + "</td>"
        $eashtml += "<td>" + $easresult.WhenChanged + "</td>"
        $eashtml += "</tr>"

        $easresult = $null
    }
    $html += $eashtml
    $html += "</table>"

    #Exchange Web Services (EWS)
    $html += "<br/><br/>"
    $html += "<h1>Exchange Web Services(EWS):</h1>"
    $html += "<table border='1'>"
    $html += "<tr class='color'>"
    $html += "<td>Server</td><td>Internal URL</td><td>External Url</td><td>Auth. (Int.)</td><td>Auth. (Ext.)</td><td>MRS Proxy Enabled</td><td>Last modified on:</td>"
    $html += "</tr>"

    foreach ($server in $servers) {
        Write-Host "Getting Web Services information for server: " -NoNewLine
        Write-Host "$($server.name)" -ForegroundColor Cyan
        if ($ADProperties) {
            $ewsresult = Get-WebServicesVirtualDirectory -server $server.name -ADPropertiesOnly | Select-Object Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, MRSProxyEnabled, WhenChanged
        }
        else {
            $ewsresult = Get-WebServicesVirtualDirectory -server $server.name | Select-Object Server, InternalUrl, ExternalUrl, ExternalAuthenticationMethods, InternalAuthenticationMethods, MRSProxyEnabled, WhenChanged
        }

        $ewshtml += "<tr.color>"
        $ewshtml += "<td>" + $ewsresult.Server + "</td>"
        $ewshtml += "<td>" + $ewsresult.InternalURL.absoluteUri + "</td>"
        $ewshtml += "<td>" + $ewsresult.ExternalURL.absoluteUri + "</td>"
        $ewshtml += "<td>" + $ewsresult.InternalAuthenticationMethods + "</td>"
        $ewshtml += "<td>" + $ewsresult.ExternalAuthenticationMethods + "</td>"
        $ewshtml += "<td>" + $ewsresult.MRSProxyEnabled + "</td>"
        $ewshtml += "<td>" + $ewsresult.WhenChanged + "</td>"
        $ewshtml += "</tr>"

        $easresult = $null
    }
    $html += $ewshtml
    $html += "</table>"

    try {
        $html | Out-File $filepath"\virdirinfo_"$(Get-Date -Format d-MM-yyyy_HH\hmm\mss\s)".html"
        Write-Host "Successfully created"$filepath"\virdirinfo_"$(Get-Date -Format d-MM-yyyy_HH\hmm\mss\s)".html" -ForegroundColor Green
    }
    catch {
        Write-Warning "Couldn't save "$filepath"\virdirinfo_"$(Get-Date -Format d-MM-yyyy_HH\hmm\mss\s)".html"
    }

    $Owahtml, $Owaresult, $html, $servers = $null

}