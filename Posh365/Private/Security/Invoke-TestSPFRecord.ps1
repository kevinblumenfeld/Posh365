function Invoke-TestSPFRecord {
    [CmdletBinding()]
    param (
        [Parameter()]
        $DomainName
    )
    $web = Invoke-WebRequest -Uri 'http://www.kitterman.com/spf/validate.html'
    $web.forms[0].fields.domain = $DomainName
    $result = Invoke-RestMethod 'http://www.kitterman.com/getspf2.py' -Body $web.forms[0].fields
    $result.replace("`r`n", "--")
}
