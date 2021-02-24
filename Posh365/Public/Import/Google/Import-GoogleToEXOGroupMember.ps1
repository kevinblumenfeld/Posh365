
function Import-GoogleToEXOGroupMember {
    <#
    .SYNOPSIS
    Import CSV of Google Group Members into Office 365 as Distribution Groups

    .DESCRIPTION
    Import CSV of Google Group Members into Office 365 as Distribution Groups

    .PARAMETER Group
    Google Group(s) and respective attributes (most importantly a column of "Members")

    .EXAMPLE
    Import-Csv C:\scripts\GoogleGroups.csv | Import-GoogleToEXOGroupMember

    .NOTES

    #>

    [CmdletBinding()]
    Param
    (

        [Parameter(Mandatory, ValueFromPipeline)]
        $GroupList

    )
    Begin {

    }
    Process {
        ForEach ($Group in $GroupList) {

            if ($Group.Members) {

                $MemberList = $Group.Members.Split('|')

                foreach ($Member in $MemberList) {

                    $MemberSplat = @{
                        Identity                        = $Group.Email
                        Member                          = $Member
                        BypassSecurityGroupManagerCheck = $True
                    }

                    try {

                        Add-DistributionGroupMember @MemberSplat -ErrorAction Stop

                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'SUCCESS'
                            Action          = 'ADDING'
                            Object          = 'MEMBER'
                            Member          = $Member
                            Name            = $Group.Name
                            Email           = $Group.Email
                            Message         = 'SUCCESS'
                            ExtendedMessage = 'SUCCESS'

                        }

                        Write-HostLog -Message "Adding to Group`t$($Group.Name) Member`t$($Member)" -Status "Success"
                    }
                    catch {

                        $Failure = $_.CategoryInfo.Reason

                        if ($_ -match 'already a member') {

                            $Failure = "$Member is already member of $($Group.Name)"
                        }

                        if ($_ -match "Couldn't find object") {

                            $Failure = "Member $Member could not be found to add to $($Group.Name)"
                        }
                        if ($_ -match "The operation couldn't be performed because object") {

                            $Failure = "Group $($Group.Name) could not be found"
                        }
                        [PSCustomObject]@{
                            Time            = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result          = 'FAILURE'
                            Action          = 'ADDING'
                            Object          = 'MEMBER'
                            Member          = $Member
                            Name            = $Group.Name
                            Email           = $Group.Email
                            Message         = $Failure
                            ExtendedMessage = $_.Exception.Message

                        }
                        Write-HostLog -Message "Adding to Group`t$($Group.Name)Member`t$Member`t$Failure" -Status "Failed"
                    }
                }
            }
        }
    }
}
