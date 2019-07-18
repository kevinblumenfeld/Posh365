Function Get-MailboxMoveOnPremisesPermissionReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ReportPath,

        [Parameter()]
        [switch]
        $SkipSendAs,

        [Parameter()]
        [switch]
        $SkipSendOnBehalf,

        [Parameter()]
        [switch]
        $SkipFullAccess,

        [Parameter()]
        [switch]
        $SkipFolderPerms
    )
    end {
        New-Item -ItemType Directory -Path $ReportPath -ErrorAction SilentlyContinue

        Write-Verbose "Caching hashtable. msExchRecipientTypeDetails numerical value as Key and Value of human readable"
        $ADHashType = Get-ADHashType

        Write-Verbose "Caching hashtable. msExchRecipientDisplayType numerical value as Key and Value of human readable"
        $ADHashDisplay = Get-ADHashDisplay

        $DelegateSplat = @{
            SkipFullAccess   = $SkipFullAccess
            SkipSendOnBehalf = $SkipSendOnBehalf
            SkipSendAs       = $SkipSendAs
            ADHashType       = $ADHashType
            ADHashDisplay    = $ADHashDisplay
            ErrorAction      = 'SilentlyContinue'
        }
        if ($DelegateSplat.Values -contains $false) {
            try {
                Import-Module ActiveDirectory -ErrorAction Stop -Verbose:$false
            }
            catch {
                Write-Host "This module depends on the ActiveDirectory module."
                Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
                Write-Host "or run Connect-Exchange from a server with the Active Directory Module installed"
                throw
            }
        }
        $DomainNameHash = Get-DomainNameHash
        Write-Verbose "Importing Active Directory Users and Groups that have at least one proxy address"

        $ADUserList = Get-ADUsersandGroupsWithProxyAddress -DomainNameHash $DomainNameHash
        Write-Verbose "Retrieving all Exchange Mailboxes"
        $MailboxList = Get-Mailbox -ResultSize unlimited
        if ($DelegateSplat.Values -contains $false) {
            $DelegateSplat.Add('MailboxList', $MailboxList)
            $DelegateSplat.Add('ADUserList', $ADUserList)
            Get-MailboxMoveMailboxPermission @DelegateSplat | Export-Csv (Join-Path $ReportPath 'MailboxPermissions.csv') -NoTypeInformation -Encoding UTF8
            $MailboxFile = Join-Path $ReportPath 'MailboxPermissions.csv'
        }
        if (-not $SkipFolderPerms) {
            $FolderPermSplat = @{
                MailboxList   = $MailboxList
                ADUserList    = $ADUserList
                ADHashType    = $ADHashType
                ADHashDisplay = $ADHashDisplay
                ErrorAction   = 'SilentlyContinue'
            }
            Get-MailboxMoveFolderPermission @FolderPermSplat | Export-Csv (Join-Path $ReportPath 'FolderPermissions.csv') -NoTypeInformation -Encoding UTF8
            $FolderFile = Join-Path $ReportPath 'FolderPermissions.csv'
        }
        $ExcelSplat = @{
            Path                    = (Join-Path $ReportPath 'Permissions.xlsx')
            TableStyle              = 'Medium2'
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $true
            ClearSheet              = $true
            ErrorAction             = 'SilentlyContinue'
        }
        $MailboxFile, $FolderFile | Where-Object { $_ } | ForEach-Object { Import-Csv $_ | Export-Excel @ExcelSplat -WorksheetName ($_ -replace '.+\\|permissions\.csv') }
    }
}
