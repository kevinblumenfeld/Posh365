
function Import-GoogleToSharedMailbox {
    <#

    .SYNOPSIS
    Import CSV of Google Shared Mailboxes into Exchange Online as Shared Mailboxes

    .DESCRIPTION
    Import CSV of Google Shared Mailboxes into Exchange Online as Shared Mailboxes

    .PARAMETER LogPath
    The full path and file name of the log ex. c:\scripts\AddSharedMbxLog.csv (use csv for best results)

    .EXAMPLE
    Import-Csv .\GoogleShared.csv | Import-GoogleToSharedMailbox -LogPath .\EXOSharedMbxResults.csv

    .EXAMPLE
    Import-Csv .\Shared-Intial_and_Phone.csv | Import-GoogleToSharedMailbox -LogPath .\SharedMailboxCreation.csv

    .NOTES

    #>

    [CmdletBinding()]
    Param
    (

        [Parameter(Mandatory)]
        $LogPath,

        [Parameter(Mandatory, ValueFromPipeline)]
        $SharedList

    )
    Begin {

    }
    Process {
        ForEach ($Shared in $SharedList) {

            $Alias = ($Shared.PrimarySmtpAddress -split "@")[0]

            $NewSharedSplat = @{
                Name               = $Shared.DisplayName
                DisplayName        = $Shared.DisplayName
                FirstName          = $Shared.FirstName
                LastName           = $Shared.LastName
                Alias              = $Alias
                PrimarySmtpAddress = $Shared.PrimarySmtpAddress
                Shared             = $True
                ErrorAction        = 'Stop'
            }

            try {
                $NewShared = New-Mailbox @NewSharedSplat

                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'SUCCESS'
                    Action             = 'CREATING'
                    Object             = $NewShared.RecipientTypeDetails
                    Name               = $NewShared.Name
                    Alias              = $NewShared.Alias
                    UserPrincipalName  = $NewShared.UserPrincipalName
                    PrimarySmtpAddress = $NewShared.PrimarySmtpAddress
                    EmailAddresses     = [string]::join('|', [string[]]$NewShared.EmailAddresses)
                    ObjectId           = $NewShared.ExternalDirectoryObjectId
                    FullNameError      = 'SUCCESS'
                    Message            = 'SUCCESS'
                    ExtendedMessage    = 'SUCCESS'
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Creating Mailbox`t$($NewShared.Name)`t$($NewShared.PrimarySmtpAddress)" -Status "Success"

            }
            catch {

                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'FAILED'
                    Action             = 'CREATING'
                    Object             = 'SHAREDMAILBOX'
                    Name               = $Shared.DisplayName
                    Alias              = $Alias
                    UserPrincipalName  = 'FAILED'
                    PrimarySmtpAddress = $Shared.PrimarySmtpAddress
                    EmailAddresses     = 'FAILED'
                    ObjectId           = 'FAILED'
                    FullNameError      = $_.Exception.GetType().fullname
                    Message            = $_.CategoryInfo.Reason
                    ExtendedMessage    = $_.Exception.Message
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Creating Mailbox`t$($Shared.DisplayName)" -Status "Failed"
            }
        }
    }
    End {

    }
}