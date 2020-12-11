function Find-MemMobileDevice {
    <#
    .SYNOPSIS
    Loop till a mobile device is found and compliant

    .DESCRIPTION
    Loop till a mobile device is found and compliant

    .PARAMETER imei
    Phone's imei number

    .EXAMPLE
    Find-MemMobileDevice -imei '673281231034555'

    .NOTES
    General notes
    #>
    param (
        [Parameter(Mandatory)]
        $imei
    )
    do {
        $Device = $null
        try {
            $Device = Get-MemMobileDevice -imei $imei -ErrorAction Stop
        }
        catch {
            Write-Host 'Device not found ERROR!!!!' -ForegroundColor Red
            $_ | Select-Object *
            Start-Sleep 1
            continue
        }
        Start-Sleep 1
        if (-not $Device) {
            Write-Host 'Device not found' -ForegroundColor Red
        }
        elseif ($Device.complianceState -eq 'Compliant') {
            $Device | Select-Object *ID*, *NAME*
            Write-Host 'Device Found COMPLIANT!' -ForegroundColor Green
        }
        else {
            $Device | Select-Object *ID*,*NAME*
            Write-Host 'Device Found ' -ForegroundColor Green -NoNewline
            Write-Host 'NonCompliant' -ForegroundColor Red
        }
    } until ($Device.complianceState -eq 'Compliant')
}