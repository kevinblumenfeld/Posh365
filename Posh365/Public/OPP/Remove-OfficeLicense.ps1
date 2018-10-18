function Remove-OfficeLicense { 
    <#
    .SYNOPSIS
    Remove Product Key and License from an existing Office Install

    .DESCRIPTION
    Remove Product Key and License from an existing Office Install
    Often used when moving from one Office 365 tenant to another.

    .EXAMPLE
    Remove-OfficeLicense

    #>
    Start-Transcript

    $licrem = join-path $env:temp OfficeProPlusLicenseRemoved.txt
    if (-not (Test-Path $licrem)) {

        $license = cscript “C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS” /dstatus

        $o365 = 'LICENSE NAME'

        for ($i = 0; $i -lt $license.Length; $i++) {

            if ($license[$i] -match $o365) {
                $i += 6
                $keyline = $license[$i]
                $prodkey = $keyline.substring($keyline.length - 5, 5)
            }
        }

        cscript “C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS” /unpkey:$prodkey
        New-Item $licrem
    }
}