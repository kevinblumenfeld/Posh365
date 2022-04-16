function Test-MXHandler {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    if ($DomainData.MX -eq $null) { return }

    $lowestPreferenceMX = $DomainData.MX | Sort-Object -Property Preference | Select-Object -First 1 -ExpandProperty NameExchange -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    switch -Wildcard ($lowestPreferenceMX) {
        'inbound-smtp.*.amazonaws.com' { $determination = "Amazon SES" }
        'aspmx*google.com' { $determination = "Google" }
        'au*mimecast*' { $determination = "Mimecast (AU)" }
        '*barracudanetworks.com' { $determination = "Barracuda ESS" }
        '*fireeyecloud.com' { $determination = "FireEye Email Security Cloud" }
        '*.eo.outlook.com' { $determination = "Microsoft Exchange Online" }
        '*eu-central*.sophos.com' { $determination = "Sophos (Germany)" }
        'eu*mimecast*' { $determination = "Mimecast (EU)" }
        '*eu-west*.sophos.com' { $determination = "Sophos (Ireland)" }
        '*.firstcloudsecurity.net' { $determination = "FirstWave (AU)" }
        '*firstwave.com.au' { $determination = "FirstWave (AU)" }
        '*in.mailcontrol.com' { $determination = "Forcepoint (Formerly Websense)" }
        '*iphmx*' { $determination = "Cisco Email Security (Formerly IronPort Cloud)" }
        '*.itoncloud.com' { $determination = "ITonCloud (AU)" }
        '*mailguard*' { $determination = "Mailguard (AU)" }
        '*.mailgun.org' { $determination = "Mailgun" }
        '*.server-mail.com' { $determination = "Melbourne IT" }
        '*mail.protection.outlook.com*' { $determination = "Microsoft Exchange Online" }
        '*messagelabs*' { $determination = "Symantec.Cloud" }
        '*.msng.telstra.com.au' { $determination = "Telstra (AU)" }
        '*mxthunder*' { $determination = "SpamHero" }
        '*mpmailmx*' { $determination = "Manage Protect (AU/NZ)" }
        '*nexon.com.au*' { $determination = "Nexon (AU MSP)" }
        '*trendmicro*' { $determination = "Trend Micro" }
        '*.secureintellicentre.net.au' { $determination = "Macquarie Government (AU)" }
        'seg.trustwave.com' { $determination = "Trustwave Secure Email Gateway Cloud" }
        '*.sendgrid.net' { $determination = "SendGrid" }
        '*.mtaroutes.com' { $determination = "Solarwinds Mail Assure" }
        '*.sge.net' { $determination = "Verizon Business (ex CyberTrust)" }
        '*.spamh.com' { $determination = "Greenview Data SpamStopsHere" }
        '*pphosted*' { $determination = "Proofpoint" }
        '*ppe-hosted*' { $determination = "Proofpoint" }
        '*.emailsrvr.com' { $determination = "RackSpace" }
        '*securence*' { $determination = "Securence" }
        '*us-west*.sophos.com' { $determination = "Sophos (US West)" }
        '*us-east*.sophos.com' { $determination = "Sophos (US East)" }
        '*.mailbox.org' { $determination = "Mailbox.Org (Germany)" }
        '*.uberspace.de' { $determination = "Uberspace (Germany)" }
        '*.expurgate.de' { $determination = "Cyren/eXpurgate (Germany)" }
        "*$($domainData.SOA.Name)" { $determination = "Self-Hosted" }
        "" { $determination = "NO MX RECORD FOUND" }

        $null { $determination = "NO MX RECORD FOUND" }
        Default { $determination = "Other/Undetermined" }
    }

    return $determination
}
