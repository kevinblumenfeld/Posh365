function Invoke-TestSPFRecord {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    # $web = Invoke-WebRequest -Uri 'http://www.kitterman.com/spf/validate.html' -UseBasicParsing
    # $web.forms[0].fields.domain = $DomainName
    $result = Invoke-RestMethod "http://www.kitterman.com/spf/getspf3.py?serial=fred12&domain=${DomainName}" -UseBasicParsing
    $result.replace("`r`n", "--")
}
