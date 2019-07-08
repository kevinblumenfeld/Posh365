Function Get-MailboxSyncPermission {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ReportPath,

        [Parameter()]
        [switch] $SkipSendAs,

        [Parameter()]
        [switch] $SkipSendOnBehalf,

        [Parameter()]
        [switch] $SkipFullAccess,

        [Parameter()]
        [switch] $SkipFolderPerms
    )
    end {
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue

        $DelegateSplat = @{
            SkipFullAccess   = $SkipFullAccess
            SkipSendOnBehalf = $SkipSendOnBehalf
            SkipSendAs       = $SkipSendAs
        }
        if ($DelegateSplat.Values -contains $true) {
            try {
                import-module activedirectory -ErrorAction Stop -Verbose:$false
            }
            catch {
                Write-Host "This module depends on the ActiveDirectory module."
                Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
                Write-Host "or run Connect-Exchange from a server with the Active Directory Module installed"
                throw
            }
        }
        if ($DelegateSplat.Values -contains $true -or -not $SkipFolderPerms) {
            $DomainNameHash = Get-DomainNameHash

            Write-Verbose "Importing Active Directory Users and Groups that have at least one proxy address"
            $ADUserList = Get-ADUsersandGroupsWithProxyAddress -DomainNameHash $DomainNameHash
            Write-Verbose "Retrieving all Exchange Mailboxes"
            $MailboxList = Get-Mailbox -ResultSize unlimited
            $DelegateSplat.Add('MailboxList', $MailboxList)
            $DelegateSplat.Add('ADUserList', $ADUserList)
            Get-MailboxSyncDelegate @DelegateSplat | Export-Csv (Join-Path $ReportPath 'MailboxPermissions.csv') -NoTypeInformation -Encoding UTF8
        }
        if (-not $SkipFolderPerms) {
            $FolderPermSplat = @{
                MailboxList = $MailboxList
                ADUserList  = $ADUserList
            }
            Get-MailboxSyncFolderPermission @FolderPermSplat | Export-Csv (Join-Path $ReportPath 'FolderPermissions.csv') -NoTypeInformation -Encoding UTF8
        }
    }
}
