function Get-SpfRecordMode {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    $record = Get-SpfRecordText $DomainData

    if ($record) {
        switch -Wildcard ($record) {
            '*-all' { $determination = "HARDFAIL" }
            '*+all' { $determination = "PASS" }
            '*~all' { $determination = "SOFTFAIL" }
            '*`?all' { $determination = "NEUTRAL" }

            Default { $determination = "Other/Undetermined" }
        }

        return $determination
    }
    else {
        return "N/A"
    }
}
