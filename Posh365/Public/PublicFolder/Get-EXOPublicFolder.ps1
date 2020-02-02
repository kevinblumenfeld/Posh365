function Get-EXOPublicFolder {
    param (

    )
    end {
        $FolderList = Get-PublicFolder -Recurse -Resultsize unlimited
        foreach ($Folder in $FolderList) {
            $FolderStatsList = Get-PublicFolderStatistics $Folder.Identity
            foreach ($FolderStats in $FolderStatsList) {
                if ($Folder.MailEnabled) {
                    [PSCustomObject]@{
                        FolderName         = $Folder.name
                        Identity           = $Folder.Identity
                        LastModified       = $FolderStats.LastModificationTime
                        Created            = $FolderStats.CreationTime
                        ItemCount          = $FolderStats.ItemCount
                        SizeMB             = [Math]::Round([Double]($FolderStats.TotalItemSize -replace '^.*\(| .+$|,') / 1MB, 4)
                        MailEnabled        = $Folder.MailEnabled
                        PrimarySmtpAddress = (Get-Recipient $Folder.MailRecipientGuid.ToString()).PrimarySmtpAddress
                        Owner              = @((Get-PublicFolderClientPermission $Folder.Identity | Where-Object { $_.accessrights -like "*owner*" }).User.ADRecipient.PrimarySmtpAddress) -ne '' -join '|'
                    }
                }
                else {
                    [PSCustomObject]@{
                        FolderName         = $Folder.name
                        Identity           = $Folder.Identity
                        LastModified       = $FolderStats.LastModificationTime
                        Created            = $FolderStats.CreationTime
                        ItemCount          = $FolderStats.ItemCount
                        SizeMB             = [Math]::Round([Double]($FolderStats.TotalItemSize -replace '^.*\(| .+$|,') / 1MB, 4)
                        MailEnabled        = $Folder.MailEnabled
                        PrimarySmtpAddress = ""
                        Owner              = @((Get-PublicFolderClientPermission $Folder.Identity | Where-Object { $_.accessrights -like "*owner*" }).User.ADRecipient.PrimarySmtpAddress) -ne '' -join '|'
                    }
                }
            }
        }
    }
}
