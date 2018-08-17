function Connect-IPPSSession {
    <#
        .SYNOPSIS
            Connect-IPPSSession -ConnectionURI https://ps.compliance.protection.outlook.com/PowerShell-LiveId -AzureADAuthorizationEndpointUri https://login.windows.net/common
            NOTE: PSSessionOption accept object created using New-PSSessionOption
            Please add -DelegatedOrganization para name and its value (domain name) if you want manage another tenant
        .DESCRIPTION
            This cmdlet allows you to connect to Exchange Online Protection Service
    #>

    param(
        # Connection Uri for the Remote PowerShell endpoint
        [string] $ConnectionUri = 'https://ps.compliance.protection.outlook.com/PowerShell-LiveId',

        # Azure AD Authorization endpoint Uri that can issue the OAuth2 access tokens
        [string] $AzureADAuthorizationEndpointUri = 'https://login.windows.net/common',

        # User Principal Name or email address of the user
        [string] $UserPrincipalName = '',

        # Delegated Organization Name
        [string] $DelegatedOrganization = '',

        # PowerShell session options to be used when opening the Remote PowerShell session
        [System.Management.Automation.Remoting.PSSessionOption] $PSSessionOption = $null,

        # User Credential to Logon
        [System.Management.Automation.PSCredential] $Credential = $null
    )

    [string]$newUri = $null;

    if (![string]::IsNullOrWhiteSpace($DelegatedOrganization)) {
        [UriBuilder] $uriBuilder = New-Object -TypeName UriBuilder -ArgumentList $ConnectionUri;
        [string] $queryToAppend = "DelegatedOrg={0}" -f $DelegatedOrganization;
        if ($uriBuilder.Query -ne $null -and $uriBuilder.Query.Length -gt 0) {
            [string] $existingQuery = $uriBuilder.Query.Substring(1);
            $uriBuilder.Query = $existingQuery + "&" + $queryToAppend;
        }
        else {
            $uriBuilder.Query = $queryToAppend;
        }

        $newUri = $uriBuilder.ToString();
    }
    else {
        $newUri = $ConnectionUri;
    }

    Connect-EXOPSSession -ConnectionUri $newUri -AzureADAuthorizationEndpointUri $AzureADAuthorizationEndpointUri -UserPrincipalName $UserPrincipalName -PSSessionOption $PSSessionOption -Credential $Credential
}