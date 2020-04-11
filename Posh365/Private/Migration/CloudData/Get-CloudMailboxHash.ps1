function Get-CloudMailboxHash {
    [CmdletBinding()]
    param (
    )

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
}