
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

            $Alias = ($Shared.Email -split "@")[0]

            $ResourceType = switch ($Shared.resourceCategory) {
                'CATEGORY_UNKNOWN' { 'ROOM' }
                'CONFERENCE_ROOM' { 'ROOM' }
            }

            $NewHash = @{
                Name               = $Shared.Name
                DisplayName        = $Shared.Name
                Alias              = $Alias
                PrimarySmtpAddress = $Shared.Email
                $ResourceType      = $True
                Office             = $Shared.BuildingName
            }

            if ($Shared.Capacity) {
                $NewHash['ResourceCapacity'] = $Shared.Capacity
            }

            try {
                $NewResource = New-Mailbox @NewHash -ErrorAction Stop

                [PSCustomObject]@{
                    Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result          = 'SUCCESS'
                    Action          = 'CREATING'
                    Object          = $ResourceType
                    Name            = $Shared.Name
                    Email           = $Shared.Email
                    FullNameError   = 'SUCCESS'
                    Message         = 'SUCCESS'
                    ExtendedMessage = 'SUCCESS'
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Creating`t$($NewResource.Name)`t$($NewResource.PrimarySmtpAddress)" -Status "Success"
                try {
                    if ($Shared.featureInstances) {

                        $NewResource | Set-Mailbox -ResourceCustom ($Shared.featureInstances)

                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'SUCCESS'
                            Action          = 'SETTING'
                            Object          = $ResourceType
                            Name            = $Shared.Name
                            Email           = $Shared.Email
                            FullNameError   = 'SUCCESS'
                            Message         = 'SUCCESS'
                            ExtendedMessage = 'SUCCESS'
                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                        Write-HostLog -Message "Setting`t$($NewResource.Name)`t$($NewResource.PrimarySmtpAddress)" -Status "Success"
                    }
                }
                catch {

                    [PSCustomObject]@{
                        Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result          = 'FAILURE'
                        Action          = 'SETTING'
                        Object          = $ResourceType
                        Name            = $Shared.Name
                        Email           = $Shared.Email
                        FullNameError   = $_.Exception.GetType().fullname
                        Message         = $_.CategoryInfo.Reason
                        ExtendedMessage = $_.Exception.Message
                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                    Write-HostLog -Message "Setting`t$($NewResource.Name)`t$($NewResource.PrimarySmtpAddress)" -Status "Failed"
                }
            }
            catch {

                [PSCustomObject]@{
                    Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result          = 'FAILURE'
                    Action          = 'CREATING'
                    Object          = $ResourceType
                    Name            = $Shared.Name
                    Email           = $Shared.Email
                    FullNameError   = $_.Exception.GetType().fullname
                    Message         = $_.CategoryInfo.Reason
                    ExtendedMessage = $_.Exception.Message


                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Creating`t$($Shared.Name)" -Status "Failed"
            }
        }
    }
    End {

    }
}