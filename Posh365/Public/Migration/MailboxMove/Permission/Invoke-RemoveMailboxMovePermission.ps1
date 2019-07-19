function Invoke-RemoveMailboxMovePermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        $PermissionList
    )
    process {
        foreach ($Permission in $PermissionList) {
            switch -regex ($Permission.Location) {
                { '(Calendar)|(Inbox)|(SentItems)|(Contacts)' } {
                    $StatSplat = @{
                        Identity    = $Mailbox.PrimarySMTPAddress
                        ErrorAction = 'SilentlyContinue'
                        FolderScope = $Permission.Location
                    }
                    $Location = (($Permission.PrimarySMTPAddress) + ":\" + (Get-MailboxFolderStatistics @StatSplat | Select-Object -First 1).Name)
                    $FolderPermSplat = @{
                        Identity    = $Location
                        User        = $Permission.GrantedSMTP
                        Confirm     = $false
                        ErrorAction = 'Stop'
                    }
                    try {
                        Remove-MailboxFolderPermission @FolderPermSplat
                        [PSCustomObject]@{
                            Mailbox            = $Permission.Object
                            PrimarySMTPAddress = $Permission.PrimarySMTPAddress
                            Permission         = $Permission.Permission
                            Granted            = $Permission.Granted
                            GrantedSMTP        = $Permission.GrantedSMTP
                            Type               = $Permission.Type
                            Action             = "REMOVE"
                            Result             = "SUCCESS"
                            Message            = "SUCCESS"
                        }
                    }
                    catch {
                        [PSCustomObject]@{
                            Mailbox            = $Permission.Object
                            PrimarySMTPAddress = $Permission.PrimarySMTPAddress
                            Permission         = $Permission.Permission
                            Granted            = $Permission.Granted
                            GrantedSMTP        = $Permission.GrantedSMTP
                            Type               = $Permission.Type
                            Action             = "REMOVE"
                            Result             = "FAILED"
                            Message            = $_.Exception.Message
                        }
                    }
                }
                'Mailbox' {
                    switch ($Permission.Permission) {
                        'FullAccess' { Write-Host 'FullAccess' }
                        'SendAs' { }
                        'SendOnBehalf' { }
                    }
                }
            }
        }
    }
    end {

    }
}
