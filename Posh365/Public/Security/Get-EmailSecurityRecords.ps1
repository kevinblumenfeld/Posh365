function Get-EmailSecurityRecords {
    <#
    .DESCRIPTION
        All credit to:
        AUTHOR:	 Daniel Streefkerk
        WWW:	 https://daniel.streefkerkonline.com
        Twitter: @dstreefkerk

        This function that he put together is amazing.

        I removed ordered type and used pscustomobject instead.

        Here is Daniel's description

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
        Email domain to check

    .EXAMPLE
        .\Invoke-EmailRecon.ps1 -EmailDomain "contoso.com"

        Retrieve email details for the domain contoso.com

    .EXAMPLE
        .\Invoke-EmailRecon.ps1 -EmailDomain "contoso.com",'fabrikam.com'

        Retrieve email details for multiple domains

    .EXAMPLE
        .\Invoke-EmailRecon.ps1 -EmailDomain "contoso.com",'fabrikam.com' | Format-Table -AutoSize

        Retrieve email details for multiple domains, and format the results in a table

    .EXAMPLE
        Get-Content C:\temp\domains.txt | .\Invoke-EmailRecon.ps1 | Format-Table -AutoSize

        Get a list of domains from a text file (single domain per line), retrieve the details, and format the results into a table

    .EXAMPLE
        Get-Content C:\temp\domains.txt | .\Invoke-EmailRecon.ps1 | Export-Csv c:\temp\domains.csv -NoTypeInformation

        Get a list of domains from a text file (single domain per line), retrieve the details, and export the results to a CSV file

    .EXAMPLE
        Import-Csv C:\temp\companies.csv | Select-Object -ExpandProperty Email_Domain | C:\Scripts\Invoke-EmailRecon.ps1 | Out-GridView

        Get a list of domains from a CSV file that contains a column named 'Email_Domain, run our process across each one of them, and output the results to a GridView GUI control

    .INPUTS
        System.String

    .OUTPUTS
        Custom PowerShell object containing email-related information collected from public DNS records

    .NOTES

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
            if ([string]::IsNullOrEmpty($domain)) { continue }
            # Attempt to find the SOA domain record, skip the domain if we can't locate one DNS
            try {
                Resolve-DnsName -Name $domain -Type SOA -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Verbose "Failed to locate SOA record for $domain"
                continue
            }
            # Collect data
            $ErrorActionPreference = 'SilentlyContinue'
            $dataCollection = [PSCustomObject]@{
                DMARC                  = Resolve-DnsName -Name "_dmarc.$($domain)" -Type TXT
                MX                     = Resolve-DnsName -Name $domain -Type MX
                MTASTS                 = Get-MTASTSDetails -DomainName $domain
                MSOID                  = Resolve-DnsName "msoid.$($domain)"
                TXT                    = Resolve-DnsName $domain -Type TXT
                ENTERPRISEREGISTRATION = Resolve-DnsName -Name "enterpriseregistration.$domain" -Type CNAME
                AUTODISCOVER           = Resolve-DnsName -Name "autodiscover.$domain" -Type CNAME
                SOA                    = Resolve-DnsName -Type SOA -Name $domain
                NS                     = Resolve-DnsName $domain -Type NS
                O365DKIM               = [PSCustomObject]@{
                    SELECTOR1 = Resolve-DnsName "selector1._domainkey.$domain" -Type CNAME
                    SELECTOR2 = Resolve-DnsName "selector2._domainkey.$domain" -Type CNAME
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
