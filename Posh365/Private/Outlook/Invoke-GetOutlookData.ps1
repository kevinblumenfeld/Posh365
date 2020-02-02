function Invoke-GetOutlookData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $FullFilePath
    )
    If (Test-Path $FullFilePath) {
        Get-Content -path $FullFilePath | ConvertFrom-Csv -Header @(
            'date-time', 'session-id', 'seq-number', 'client-name', 'organization-info'
            'client-software', 'client-software-version', 'client-mode', 'client-ip'
            'server-ip', 'protocol', 'application-idoperation', 'rpc-status'
            'processing-time', 'operation-specific', 'failures'
        ) | Where-Object { ($_."client-software" -eq 'OUTLOOK.EXE') -and ($_."client-name" -ne $null) } |
        Select-Object -Unique @(
            'client-software', 'client-software-version', 'client-mode'
            @{
                Name       = 'client-name'
                Expression = { ($_."client-name") }
            }
        )
    }
}
