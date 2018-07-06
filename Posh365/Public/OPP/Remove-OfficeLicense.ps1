function Remove-OfficeLicense { 
    <#

.SYNOPSIS
Often used when moving from one Office 365 tenant to another.

#>

    # store the license info into an array (uncomment line below)
    $license = cscript "C:\Program Files (x86)\Microsoft Office\Office15\OSPP.VBS" /dstatus

    #license name from /dstatus
    $o365 = “ADJUST_HERE_OfficeO365ProPlusR_Subscription1 edition”

    #loop till the end of the array searching for the $o365 string
    for ($i = 0; $i -lt $license.Length; $i++) {

        if ($license[$i] -match $o365) {

            $i += 6 #jumping six lines to get to the product key line in the array, check output of dstatus and adjust as needed for the product you are removing
            $keyline = $license[$i] # extra step but i would rather deal with the variable as a string than an array, could be removed i guess, efficiency is not my concern
            $prodkey = $keyline.substring($keyline.length - 5, 5) # getting the last 5 characters of the line (prodkey)

        }
    }
    #removing the key from the workstation
    cscript ‘C:\Program Files (x86)\Microsoft Office\Office15\OSPP.VBS’ /unpkey:$prodkey
}