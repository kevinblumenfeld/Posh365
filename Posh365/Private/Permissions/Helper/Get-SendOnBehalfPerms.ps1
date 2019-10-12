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
        $ADHashDisplay,

        [parameter()]
        [hashtable]
        $UserGroupHash,

        [parameter()]
        [hashtable]
        $GroupMemberHash
    )
    begin {

    }
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Verbose "Inspecting: `t $Mailbox"

            foreach ($HasPerm in @($Mailbox.GrantSendOnBehalfTo)) {
                $Logon = $ADHashCN.$HasPerm.logon
                if ($GroupMemberHash.$Logon.Members -and
                    $ADHashDisplay."$($ADHashCN["$HasPerm"].msExchRecipientDisplayType)" -match 'group') {
                    foreach ($Member in @($GroupMemberHash.$Logon.Members)) {
                        Write-Verbose "  Member: `t $Member"
                        New-Object -TypeName psobject -property @{
                            Object             = $Mailbox.DisplayName
                            UserPrincipalName  = $Mailbox.UserPrincipalName
                            PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                            Granted            = $UserGroupHash[$Member].DisplayName
                            GrantedUPN         = $UserGroupHash[$Member].UserPrincipalName
                            GrantedSMTP        = $UserGroupHash[$Member].PrimarySMTPAddress
                            Checking           = $ADHashCN.$HasPerm.DisplayName
                            TypeDetails        = "GroupMember"
                            DisplayType        = $ADHashDisplay."$($ADHashCN["$HasPerm"].msExchRecipientDisplayType)"
                            Permission         = "SendOnBehalf"
                        }
                    }
                }
                elseif ( $ADHash["$HasPerm"].objectClass -notmatch 'group') {
                    Write-Verbose "  CN: `t $HasPerm"
                    New-Object -TypeName psobject -property @{
                        Object             = $Mailbox.DisplayName
                        UserPrincipalName  = $Mailbox.UserPrincipalName
                        PrimarySMTPAddress = $Mailbox.PrimarySMTPAddress
                        Granted            = $ADHashCN["$HasPerm"].DisplayName
                        GrantedUPN         = $ADHashCN["$HasPerm"].UserPrincipalName
                        GrantedSMTP        = $ADHashCN["$HasPerm"].PrimarySMTPAddress
                        Checking           = $ADHashCN.$HasPerm.DisplayName
                        TypeDetails        = $ADHashType."$($ADHashCN["$HasPerm"].msExchRecipientTypeDetails)"
                        DisplayType        = $ADHashDisplay."$($ADHashCN["$HasPerm"].msExchRecipientDisplayType)"
                        Permission         = "SendOnBehalf"
                    }
                }
            }
        }
    }
    end {

    }
}
