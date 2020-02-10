function Expand-IdFixReport {
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
