function Invoke-GetDupePrefix {
    param (

        [Parameter()]
        $FilePath,

        [Parameter()]
        $PoshPath,

        [Parameter()]
        [switch]
        $Target,

        [Parameter()]
        $Data
    )

    $Data = Import-Clixml $FilePath
    if ($Target) {
        $FileStamp = 'Local_Target_Dupes_{0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm')
    }
    else {
        $FileStamp = 'Local_Source_Dupes_{0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm')
    }

    $Hash = @{ }
    $RecipientList = $Data | Where-Object { $_.RecipientTypeDetails -notmatch 'DiscoveryMailbox|MailContact|GuestMailUser' }
    foreach ($Recipient in $RecipientList) {
        foreach ($Email in $Recipient.EmailAddresses) {
            if ($Email -like 'SMTP:*' ) {
                $Address = ($Email -split ':')[1]
                $Prefix = ($Address -split '@')[0]
                if ($Hash.ContainsKey($Prefix) -and $Hash[$Prefix]['PrimarySmtpAddress'] -ne $Recipient.PrimarySmtpAddress ) {
                    Get-DupesLocal -Prefix $Prefix -Address $Address -Hash $Hash -Recipient $Recipient | Export-Csv (Join-Path $PoshPath $FileStamp) -NoTypeInformation -Append
                }
                else {
                    $Hash[$Prefix] = @{
                        DisplayName          = $Recipient.DisplayName
                        Address              = $Address
                        PrimarySmtpAddress   = $Recipient.PrimarySmtpAddress
                        RecipientType        = $Recipient.RecipientType
                        RecipientTypeDetails = $Recipient.RecipientTypeDetails
                        EmailAddresses       = @($Recipient.EmailAddresses) -match [regex]::Escape(":$Prefix@") -join '|'
                    }
                }
            }
        }
    }
    $Hash
}