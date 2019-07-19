function Invoke-AddMailboxMovePermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $PermissionList
    )
    process {
        foreach ($Permission in $PermissionList) {
            switch ($Permission.Location) {
                { $_ -in @('Calendar', 'Inbox', 'SentItems', 'Contacts') } {
                    write-host 'TEST'
                    $StatSplat = @{
                        Identity    = $Mailbox.PrimarySMTPAddress
                        ErrorAction = 'SilentlyContinue'
                        FolderScope = $Permission.Location
                    }
                    $Location = (($Permission.PrimarySMTPAddress) + ':\' + (Get-MailboxFolderStatistics @StatSplat | Select-Object -First 1).Name)
                    $FolderPermSplat = @{
                        Identity      = $Location
                        User          = $Permission.GrantedSMTP
                        AccessRights  = ($Permission.Permission -split ',')
                        ErrorAction   = 'Stop'
                        WarningAction = 'Stop'
                    }
                    try {
                        $null = Add-MailboxFolderPermission @FolderPermSplat
                        [PSCustomObject]@{
                            Mailbox            = $Permission.Object
                            PrimarySMTPAddress = $Permission.PrimarySMTPAddress
                            Permission         = $Permission.Permission
                            Granted            = $Permission.Granted
                            GrantedSMTP        = $Permission.GrantedSMTP
                            Type               = $Permission.Type
                            Action             = 'ADD'
                            Result             = 'SUCCESS'
                            Message            = 'SUCCESS'
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
                            Action             = 'ADD'
                            Result             = 'FAILED'
                            Message            = $_.Exception.Message
                        }
                    }
                }
                'Mailbox' {
                    switch ($Permission.Permission) {
                        'FullAccess' {
                            $FolderPermSplat = @{
                                Identity      = $Permission.PrimarySMTPAddress
                                User          = $Permission.GrantedSMTP
                                AccessRights  = 'FullAccess'
                                ErrorAction   = 'Stop'
                                WarningAction = 'Stop'
                            }
                            try {
                                $null = Add-MailboxPermission @FolderPermSplat
                                [PSCustomObject]@{
                                    Mailbox            = $Permission.Object
                                    PrimarySMTPAddress = $Permission.PrimarySMTPAddress
                                    Permission         = $Permission.Permission
                                    Granted            = $Permission.Granted
                                    GrantedSMTP        = $Permission.GrantedSMTP
                                    Type               = $Permission.Type
                                    Action             = 'ADD'
                                    Result             = 'SUCCESS'
                                    Message            = 'SUCCESS'
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
                                    Action             = 'ADD'
                                    Result             = 'FAILED'
                                    Message            = $_.Exception.Message
                                }
                            }
                        }
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

