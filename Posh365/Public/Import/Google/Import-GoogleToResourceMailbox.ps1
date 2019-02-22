
function Import-GoogleToResourceMailbox {
    <#
    .SYNOPSIS
    Import CSV of Google Resource Mailboxes into Exchange Online as Resource Mailboxes

    .DESCRIPTION
    Import CSV of Google Resource Mailboxes into Exchange Online as Resource Mailboxes

    .PARAMETER LogPath
    The full path and file name of the log ex. c:\scripts\AddResMbxLog.csv (use csv for best results)

    .EXAMPLE
    Import-Csv .\GoogleResources.csv | Import-GoogleToResourceMailbox -LogPath .\EXOResMbxResults.csv

    .NOTES
    Run this Prior to running this script, if if hasn't already been run

    Get-ResourceConfig

    if No Resources, then add at minimum:
    Set-ResourceConfig -ResourcePropertySchema ('Room/Projector','Room/Television')

    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        $LogPath,

        [Parameter(Mandatory, ValueFromPipeline)]
        $Resource

    )
    Begin {

    }
    Process {
        ForEach ($CurResource in $Resource) {

            $Alias = ($CurResource.Email -split "@")[0]

            $ResourceType = switch ($CurResource.resourceCategory) {
                'CATEGORY_UNKNOWN' { 'ROOM' }
                'CONFERENCE_ROOM' { 'ROOM' }
            }

            $NewHash = @{
                Name               = $CurResource.Name
                DisplayName        = $CurResource.Name
                Alias              = $Alias
                PrimarySmtpAddress = $CurResource.Email
                $ResourceType      = $True
                Office             = $CurResource.BuildingName
            }

            if ($CurResource.Capacity) {
                $NewHash['ResourceCapacity'] = $CurResource.Capacity
            }

            try {
                $NewResource = New-Mailbox @NewHash -ErrorAction Stop

                [PSCustomObject]@{
                    Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result          = 'SUCCESS'
                    Action          = 'CREATING'
                    Object          = $ResourceType
                    Name            = $CurResource.Name
                    Email           = $CurResource.Email
                    FullNameError   = 'SUCCESS'
                    Message         = 'SUCCESS'
                    ExtendedMessage = 'SUCCESS'
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Creating`t$($NewResource.Name)`t$($NewResource.PrimarySmtpAddress)" -Status "Success"
                try {
                    if ($CurResource.featureInstances) {

                        $NewResource | Set-Mailbox -ResourceCustom ($CurResource.featureInstances)

                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'SUCCESS'
                            Action          = 'SETTING'
                            Object          = $ResourceType
                            Name            = $CurResource.Name
                            Email           = $CurResource.Email
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
                        Name            = $CurResource.Name
                        Email           = $CurResource.Email
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
                    Name            = $CurResource.Name
                    Email           = $CurResource.Email
                    FullNameError   = $_.Exception.GetType().fullname
                    Message         = $_.CategoryInfo.Reason
                    ExtendedMessage = $_.Exception.Message


                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Creating`t$($CurResource.Name)" -Status "Failed"
            }
        }
    }
    End {

    }
}