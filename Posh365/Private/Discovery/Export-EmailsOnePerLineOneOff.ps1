function Export-EmailsOnePerLineOneOff {
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
            { $_ -in @('ProxyAddresses', 'OtherMails', 'Mail') } {
                foreach ($Row in $RowList) {
                    foreach ($Expand in $Row.$FindInColumn.split('|')) {
                        [PSCustomObject]@{
                            DisplayName          = $Row.DisplayName
                            RecipientTypeDetails = $Row.UserType
                            Protocol             = $Expand.split(':')[0]
                            Domain               = $Expand.split('@')[1]
                            PrefixedAddress      = $Expand
                            Address              = $Expand.split(':')[1]
                            Identity             = $Row.Identity
                            PrimarySmtpAddress   = $Row.PrimarySmtpAddress
                            ExchangeObjectId     = $Row.ObjectId
                        }
                    }
                }
            }
        }
    }
}
