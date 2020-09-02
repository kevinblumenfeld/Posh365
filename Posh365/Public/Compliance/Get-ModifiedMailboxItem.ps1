function Get-ModifiedMailboxItem {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('UPN')]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserPrincipalName
    )
    process {
        Get-MailboxFolderStatistics -Identity $_ -IncludeOldestAndNewestItems |
        Sort-Object -Property OldestItemLastModifiedDate -Descending |
        Select-Object -Property @{
            Name       = 'UPN'
            Expression = { $UserPrincipalName }
        }, FolderPath, ItemsInFolder, OldestItemLastModifiedDate
    }
}
