function Export-EmailsOnePerLine {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("ProxyAddresses", "EmailAddresses", "EmailAddress", "AddressOrMember", "x500", "ExternalEmailAddress", "UserPrincipalName", "PrimarySmtpAddress", "Mail", "OtherMails", "MembersName", "Member", "Members", "MemberOf", "Aliases", "Owners", "Managers", "Subscribers")]
        [String]
        $FindInColumn,

        [Parameter(Mandatory = $true)]
        $RowList
    )
    end {
        switch ($FindInColumn) {
            { $_ -in @('Members', 'Owners', 'Subscribers') } {
                foreach ($Row in $RowList) {
                    foreach ($Expand in $Row.$FindInColumn.split('|')) {
                        [PSCustomObject]@{
                            DisplayName          = $Row.DisplayName
                            RecipientTypeDetails = 'UnifiedGroup'
                            Protocol             = "SMTP"
                            Domain               = $Expand.split('@')[1]
                            PrefixedAddress      = 'SMTP:{0}' -f $Expand
                            Address              = $Expand
                            Identity             = $FindInColumn
                            PrimarySmtpAddress   = ""
                            ExchangeObjectId     = $Row.ExchangeObjectId
                        }
                    }
                }
            }
            { $_ -in @('Mail', 'OtherMails') } {
                foreach ($Row in $RowList) {
                    foreach ($Expand in $Row.$FindInColumn.split('|')) {
                        [PSCustomObject]@{
                            DisplayName          = $Row.DisplayName
                            RecipientTypeDetails = $Row.UserType
                            Protocol             = "smtp"
                            Domain               = $Expand.split('@')[1]
                            PrefixedAddress      = 'smtp:{0}' -f $Expand
                            Address              = $Expand
                            Identity             = $Row.UserPrincipalName
                            PrimarySmtpAddress   = ""
                            ExchangeObjectId     = $Row.ObjectId
                        }
                    }
                }
            }
            { $_ -eq 'ExternalEmailAddress' } {
                foreach ($Row in $RowList) {
                    foreach ($Expand in $Row.$FindInColumn) {
                        [PSCustomObject]@{
                            DisplayName          = $Row.DisplayName
                            RecipientTypeDetails = $Row.RecipientTypeDetails
                            Protocol             = $Expand.split(':')[0]
                            Domain               = $Expand.split('@')[1]
                            PrefixedAddress      = $Expand
                            Address              = $Expand.split(':')[1]
                            Identity             = $Row.Identity
                            PrimarySmtpAddress   = $Row.PrimarySmtpAddress
                            ExchangeObjectId     = $Row.ExchangeObjectId
                        }
                    }
                }
            }
            Default {
                foreach ($Row in $RowList) {
                    foreach ($Expand in $Row.$FindInColumn.split('|')) {
                        [PSCustomObject]@{
                            DisplayName          = $Row.DisplayName
                            RecipientTypeDetails = $Row.RecipientTypeDetails
                            Protocol             = $Expand.split(':')[0]
                            Domain               = $Expand.split('@')[1]
                            PrefixedAddress      = $Expand
                            Address              = $Expand.split(':')[1]
                            Identity             = $Row.Identity
                            PrimarySmtpAddress   = $Row.PrimarySmtpAddress
                            ExchangeObjectId     = $Row.ExchangeObjectId
                        }
                    }
                }
            }
        }
    }
}
