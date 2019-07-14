Function Get-MailboxMoveMailboxPermission {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $SkipSendAs,

        [Parameter()]
        [switch]
        $SkipSendOnBehalf,

        [Parameter()]
        [switch]
        $SkipFullAccess,

        [Parameter(Mandatory = $true)]
        $MailboxList,

        [Parameter(Mandatory = $true)]
        $ADUserList
    )
    end {
        Write-Verbose "Caching hashtable. LogonName as Key and Values of DisplayName & UPN"
        $ADHash = $ADUserList | Get-ADHash

        Write-Verbose "Caching hashtable. DN as Key and Values of DisplayName, UPN & LogonName"
        $ADHashDN = $ADUserList | Get-ADHashDN

        Write-Verbose "Caching hashtable. CN as Key and Values of DisplayName, UPN & LogonName"
        $ADHashCN = $ADUserList | Get-ADHashCN

        Write-Verbose "Caching hashtable. msExchRecipientTypeDetails numerical value as Key and Value of human readable"
        $ADHashType = Get-ADHashType

        $MailboxDN = $MailboxList | Select-Object -expandproperty distinguishedname

        $PermSelect = @(
            'Object', 'UserPrincipalName', 'PrimarySMTPAddress', 'Granted', 'GrantedUPN'
            'GrantedSMTP', 'Checking', 'GroupMember', 'Type', 'Permission'
        )
        if (-not $SkipSendAs) {
            Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
            $MailboxDN | Get-SendAsPerms -ADHashDN $ADHashDN -ADHash $ADHash -ADHashType $ADHashType |
            Select-Object $PermSelect
        }
        if (-not $SkipSendOnBehalf) {
            Write-Verbose "Getting SendOnBehalf permissions for each mailbox and writing to file"
            ($MailboxList | Where-Object { $_.GrantSendOnBehalfTo -ne $null }) | Get-SendOnBehalfPerms -ADHashCN $ADHashCN -ADHashDN $ADHashDN -ADHashType $ADHashType |
            Select-Object $PermSelect
        }
        if (-not $SkipFullAccess) {
            Write-Verbose "Getting FullAccess permissions for each mailbox and writing to file"
            $MailboxDN | Get-FullAccessPerms -ADHashDN $ADHashDN -ADHash $ADHash -ADHashType $ADHashType |
            Select-Object $PermSelect
        }
    }
}
