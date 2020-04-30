function Add-ProxyToRecipient {
    [CmdletBinding()]
    param (
        [Parameter()]
        $AddProxyList,

        [Parameter(Mandatory)]
        [ValidateSet('RemoteMailbox', 'MailContact')]
        $Type
    )
    $ErrorActionPreference = 'Stop'
    $Count = @($AddProxylist).Count
    $i = 0
    if ($Type -eq 'RemoteMailbox') {
        foreach ($Add in $AddProxyList) {
            $i++
            $Guid = $Add.TargetGUID.ToString()
            try {
                Set-RemoteMailbox -Identity $Guid -EmailAddresses @{add = $Add.LegacyExchangeDN }
                [PSCustomObject]@{
                    Num                = '[{0} of {1}]' -f $i, $Count
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
                            Num                = '[{0} of {1}]' -f $i, $Count
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
                    Num                = '[{0} of {1}]' -f $i, $Count
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
                    Num                = '[{0} of {1}]' -f $i, $Count
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
                            Num                = '[{0} of {1}]' -f $i, $Count
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
                    Num                = $Add.Num
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
