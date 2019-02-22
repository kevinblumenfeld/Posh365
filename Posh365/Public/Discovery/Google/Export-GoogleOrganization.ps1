function Export-GoogleOrganization {
    <#
    .SYNOPSIS
    Google's GAM tool exports aliases
    This transforms that data and exports it into an importable format in the Microsoft world

    .DESCRIPTION
    Exports all organizational related information from Google GAM output to then be imported into Microsoft's environments

    .NOTES
    General notes
    #>

    param (

        [Parameter(Mandatory)]
        [string] $MailboxCSV

    )

    $MbxList = Import-Csv $MailboxCSV
    $PropList = ($MbxList | Select-Object -first 1).psobject.properties.name.where{ $_ -match 'organizations.*' }
    $PropPrimary = $PropList.where{ $_ -match 'organizations.*primary' }
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
                Department         = $Mbx."organizations.$Num.department"
                Office             = $Mbx."organizations.$Num.location"
                Title              = $Mbx."organizations.$Num.title"
            }
        }
    }
}