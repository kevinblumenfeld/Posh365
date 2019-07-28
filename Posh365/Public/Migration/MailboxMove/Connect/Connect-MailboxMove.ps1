Function Connect-MailboxMove {
    <#
    .SYNOPSIS
    Connect to Exchange Online and Azure AD

    .DESCRIPTION
    Connect to Exchange Online and Azure AD

    .PARAMETER Tenant
    if contoso.onmicrosoft.com use "Contoso"

    .EXAMPLE
    Connect-CloudMFA -Tenant

    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory)]
        [string] $Tenant
    )
    Connect-CloudMFA -Tenant $Tenant -ExchangeOnline -AzureAD
}
