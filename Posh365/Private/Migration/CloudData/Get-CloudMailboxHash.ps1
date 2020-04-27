function Get-CloudMailboxHash {
    [CmdletBinding()]
    param (
    )

    
    $CloudSelect = @(
        'UserPrincipalName', 'Identity', 'DisplayName'
        'Name', 'SamAccountName', 'WindowsEmailAddress'
        'PrimarySmtpAddress', 'ExchangeGuid', 'ArchiveGuid'
    )

    $CloudList = Get-Mailbox -ResultSize Unlimited | Select-Object $CloudSelect

    $CloudHash = @{ }
    foreach ($Cloud in $CloudList) {
        $CloudHash[$Cloud.UserPrincipalName] = @{
            'Identity'            = $Cloud.Identity
            'DisplayName'         = $Cloud.DisplayName
            'Name'                = $Cloud.Name
            'SamAccountName'      = $Cloud.SamAccountName
            'WindowsEmailAddress' = $Cloud.WindowsEmailAddress
            'PrimarySmtpAddress'  = $Cloud.PrimarySmtpAddress
            'ExchangeGuid'        = ($Cloud.ExchangeGuid).ToString()
            'ArchiveGuid'         = ($Cloud.ArchiveGuid).ToString()
        }
    }
    $CloudHash
}