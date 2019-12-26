function Get-LowestPreferenceMX {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainData
    )
    if ($DomainData.MX -eq $null) { return }

    $DomainData.MX | Sort-Object -Property Preference | Select-Object -First 1 -ExpandProperty NameExchange -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}
