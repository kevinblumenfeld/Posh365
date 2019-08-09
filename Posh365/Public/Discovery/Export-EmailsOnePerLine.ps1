function Export-EmailsOnePerLine {
    [CmdletBinding()]
    param (

        [Parameter()]
        [string]$ReportPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ProxyAddresses", "EmailAddresses", "EmailAddress", "AddressOrMember", "x500", "ExternalEmailAddress", "UserPrincipalName", "PrimarySmtpAddress", "MembersName", "Member", "Members", "MemberOf", "Aliases", "Owners", "Managers")]
        [String]$FindInColumn,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $RowItem
    )
    process {

        foreach ($Row in $RowItem) {
            if ($FindInColumn -ne "ExternalEmailAddress") {
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
            else {
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

    }
}
