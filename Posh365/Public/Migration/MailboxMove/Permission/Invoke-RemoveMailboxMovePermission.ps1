function Invoke-RemoveMailboxMovePermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        $PermissionList
    )
    process {
        foreach ($Permission in $PermissionList) {
            switch ($Permission.Location) {
                { $_ -in @('Calendar', 'Inbox', 'SentItems', 'Contacts') } {
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
                            Message            = ($_.Exception.Message -replace 'The running command stopped because the preference variable "WarningPreference" or common parameter is set to Stop: ', '')
                        }
                    }
                }
                'Mailbox' {
                    switch ($Permission.Permission) {
                        'FullAccess' {
                            $FullAccessSplat = @{
                                Identity      = $Permission.PrimarySMTPAddress
                                User          = $Permission.GrantedSMTP
                                Confirm       = $false
                                AccessRights  = 'FullAccess'
                                ErrorAction   = 'Stop'
                                WarningAction = 'Stop'
                            }
                            try {
                                $null = Remove-MailboxPermission @FullAccessSplat
                                [PSCustomObject]@{
                                    Mailbox            = $Permission.Object
                                    PrimarySMTPAddress = $Permission.PrimarySMTPAddress
                                    Permission         = $Permission.Permission
                                    Granted            = $Permission.Granted
                                    GrantedSMTP        = $Permission.GrantedSMTP
                                    Type               = $Permission.Type
                                    Action             = 'REMOVE'
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
                                    Action             = 'REMOVE'
                                    Result             = 'FAILED'
                                    Message            = ($_.Exception.Message -replace 'The running command stopped because the preference variable "WarningPreference" or common parameter is set to Stop: ', '')
                                }
                            }
                        }
                        'SendAs' {
                            $SendAsSplat = @{
                                Identity      = $Permission.PrimarySMTPAddress
                                Trustee       = $Permission.GrantedSMTP
                                AccessRights  = 'SendAs'
                                Confirm       = $false
                                ErrorAction   = 'Stop'
                                WarningAction = 'Stop'
                            }
                            try {
                                $null = Remove-RecipientPermission @SendAsSplat
                                [PSCustomObject]@{
                                    Mailbox            = $Permission.Object
                                    PrimarySMTPAddress = $Permission.PrimarySMTPAddress
                                    Permission         = $Permission.Permission
                                    Granted            = $Permission.Granted
                                    GrantedSMTP        = $Permission.GrantedSMTP
                                    Type               = $Permission.Type
                                    Action             = 'REMOVE'
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
                                    Action             = 'REMOVE'
                                    Result             = 'FAILED'
                                    Message            = ($_.Exception.Message -replace 'The running command stopped because the preference variable "WarningPreference" or common parameter is set to Stop: ', '')
                                }
                            }
                        }
                        'SendOnBehalf' {
                            $SOBSplat = @{
                                Identity            = $Permission.PrimarySMTPAddress
                                GrantSendOnBehalfTo = $null
                                ErrorAction         = 'Stop'
                                WarningAction       = 'Stop'
                            }
                            try {
                                $null = Set-Mailbox @SOBSplat
                                [PSCustomObject]@{
                                    Mailbox            = $Permission.Object
                                    PrimarySMTPAddress = $Permission.PrimarySMTPAddress
                                    Permission         = $Permission.Permission
                                    Granted            = $Permission.Granted
                                    GrantedSMTP        = $Permission.GrantedSMTP
                                    Type               = $Permission.Type
                                    Action             = 'REPLACE'
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
                                    Action             = 'REPLACE'
                                    Result             = 'FAILED'
                                    Message            = ($_.Exception.Message -replace 'The running command stopped because the preference variable "WarningPreference" or common parameter is set to Stop: ', '')
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    end {

    }
}
