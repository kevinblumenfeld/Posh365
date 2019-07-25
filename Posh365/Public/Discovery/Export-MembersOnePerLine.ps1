function Export-MembersOnePerLine {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ReportPath
    Parameter description

    .PARAMETER FindInColumn
    Parameter description

    .PARAMETER RowItem
    Parameter description

    .EXAMPLE
    Import-Csv .\EXO_Groups.csv | Export-MembersOnePerLine -ReportPath .\ -FindInColumn MembersName

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (

        [Parameter()]
        [string]$ReportPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet("MembersName", "MembersSMTP", "Member", "Members", "MemberOf", "Aliases", "Owners", "Managers")]
        [String]$FindInColumn,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $RowItem
    )
    process {

        foreach ($Row in $RowItem) {
            foreach ($Expand in ($Row."$FindInColumn").split('|')) {
                [PSCustomObject]@{
                    DisplayName          = $Row.DisplayName
                    $FindInColumn        = $Expand
                    GroupType            = $Row.GroupType
                    RecipientTypeDetails = $Row.RecipientTypeDetails
                    Identity             = $Row.Identity
                    ManagedBy            = $Row.ManagedBy
                    Name                 = $Row.Name
                    PrimarySmtpAddress   = $Row.PrimarySmtpAddress
                    EmailAddresses       = $Row.EmailAddresses
                }
            }
        }
    }
}
