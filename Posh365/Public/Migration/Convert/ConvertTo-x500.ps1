function ConvertTo-x500 {
    <#
    .SYNOPSIS
    Convert IMCEAX NDRs to code to run against a mailbox

    .DESCRIPTION
    Convert IMCEAX NDRs to code to run against a mailbox

    .PARAMETER IMCEAEX
    Use IMCEAEX found in NDR or trace logs

    The NDR might looks something like this...

    Couldn't deliver to the following recipients:

    IMCEAEX-_o=ExchangeLabs_ou=Exchange+20Administrative+20Group+20+28FYDIBOHF23SPDLT+29_cn=Recipients_cn=86595dbec932d461fbdfe93cb1234585e-Joe+20Smit@namprd13.prod.outlook.com


    .EXAMPLE
    ConvertTo-x500 -IMCEAEX "IMCEAEX-_o=ExchangeLabs_ou=Exchange+20Administrative+20Group+20+28FYDIBOHF23SPDLT+29_cn=Recipients_cn=86595dbec932d461fbdfe93cb1234585e-Joe+20Smit@namprd13.prod.outlook.com"

    .NOTES
    This is based on Matt Ellis's code.  It was missing ("+2C", ",") so I corrected it here.
    #>

    param (
        [Parameter()]
        [string]
        $IMCEAEX
    )
    if ($IMCEAEX.Substring(0, 7) -ne "IMCEAEX") {
        Write-Host -ForegroundColor Red "`nSorry, your IMCEAEX string must begin with IMCEAEX`n"
    }
    else {
        $X500 = $IMCEAEX.Replace("IMCEAEX-", "X500:").Replace("_", "/").Replace("+20", " ").Replace("+28", "(").Replace("+29", ")").Replace("+2E", ".").Replace("%3D", "=").Replace("+2C", ",").Split("@")[0]
        Write-Host
        Write-Host -ForegroundColor DarkCyan "Your converted X.500 address is: `n"
        Write-Host -ForegroundColor Green $X500 `n
        # Write-Host -ForegroundColor DarkCyan "Here is the Set-Mailbox command to add the X.500 address to a user (change the Identity attribute accordingly): `n"
        # Write-Host -ForegroundColor Green "Set-Mailbox -Identity first.last@domain.com -EmailAddresses @{add=`"$X500`"}" `n
        # Write-Host -ForegroundColor Yellow "Done!`n"
    }
}
