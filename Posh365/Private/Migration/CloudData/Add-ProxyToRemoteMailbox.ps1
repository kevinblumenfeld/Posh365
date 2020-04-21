function Add-ProxyToRemoteMailbox {
    [CmdletBinding()]
    param (
        [Parameter()]
        $AddProxyList
    )
    $ErrorActionPreference = 'Stop'
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
