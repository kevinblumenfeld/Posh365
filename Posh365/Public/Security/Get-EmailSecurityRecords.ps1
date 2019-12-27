function Get-EmailSecurityRecords {
    <#
    .DESCRIPTION
        All credit to:

        AUTHOR:	 Daniel Streefkerk
        WWW:	 https://daniel.streefkerkonline.com
        Twitter: @dstreefkerk

        This function that he put together is amazing!!
        Please check out his blog - also fantastic.

        I removed [ordered] type and used [pscustomobject] instead.

        I also added in kitterman spf validation and detail (if fails)

        Here is Daniel's description...

        A quick and dirty script to be used to automate the collection of
        publicly-available email-related records

        For example: MX, SPF, DMARC, MTA-STS records.

        It'll also try to make a determination about who's handling mail flow, and whether the domain
        is hosted on Exchange Online (sometimes ExOnline tenants pass their mail through filtering
        services like ProofPoint, Mimecast, etc)

        If the domain is hosted on Exchange Online, it'll also check whether DKIM is configured,
        and determine whether the domain is federated or not.

    .SYNOPSIS
        Perform email-based reconnaissance on a single domain, or a collection of domains

    .PARAMETER DomainName
        PrimarySmtpAddress Domain to check

    .EXAMPLE
       Get-EmailSecurityRecords -DomainName contoso.com

    .EXAMPLE
       (Import-Csv c:\scripts\domains.csv).DomainName | Get-EmailSecurityRecords
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $EmailDomain
    )

    begin {
    }
    process {
        foreach ($domain in $EmailDomain) {
            Write-Verbose "Testing domain:`t$Domain"
            if ([string]::IsNullOrEmpty($domain)) { continue }
            # Attempt to find the SOA domain record, skip the domain if we can't locate one DNS
            try {
                $null = Resolve-DnsName -Name $domain -Type SOA -ErrorAction Stop
                Write-Verbose "Successfully located SOA record for $domain"
            }
            catch {
                Write-Verbose "Failed to locate SOA record for $domain"
                continue
            }
            # Collect data
            $ErrorActionPreference = 'SilentlyContinue'
            $dataCollection = [PSCustomObject]@{
                DMARC                  = Resolve-DnsName -Name "_dmarc.$($domain)" -Type TXT -Server 8.8.8.8
                MX                     = Resolve-DnsName -Name $domain -Type MX -Server 8.8.8.8
                MTASTS                 = Get-MTASTSDetails -DomainName $domain -Server 8.8.8.8
                MSOID                  = Resolve-DnsName "msoid.$($domain)" -Server 8.8.8.8
                TXT                    = Resolve-DnsName $domain -Type TXT -Server 8.8.8.8
                ENTERPRISEREGISTRATION = Resolve-DnsName -Name "enterpriseregistration.$domain" -Type CNAME -Server 8.8.8.8
                AUTODISCOVER           = Resolve-DnsName -Name "autodiscover.$domain" -Type CNAME -Server 8.8.8.8
                SOA                    = Resolve-DnsName -Type SOA -Name $domain -Server 8.8.8.8
                NS                     = Resolve-DnsName $domain -Type NS -Server 8.8.8.8
                O365DKIM               = [PSCustomObject]@{
                    SELECTOR1 = Resolve-DnsName "selector1._domainkey.$domain" -Type CNAME -Server 8.8.8.8
                    SELECTOR2 = Resolve-DnsName "selector2._domainkey.$domain" -Type CNAME -Server 8.8.8.8
                }
                FEDERATION             = Get-DomainFederationDataFromO365 -DomainName $domain
                DNSSEC                 = Get-DNSSECDetails -DomainName $domain
            }

            $ErrorActionPreference = 'Continue'
            # Finish collecting data

            # Analyse the collected data
            $SPFResult = Test-SPFRecord $domain
            [PSCustomObject]@{
                'Domain'                      = $domain;
                'MX Records Exist'            = $dataCollection.mx.NameExchange.Count -gt 0
                'MX Provider'                 = Test-MXHandler $dataCollection
                'MX Lowest Preference'        = Get-LowestPreferenceMX $dataCollection
                'SPF Record Exists'           = Test-SpfRecordExists $dataCollection
                'SPF Record'                  = Get-SpfRecordText $dataCollection
                'SPF Mechanism Mode'          = Get-SpfRecordMode $dataCollection
                'SPF Validity'                = $SPFResult.Result
                'SPF Result'                  = $SPFResult.Detail
                'DMARC Record Exists'         = Test-DmarcRecordExists $dataCollection
                'DMARC Record'                = Get-DmarcRecordText $dataCollection
                'DMARC Domain Policy Mode'    = Get-DmarcPolicy $dataCollection
                'DMARC Subdomain Policy Mode' = Get-DmarcSubdomainPolicy $dataCollection
                'O365 Exchange Online'        = Test-ExchangeOnlineDomain $dataCollection
                'O365 Tenant Name'            = Test-O365DomainTenantName $dataCollection
                'O365 DKIM Enabled'           = Test-O365Dkim $dataCollection
                'O365 Federated'              = Test-O365IsFederated $dataCollection
                'O365 Federation Provider'    = Test-O365FederationProvider $dataCollection
                'O365 Federation Hostname'    = Get-O365FederationHostname $dataCollection
                'O365 Federation Brand Name'  = $dataCollection.FEDERATION.FederationBrandName
                'O365/AzureAD Directory ID'   = Test-O365DirectoryID $domain
                'O365/AzureAD is Unmanaged'   = Test-AADIsUnmanaged $dataCollection
                'MTA-STS Record Exists'       = $dataCollection.MTASTS.DNSRecord -ne $null
                'MTA-STS Policy Mode'         = $dataCollection.MTASTS.Mode
                'MTA-STS Allowed MX Hosts'    = $dataCollection.MTASTS.AllowedMX
                'DNS Registrar'               = Test-DnsNameAdministrator $dataCollection
                'DNS Host'                    = Test-DnsHostingProvider $dataCollection
                'DNSSEC DNSKEY Record Exists' = $dataCollection.DNSSEC.DNSKeyExists
                #'ADFS Host' = (Test-AdfsFederationMetadataUrl $domain)
            }
        }
    }
    end { }
}
