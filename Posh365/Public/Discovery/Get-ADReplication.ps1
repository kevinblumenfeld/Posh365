function Get-ADReplication {
    Param ()
    <#
    .SYNOPSIS
    Get Active Directory Replication Summary from each Domain Controller in the Forest

    .EXAMPLE
    Get-ADReplication | Export-Csv .\ADReplication.csv -notypeinformation

    #>

    $domain = (Get-ADForest).Domains

    $server = ForEach ($curDomain in $domain) {
        Try {
            Get-ADDomainController -Discover -DomainName $curDomain -erroraction stop
        }
        Catch {
            Write-Warning "Error Discovering Server in Domain: $curDomain"
        }
    }

    $dc = ForEach ($curServer in $Server) {
        Try {
            Get-ADDomainController -Filter * -Server $curServer.name -erroraction stop
        }
        Catch {
            Write-Warning "Error Discovering DCs with Server: $curServer"
        }
    }

    foreach ($curDC in $dc) {
        $src = @(& C:\windows\system32\repadmin.exe /replsummary /bysrc /sort:delta $curDC.hostname)

        $cleanSrc = @()
        for ($i = 10; $i -lt ($src.Count - 4); $i++) {
            if ($src[$i] -ne "") {
                $src[$i] -replace '\s+', ' ' | Out-Null
                $cleanSrc += $src[$i]
            }
        }

        foreach ($line in $cleanSrc) {
            if ($line -like "*Server Down*") {
                $ErrorMsg = ""
                for ($i = 0; $i -lt ($cleanSrc.count - 1); $i++) {
                    $ErrorMsg += $cleanSrc[$i]
                }
                New-Object PSCustomObject -Property @{
                    Testing  = $curDC.hostname
                    ADSite   = $curDC.Site
                    DSAType  = "Source"
                    Hostname = ""
                    Delta    = ""
                    Fails    = ""
                    Total    = ""
                    PctError = ""
                    ErrorMsg = $ErrorMsg.trim()
                } | Select-Object Testing, ADSite, DSAType, Hostname, Delta, Fails, Total, PctError, ErrorMsg
            }
            else {
                if ($line -like "* days*") {
                    $line = ($line -replace ' days', 'days')
                }
                $splitSrc = $line -split '\s+', 8
                if ($splitSrc[0] -eq "Source") {
                    $repType = "Source"
                }
                if ($splitSrc[0] -eq "Destination") {
                    $repType = "Destination"
                }
                if ($splitSrc[1] -notmatch "DSA") {
                    New-Object PSCustomObject -Property @{
                        Testing  = $curDC.hostname
                        ADSite   = $curDC.Site
                        DSAType  = $repType
                        Hostname = $splitSrc[1]
                        Delta    = $splitSrc[2]
                        Fails    = $splitSrc[3]
                        Total    = $splitSrc[5]
                        PctError = $splitSrc[6]
                        ErrorMsg = $splitSrc[7]
                    } | Select-Object Testing, ADSite, DSAType, Hostname, Delta, Fails, Total, PctError, ErrorMsg
                }
            }

        }
        $dest = @(& C:\windows\system32\repadmin.exe /replsummary /bydst /sort:delta $curDC.hostname)
        $cleandest = @()
        for ($i = 10; $i -lt ($dest.Count - 4); $i++) {
            if ($dest[$i] -ne "") {
                $dest[$i] -replace '\s+', ' ' | Out-Null
                $cleandest += $dest[$i]
            }
        }
        foreach ($line in $cleandest) {
            if ($line -like "*Server Down*") {
                $ErrorMsg = ""
                for ($i = 0; $i -lt ($cleanSrc.count - 1); $i++) {
                    $ErrorMsg += $cleanSrc[$i]
                }
                New-Object PSCustomObject -Property @{
                    Testing  = $curDC.hostname
                    ADSite   = $curDC.Site
                    DSAType  = "Destination"
                    Hostname = ""
                    Delta    = ""
                    Fails    = ""
                    Total    = ""
                    PctError = ""
                    ErrorMsg = $ErrorMsg.trim()
                } | Select-Object Testing, ADSite, DSAType, Hostname, Delta, Fails, Total, PctError, ErrorMsg
            }
            else {
                if ($line -like "* days*") {
                    $line = ($line -replace ' days', 'days')
                }
                $splitDest = $line -split '\s+', 8
                if ($splitDest[0] -eq "Source") {
                    $repType = "Source"
                }
                if ($splitDest[0] -eq "Destination") {
                    $repType = "Destination"
                }
                if ($splitDest[1] -notmatch "DSA") {
                    New-Object PSCustomObject -Property @{
                        Testing  = $curDC.hostname
                        ADSite   = $curDC.Site
                        DSAType  = $repType
                        Hostname = $splitDest[1]
                        Delta    = $splitDest[2]
                        Fails    = $splitDest[3]
                        Total    = $splitDest[5]
                        PctError = $splitDest[6]
                        ErrorMsg = $splitDest[7]
                    } | Select-Object Testing, ADSite, DSAType, Hostname, Delta, Fails, Total, PctError, ErrorMsg
                }
            }
        }
    }
}