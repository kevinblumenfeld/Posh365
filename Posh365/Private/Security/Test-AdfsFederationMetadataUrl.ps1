function Test-AdfsFederationMetadataUrl {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    $federationPrefixes = 'adfs', 'sso', 'sts', 'fs', 'auth', 'idf', 'fed'
    $fedHost = $null

    foreach ($prefix in $federationPrefixes) {

        # Build up our attempted federation hostname
        $tempURL = "{0}.{1}" -f $prefix, $DomainName

        # Try and resolve the hostname
        $ResolveSplat = @{
            Name          = $tempURL
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            Server        = '8.8.8.8'
        }
        $resolved = Resolve-DnsName @ResolveSplat

        # If the hostname doesn't resolve, skip to the next one
        if ($resolved -eq $null) { continue }

        # Assuming the federation service is ADFS, build up a path to the metadata file
        $fedURL = "https://$tempURL/federationmetadata/2007-06/federationmetadata.xml"

        # Try and retrieve the federation metadata XML file
        $xmlData = $null
        try {
            $xmlData = Invoke-RestMethod -Method Get -Uri $fedURL -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        catch { }

        # If we managed to retrieve the XML metadata file, return the FQDN of the ADFS server
        if (($xmlData -ne $null) -and ($xmlData.EntityDescriptor.entityID -ne $null)) {
            return $tempURL
        }
    }
}
