function Expand-IdFixReport {
    <#
    .SYNOPSIS
    Adds OU column to idFIX report

    .DESCRIPTION
    Long description

    .PARAMETER ReportFile
    Parameter description

    .EXAMPLE
    Expand-IdFixReport -ReportFile .\idFix.csv |Export-PoshExcel .\IDFixWithOU.xlsx

    .NOTES
    General notes
    #>
    param (
        [Parameter(Mandatory)]
        [string] $ReportFile
    )

    $idFixReport = Import-Csv $ReportFile

    foreach ($id in $idFixReport) {
        [PSCustomObject]@{
            ORGANIZATIONALUNIT = Convert-DistinguishedToCanonical -DistinguishedName ($id.DistinguishedName -replace '^.+?,(?=(OU|CN)=)')
            DISPLAYNAME        = $id.DISTINGUISHEDNAME -replace '^CN=|,.*$'
            DISTINGUISHEDNAME  = $id.DISTINGUISHEDNAME
            OBJECTCLASS        = $id.OBJECTCLASS
            ATTRIBUTE          = $id.ATTRIBUTE
            ERROR              = $id.ERROR
            VALUE              = $id.VALUE
            UPDATE             = $id.UPDATE
        }
    }
}
