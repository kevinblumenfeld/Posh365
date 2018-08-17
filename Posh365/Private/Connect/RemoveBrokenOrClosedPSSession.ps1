function global:RemoveBrokenOrClosedPSSession() {
    <#
    .SYNOPSIS Remove broken and closed sessions
    #>
    $psBroken = Get-PSSession | where-object {$_.State -like "*Broken*"}
    $psClosed = Get-PSSession | where-object {$_.State -like "*Closed*"}

    if ($psBroken.count -gt 0) {
        for ($index = 0; $index -lt $psBroken.count; $index++) {
            Remove-PSSession -session $psBroken[$index]
        }
    }

    if ($psClosed.count -gt 0) {
        for ($index = 0; $index -lt $psClosed.count; $index++) {
            Remove-PSSession -session $psClosed[$index]
        }
    }
}