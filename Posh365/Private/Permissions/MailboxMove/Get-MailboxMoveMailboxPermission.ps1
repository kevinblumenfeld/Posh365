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
        $ADUserList,

        [parameter()]
        [hashtable]
        $ADHashType,

        [parameter()]
        [hashtable]
        $ADHashDisplay
    )
    end {
        Write-Verbose "Caching hashtable. LogonName as Key and Values of DisplayName & UPN"
        $ADHash = $ADUserList | Get-ADHash

        Write-Verbose "Caching hashtable. DN as Key and Values of DisplayName, UPN & LogonName"
        $ADHashDN = $ADUserList | Get-ADHashDN

        Write-Verbose "Caching hashtable. CN as Key and Values of DisplayName, UPN & LogonName"
        $ADHashCN = $ADUserList | Get-ADHashCN

        $MailboxDN = $MailboxList | Select-Object -expandproperty distinguishedname

        $PermSelect = @(
            'Object', 'UserPrincipalName', 'PrimarySMTPAddress', 'Granted', 'GrantedUPN'
            'GrantedSMTP', 'Checking', 'TypeDetails', 'DisplayType', 'Permission'
        )
        $ParamSplat = @{
            ADHashDN      = $ADHashDN
            ADHash        = $ADHash
            ADHashType    = $ADHashType
            ADHashDisplay = $ADHashDisplay
        }
        $ParamSOBSplat = @{
            ADHashCN      = $ADHashCN
            ADHashDN      = $ADHashDN
            ADHashType    = $ADHashType
            ADHashDisplay = $ADHashDisplay
        }
        if (-not $SkipSendAs) {
            Write-Verbose "Getting SendAs permissions for each mailbox and writing to file"
            $MailboxDN | Get-SendAsPerms @ParamSplat |
            Select-Object $PermSelect
        }
        if (-not $SkipSendOnBehalf) {
            Write-Verbose "Getting SendOnBehalf permissions for each mailbox and writing to file"
            ($MailboxList | Where-Object { $_.GrantSendOnBehalfTo }) | Get-SendOnBehalfPerms @ParamSOBSplat |
            Select-Object $PermSelect
        }
        if (-not $SkipFullAccess) {
            Write-Verbose "Getting FullAccess permissions for each mailbox and writing to file"
            $MailboxDN | Get-FullAccessPerms @ParamSplat |
            Select-Object $PermSelect
        }
    }
}
