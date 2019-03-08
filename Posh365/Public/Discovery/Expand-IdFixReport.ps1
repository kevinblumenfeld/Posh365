function Expand-IdFixReport {
    param (
        [Parameter(Mandatory)]
        [string] $ReportFile
    )

    $idFixReport = Import-csv $ReportFile

    foreach ($id in $idFixReport) {
        [PSCustomObject]@{
            ORGANIZATIONALUNIT = $id.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
            DISTINGUISHEDNAME  = $id.DISTINGUISHEDNAME
            OBJECTCLASS        = $id.OBJECTCLASS
            ATTRIBUTE          = $id.ATTRIBUTE
            ERROR              = $id.ERROR
            VALUE              = $id.VALUE
            UPDATE             = $id.UPDATE

        }
    }
}