function Invoke-GetOutlookData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $LogPath
    )
    If (Test-Path $LogPath) {
        Get-Content -path $LogPath | ConvertFrom-Csv -Header @(
            'date-time', 'session-id', 'seq-number', 'client-name', 'organization-info'
            'client-software', 'client-software-version', 'client-mode', 'client-ip'
            'server-ip', 'protocol', 'application-idoperation', 'rpc-status'
            'processing-time', 'operation-specific', 'failures'
        ) | Where-Object { ($_."client-software" -eq 'OUTLOOK.EXE') -and ($_."client-name" -ne $null) }
    }
}
