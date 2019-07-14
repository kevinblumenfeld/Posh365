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
        $ADHashCN
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting: `t $Mailbox"
            foreach ($GrantedSOB in $Mailbox.GrantSendOnBehalfTo) {
                $DisplayName = $ADHashCN["$GrantedSOB"].DisplayName
                Write-Verbose "Has Send On Behalf DN: `t $DisplayName"
                Write-Verbose "                   CN: `t $GrantedSOB"
                New-Object -TypeName psobject -property @{
                    Object             = $Mailbox.DisplayName
                    UserPrincipalName  = $Mailbox.UserPrincipalName
                    PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                    Granted            = $ADHashCN["$GrantedSOB"].DisplayName
                    GrantedUPN         = $ADHashCN["$GrantedSOB"].UserPrincipalName
                    GrantedSMTP        = $ADHashCN["$GrantedSOB"].PrimarySMTPAddress
                    Checking           = $GrantedSOB
                    Type               = $ADHashCN["$GrantedSOB"].msExchRecipientTypeDetails
                    Permission         = "SendOnBehalf"
                }
            }
        }
    }
    end {

    }
}
