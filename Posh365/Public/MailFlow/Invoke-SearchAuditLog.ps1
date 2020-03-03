Function Invoke-SearchAuditLog {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        $StartDate,

        [Parameter()]
        $EndDate,

        [Parameter()]
        $SessionCommand,

        [Parameter()]
        $SessionId,

        [Parameter()]
        $RecordType,

        [Parameter()]
        $Operations,

        [Parameter()]
        $ResultSize
    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    do {
        Write-Verbose "Checking audit log results on page $counter."
        Search-UnifiedAuditLog @params | Select-Object -ExcludeProperty AuditData -Property @(
            '*'
            @{
                Name       = 'AuditData'
                Expression = { $_.AuditData | ConvertFrom-Json }
            }
            @{
                Name       = 'ModifiedProperties'
                Expression = { $_.AuditData.ModifiedProperties | ConvertFrom-Json }
            }
        ) | Select-Object -ExpandProperty AuditDatam -ExcludeProperty AuditData, RecordType, ModifiedProperties -Property *
    } Until ($Log.ResultIndex[-1] -ge $Log.ResultCount[-1])

    $ErrorActionPreference = $currentErrorActionPrefs
}
