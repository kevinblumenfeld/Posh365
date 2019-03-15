
function Import-GoogleAliasToEXOMailbox {
    <#
.SYNOPSIS
Imports Aliases (Google calls secondary email addresses Aliases) to existing Cloud-Only Mailboxes

.DESCRIPTION
Imports Aliases (Google calls secondary email addresses Aliases) to existing Cloud-Only Mailboxes

.PARAMETER LogPath
Success/Failed results logged to this file (use .csv)

.PARAMETER AliasList
List of Aliases. Fed by Pipeline. The format expected is at least 2 headers.
One Mandatory header in this csv is PrimarySmtpAddress and the other is Alias

.EXAMPLE
Import-Csv .\Shared-Aliases.csv | Import-GoogleAliasToEXOMailbox -LogPath .\AddDetail-Alias-Log.csv

.EXAMPLE
Import-Csv .\MailboxAlias.csv | Import-GoogleAliasToEXOMailbox -LogPath .\AddDetail-Alias-Log.csv
.NOTES
General notes
#>

    [CmdletBinding()]
    Param
    (

        [Parameter(Mandatory)]
        $LogPath,

        [Parameter(Mandatory, ValueFromPipeline)]
        $AliasList

    )
    Begin {

    }
    Process {

        foreach ($Alias in $AliasList) {
            try {
                $AliasSplat = @{
                    Identity       = $Alias.PrimarySmtpAddress
                    EmailAddresses = @{add = "smtp:$($Alias.Alias)"}
                    ErrorAction    = 'Stop'
                }

                Set-Mailbox @AliasSplat

                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'SUCCESS'
                    Action             = 'ADDINGALIAS'
                    Object             = 'MAILBOX'
                    PrimarySmtpAddress = $Alias.PrimarySmtpAddress
                    Alias              = $Alias.Alias
                    FullNameError      = 'SUCCESS'
                    Message            = 'SUCCESS'
                    ExtendedMessage    = 'SUCCESS'
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Adding Mailbox Alias`t$($Alias.PrimarySmtpAddress)`t$($Alias.Alias)" -Status "Success"
            }
            catch {
                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'FAILED'
                    Action             = 'ADDINGALIAS'
                    Object             = 'MAILBOX'
                    PrimarySmtpAddress = $Alias.PrimarySmtpAddress
                    Alias              = $Alias.Alias
                    FullNameError      = $_.Exception.GetType().fullname
                    Message            = $_.CategoryInfo.Reason
                    ExtendedMessage    = $_.Exception.Message
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Adding Mailbox Alias`t$($Alias.PrimarySmtpAddress)`t$($Alias.Alias)" -Status "Failed"
            }
        }
    }
    End {

    }
}