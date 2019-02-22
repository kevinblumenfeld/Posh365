function Export-GooglePhone {
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
    $PropList = ($MbxList | Select-Object -first 1).psobject.properties.name.where{ $_ -match 'phones.*type' }

    foreach ($Mbx in $MbxList) {
        $Phone = [ordered]@{
            DisplayName        = $Mbx."name.fullName"
            FirstName          = $Mbx."name.GivenName"
            LastName           = $Mbx."name.familyName"
            PrimarySmtpAddress = $Mbx.primaryEmail
        }
        foreach ($Prop in $PropList) {
            $WorkNum = $Prop.where{ $Mbx.$_ -eq "work" }
            $WorkNumMatch = $WorkNum.where{ $_ -match "(?<=\.)\d+(?=\.)" }
            if ($WorkNumMatch) {
                $Num = $Matches[0]
                $Phone.add('PhoneNumber', $Mbx."phones.$Num.value")
            }
            $MobileNum = $Prop.where{ $Mbx.$_ -eq "mobile" }
            $MobileNumMatch = $MobileNum.where{ $_ -match "(?<=\.)\d+(?=\.)" }
            if ($MobileNumMatch) {
                $Num = $Matches[0]
                $Phone.add('MobilePhone', $Mbx."phones.$Num.value")
            }
        }
        if (-not $Phone.PhoneNumber) {
            $Phone.add('PhoneNumber', $null)
        }
        if (-not $Phone.MobilePhone) {
            $Phone.add('MobilePhone', $null)
        }
        [PSCustomObject]$Phone
    }
}