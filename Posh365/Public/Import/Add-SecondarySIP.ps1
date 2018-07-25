foreach ($sip in $sips) {
    $user = get-aduser -Identity $sip.distinguishedname -Properties proxyaddresses
    $ObjectGUID = $user.ObjectGUID
    $SIP = $User.proxyaddresses | Where-Object {$_ -cmatch "sip:"}
    if ($SIP) {

        write-host $sip
        Set-ADUser -Identity $ObjectGUID -remove @{proxyaddresses = "$sip"}
    }
}

foreach ($sip in $sips) {
    $user = get-aduser -Identity $sip.distinguishedname -Properties proxyaddresses
    $ObjectGUID = $user.ObjectGUID
    $SIP = $User.proxyaddresses | Where-Object {$_ -cmatch "SIP:"}
    if ($SIP) {
        $SIPlower = $SIP.tolower()
        $Secondarysip = $SIPlower -replace ([Regex]::Escape('brileywealth.com'), 'wundernet.com')
        write-host $Secondarysip
        Set-ADUser -Identity $ObjectGUID -add @{proxyaddresses = "$Secondarysip"}
    }
}


foreach ($sip in $sips) {
    $user = get-aduser -Identity $sip.distinguishedname -Properties proxyaddresses, DisplayName
    $ObjectGUID = $user.ObjectGUID
    $DisplayName = $user.displayname
    $SIP = $null
    $SIP = $User.proxyaddresses | Where-Object {$_ -cmatch "SIP:"}
    if ($SIP) {
        $SIPlower = $SIP.tolower()
        write-host "$DisplayName" 
        write-host "$SIPlower"
        Set-ADUser -Identity $ObjectGUID -replace @{'msRTCSIP-PrimaryUserAddress' = "$SIPlower"}
    }
}

foreach ($sip in $sips) {
    $DisplayName = $Null
    $user = get-aduser -Identity $sip.distinguishedname -Properties *
    $ObjectGUID = $user.ObjectGUID
    $DisplayName = $user.displayname
    $ms = "sip:" + $User.userprincipalname
    if (-not ($User.proxyaddresses | Where-Object {$_ -cmatch "SIP:"})) {
        write-host "$DisplayName" 
        write-host "$ms" 
        Set-ADUser -Identity $ObjectGUID -replace @{'msRTCSIP-PrimaryUserAddress' = "$ms"}
    }
}
    