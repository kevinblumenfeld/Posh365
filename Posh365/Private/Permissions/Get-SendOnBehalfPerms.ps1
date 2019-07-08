function Get-SendOnBehalfPerms {
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true)]
        $MailboxList,

        [parameter()]
        [hashtable] $ADHashDN,

        [parameter()]
        [hashtable] $ADHashCN
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting: `t $Mailbox"
            foreach ($Granted in $Mailbox.GrantSendOnBehalfTo) {
                $DisplayName = $ADHashCN["$Granted"].DisplayName
                Write-Verbose "Has Send On Behalf DN: `t $DisplayName"
                Write-Verbose "                   CN: `t $Granted"
                try {
                    Get-ADGroupMember "$DisplayName" -Recursive -ErrorAction stop |
                    ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Object             = $Mailbox.DisplayName
                            UserPrincipalName  = $Mailbox.UserPrincipalName
                            PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                            Granted            = $ADHashDN["$($_.distinguishedname)"].DisplayName
                            GrantedUPN         = $ADHashDN["$($_.distinguishedname)"].UserPrincipalName
                            GrantedSMTP        = $ADHashDN["$($_.distinguishedname)"].PrimarySMTPAddress
                            Checking           = $Granted
                            GroupMember        = $($_.distinguishedname)
                            Type               = "GroupMember"
                            Permission         = "SendOnBehalf"
                        }
                    }
                }
                Catch {
                    New-Object -TypeName psobject -property @{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Granted            = $ADHashCN["$Granted"].DisplayName
                        GrantedUPN         = $ADHashCN["$Granted"].UserPrincipalName
                        GrantedSMTP        = $ADHashCN["$Granted"].PrimarySMTPAddress
                        Checking           = $Granted
                        GroupMember        = ""
                        Type               = "User"
                        Permission         = "SendOnBehalf"
                    }
                }
            }
        }
    }
    end {

    }
}
