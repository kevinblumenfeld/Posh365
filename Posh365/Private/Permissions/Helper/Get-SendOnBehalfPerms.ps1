function Get-SendOnBehalfPerms {
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true)]
        $MailboxList,

        [parameter()]
        [hashtable]
        $ADHashDN,

        [parameter()]
        [hashtable]
        $ADHashCN,

        [parameter()]
        [hashtable]
        $ADHashType,

        [parameter()]
        [hashtable]
        $ADHashDisplay
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting: `t $Mailbox"
            $Display = New-Object System.Collections.Generic.List[string]
            $UPN = New-Object System.Collections.Generic.List[string]
            $SMTP = New-Object System.Collections.Generic.List[string]
            foreach ($GrantedSOB in $Mailbox.GrantSendOnBehalfTo) {
                $DisplayName = $ADHashCN["$GrantedSOB"].DisplayName
                $Display.Add($ADHashCN["$GrantedSOB"].DisplayName)
                $UPN.Add($ADHashCN["$GrantedSOB"].UserPrincipalName)
                $SMTP.Add($ADHashCN["$GrantedSOB"].PrimarySMTPAddress)
                Write-Verbose "Has Send On Behalf DN: `t $DisplayName"
                Write-Verbose "                   CN: `t $GrantedSOB"
            }
            New-Object -TypeName psobject -property @{
                Object             = $Mailbox.DisplayName
                UserPrincipalName  = $Mailbox.UserPrincipalName
                PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                Granted            = @($Display) -ne '' -join '|'
                GrantedUPN         = @($UPN) -ne '' -join '|'
                GrantedSMTP        = @($SMTP) -ne '' -join '|'
                Checking           = $GrantedSOB
                TypeDetails        = $ADHashType."$($ADHashCN["$GrantedSOB"].msExchRecipientTypeDetails)"
                DisplayType        = $ADHashDisplay."$($ADHashCN["$GrantedSOB"].msExchRecipientDisplayType)"
                Permission         = "SendOnBehalf"
            }
        }
    }
    end {

    }
}
