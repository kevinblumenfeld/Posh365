function Convert-CanonicalToDistinguished {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CanonicalName
    )
    end {
        $TempObj = $CanonicalName.Replace(',', '\,').Split('/')
        [string]$DN = "CN=" + $TempObj[$TempObj.count - 1]
        for ($i = $TempObj.count - 2; $i -ge 1; $i--) { $DN += ",OU=" + $TempObj[$i] }
        $TempObj[0].split(".") | ForEach-Object { $DN += ",DC=" + $_ }
        $DN
    }
}
