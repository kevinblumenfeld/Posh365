function Add-ProxyToRecipient {
    [CmdletBinding()]
    param (
        [Parameter()]
        $AddProxyList,

        [Parameter(Mandatory)]
        [ValidateSet('RemoteMailbox','MailContact')]
        $Type
    )
    $ErrorActionPreference = 'Stop'
    if ($Type -eq 'RemoteMailbox') {
        foreach ($Add in $AddProxyList) {
            $Guid = ($Add.TargetGUID).ToString()
            try {
                Set-RemoteMailbox -Identity $Guid -EmailAddresses @{add = $Add.LegacyExchangeDN }
                [PSCustomObject]@{
                    Count              = $Add.Count
                    Result             = 'SUCCESS'
                    TargetDisplayName  = $Add.TargetDisplayName
                    PrimarySmtpAddress = $Add.PrimarySmtpAddress
                    Added              = $Add.LegacyExchangeDN
                    GUID               = $Guid
                    Identity           = $Add.TargetIdentity
                    SourceDisplayName  = $Add.SourceDisplayName
                    Log                = 'SUCCESS'
                }
                if ($Add.X500) {
                    foreach ($X in ($Add.X500).split('|')) {
                        Set-RemoteMailbox -Identity $Guid -EmailAddresses @{add = $X }
                        [PSCustomObject]@{
                            Count              = $Add.Count
                            Result             = 'SUCCESS'
                            TargetDisplayName  = $Add.TargetDisplayName
                            PrimarySmtpAddress = $Add.PrimarySmtpAddress
                            Added              = $X
                            GUID               = $Guid
                            Identity           = $Add.TargetIdentity
                            SourceDisplayName  = $Add.SourceDisplayName
                            Log                = 'SUCCESS'
                        }
                    }
                }
            }
            catch {
                [PSCustomObject]@{
                    Count              = $Add.Count
                    Result             = 'FAILED'
                    TargetDisplayName  = $Add.TargetDisplayName
                    PrimarySmtpAddress = $Add.PrimarySmtpAddress
                    Added              = $X
                    GUID               = $Guid
                    Identity           = $Add.TargetIdentity
                    SourceDisplayName  = $Add.SourceDisplayName
                    Log                = $_.Exception.Message
                }
            }
        }
    }
    if ($Type -eq 'MailContact') {
        foreach ($Add in $AddProxyList) {
            $Guid = ($Add.TargetGUID).ToString()
            try {
                Set-MailContact -Identity $Guid -EmailAddresses @{add = $Add.LegacyExchangeDN }
                [PSCustomObject]@{
                    Count              = $Add.Count
                    Result             = 'SUCCESS'
                    TargetDisplayName  = $Add.TargetDisplayName
                    PrimarySmtpAddress = $Add.PrimarySmtpAddress
                    Added              = $Add.LegacyExchangeDN
                    GUID               = $Guid
                    Identity           = $Add.TargetIdentity
                    SourceDisplayName  = $Add.SourceDisplayName
                    Log                = 'SUCCESS'
                }
                if ($Add.X500) {
                    foreach ($X in ($Add.X500).split('|')) {
                        Set-MailContact -Identity $Guid -EmailAddresses @{add = $X }
                        [PSCustomObject]@{
                            Count              = $Add.Count
                            Result             = 'SUCCESS'
                            TargetDisplayName  = $Add.TargetDisplayName
                            PrimarySmtpAddress = $Add.PrimarySmtpAddress
                            Added              = $X
                            GUID               = $Guid
                            Identity           = $Add.TargetIdentity
                            SourceDisplayName  = $Add.SourceDisplayName
                            Log                = 'SUCCESS'
                        }
                    }
                }
            }
            catch {
                [PSCustomObject]@{
                    Count              = $Add.Count
                    Result             = 'FAILED'
                    TargetDisplayName  = $Add.TargetDisplayName
                    PrimarySmtpAddress = $Add.PrimarySmtpAddress
                    Added              = $X
                    GUID               = $Guid
                    Identity           = $Add.TargetIdentity
                    SourceDisplayName  = $Add.SourceDisplayName
                    Log                = $_.Exception.Message
                }
            }
        }
    }
}
