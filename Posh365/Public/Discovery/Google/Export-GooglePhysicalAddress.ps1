function Export-GooglePhysicalAddress {
    <#
    .SYNOPSIS
    Google's GAM tool exports aliases
    This transforms that data and exports it into an importable format in the Microsoft world

    .DESCRIPTION

    .NOTES
    General notes
    #>

    param (

        [Parameter(Mandatory)]
        [string] $MailboxCSV

    )

    $MbxList = Import-Csv $MailboxCSV
    $PropList = ($MbxList | Select-Object -first 1).psobject.properties.name.where{ $_ -match 'addresses.*' }
    $PropPrimary = $PropList.where{ $_ -match 'addresses.*primary' }
    foreach ($Mbx in $MbxList) {
        $Number = $PropPrimary.where{ $Mbx.$_ -eq "TRUE" }
        $NumMatch = $Number.where{ $_ -match "(?<=\.)\d+(?=\.)" }
        if ($NumMatch) {
            $Num = $Matches[0]
            [PSCustomObject]@{
                DisplayName        = $Mbx."name.fullName"
                FirstName          = $Mbx."name.GivenName"
                LastName           = $Mbx."name.familyName"
                PrimarySmtpAddress = $Mbx.primaryEmail
                StreetAddress      = $Mbx."addresses.$Num.streetAddress"
                City               = $Mbx."addresses.$Num.locality"
                State              = $Mbx."addresses.$Num.region"
                PostalCode         = $Mbx."addresses.$Num.postalCode"
                Country            = $Mbx."addresses.$Num.country"
            }
        }
    }
}