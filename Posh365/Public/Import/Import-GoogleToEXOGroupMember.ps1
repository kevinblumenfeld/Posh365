
function Import-GoogleToEXOGroupMember {
    <#
    .SYNOPSIS
    Import CSV of Google Group Members into Office 365 as Distribution Groups

    .DESCRIPTION
    Import CSV of Google Group Members into Office 365 as Distribution Groups

    .PARAMETER LogPath
    The full path and file name of the log ex. c:\scripts\AddMembersLog.csv (use csv for best results)

    .PARAMETER Group
    Google Group(s) and respective attributes (most importantly a column of "Members")

    .EXAMPLE
    Import-Csv C:\scripts\GoogleGroups.csv | Import-GoogleToEXOGroupMember

    .NOTES

    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        $LogPath,

        [Parameter(Mandatory, ValueFromPipeline)]
        $Group

    )
    Begin {

    }
    Process {
        ForEach ($CurGroup in $Group) {

            $Member = $CurGroup.Members -split "`r`n"
            foreach ($CurMember in $Member) {

                $MemberSplat = @{
                    Identity                        = $CurGroup.Email
                    Member                          = $CurMember
                    BypassSecurityGroupManagerCheck = $True
                }

                try {
                    Add-DistributionGroupMember @MemberSplat -ErrorAction Stop
                    [PSCustomObject]@{
                        Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result          = 'SUCCESS'
                        Action          = 'ADDING'
                        Object          = 'MEMBER'
                        Member          = $CurMember
                        Name            = $CurGroup.Name
                        Email           = $CurGroup.Email
                        Message         = 'SUCCESS'
                        ExtendedMessage = 'SUCCESS'

                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    Write-HostLog -Message "Adding to Group`t$($CurGroup.Name)Member`t$($CurMember)" -Status Success
                }
                catch {
                    $Failure = $_.CategoryInfo.Reason
                    if ($_ -match 'already a member') {
                        $Failure = "$CurMember is already member of $($CurGroup.Name)"
                    }

                    if ($_ -match "Couldn't find object") {
                        $Failure = "Member $CurMember could not be found to add to $($CurGroup.Name)"
                    }
                    if ($_ -match "The operation couldn't be performed because object") {
                        $Failure = "Group $($CurGroup.Name) could not be found"
                    }
                    [PSCustomObject]@{
                        Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result          = 'FAILURE'
                        Action          = 'ADDING'
                        Object          = 'MEMBER'
                        Member          = $CurMember
                        Name            = $CurGroup.Name
                        Email           = $CurGroup.Email
                        Message         = $Failure
                        ExtendedMessage = $_.Exception.Message

                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    Write-HostLog -Message "Adding to Group`t$($CurGroup.Name)Member`t$CurMember`t$Failure" -Status Failed
                }
            }
        }
    }
    End {

    }
}
