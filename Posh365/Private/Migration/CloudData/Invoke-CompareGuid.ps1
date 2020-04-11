function Invoke-CompareGuid {
    [CmdletBinding()]
    param (
        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    # On-Premises (Remote Mailbox)
    Write-Host "`r`nConnecting to Exchange On-Premises $OnPremExchangeServer`r`n" -ForegroundColor Green
    Connect-Exchange -Server $OnPremExchangeServer -DontViewEntireForest:$DontViewEntireForest

    $OnPremList = Get-RemoteMailbox -ResultSize Unlimited
    $OnHash = @{ }
    foreach ($On in $OnPremList) {
        $OnHash[$On.UserPrincipalName] = @{
            'Identity'            = $On.Identity
            'DisplayName'         = $On.DisplayName
            'Name'                = $On.Name
            'SamAccountName'      = $On.SamAccountName
            'WindowsEmailAddress' = $On.WindowsEmailAddress
            'PrimarySmtpAddress'  = $On.PrimarySmtpAddress
            'OrganizationalUnit'  = $On.OnPremisesOrganizationalUnit
            'ExchangeGuid'        = ($On.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($On.ArchiveGuid).ToString()
        }
    }
    Get-PSSession | Remove-PSSession

    # (CLOUD) Exchange Online (Mailbox)
    $CloudList = Get-Mailbox -ResultSize Unlimited

    $CloudHash = @{ }
    foreach ($Cloud in $CloudList) {
        $CloudHash[$Cloud.UserPrincipalName] = @{
            'Identity'            = $Cloud.Identity
            'SamAccountName'      = $Cloud.SamAccountName
            'WindowsEmailAddress' = $Cloud.WindowsEmailAddress
            'PrimarySmtpAddress'  = $Cloud.PrimarySmtpAddress
            'ExchangeGuid'        = ($Cloud.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($Cloud.ArchiveGuid).ToString()
        }
    }
    Get-PSSession | Remove-PSSession

    foreach ($OnKey in $OnHash.keys) {
        if ($CloudHash.ContainsKey($OnKey)) {
            [PSCustomObject]@{
                Displayname        = if ($OnHash[$OnKey]['DisplayName']) { $OnHash[$OnKey]['DisplayName'] } else { $OnHash[$OnKey]['DisplayName']}
                OrganizationalUnit = $OnHash[$OnKey]['OnPremisesOrganizationalUnit']
                ExchangeGuidMatch  = $OnHash[$OnKey]['ExchangeGuid'] -eq $CloudHash[$OnKey]['ExchangeGuid']
                ArchiveGuidMatch   = $OnHash[$OnKey]['ArchiveGuid'] -eq $CloudHash[$OnKey]['ArchiveGuid']
                ExchangeGuidOnPrem = $OnHash[$OnKey]['ExchangeGuid']
                ExchangeGuidCloud  = $CloudHash[$OnKey]['ExchangeGuid']
            }
        }
        else {
            [PSCustomObject]@{
                Displayname        = if ($OnHash[$OnKey]['DisplayName']) { $OnHash[$OnKey]['DisplayName'] } else { $OnHash[$OnKey]['DisplayName'] }
                OrganizationalUnit = $OnHash[$OnKey]['OnPremisesOrganizationalUnit']
                ExchangeGuidMatch  = 'CLOUDUPNNOTFOUND'
                ArchiveGuidMatch   = 'CLOUDUPNNOTFOUND'
                ExchangeGuidOnPrem = $OnHash[$OnKey]['ExchangeGuid']
                ExchangeGuidCloud  = 'CLOUDUPNNOTFOUND'
            }
        }
    }
}