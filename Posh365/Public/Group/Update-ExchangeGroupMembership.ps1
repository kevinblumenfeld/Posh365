
function Update-ExchangeGroupMembership {

    <#
    .SYNOPSIS
    This will remove all members from all groups (that are fed via the pipeline).

    .DESCRIPTION
    This will remove all members from all groups (that are fed via the pipeline).
    Then add an updated list of members from the same list.

    .PARAMETER LogPath
    Log of all success and failures

    .PARAMETER NewMemberCSV
    List of (new) members and groups to which they will be added

    .PARAMETER GroupList
    Pipeline input of a list of (new) members and groups to which they will be added

    .EXAMPLE
    $Groups = Import-Csv .\GroupsAndMembers.csv | Sort -Property Group -Unique
    $Groups | Update-ExchangeGroupMembership -LogPath .\MemberLog.csv -NewMemberCSV .\GroupsAndMembers.csv

    .EXAMPLE
    Import-Csv .\GroupsUnique.csv | Update-ExchangeGroupMembership -LogPath .\MemberLog.csv -NewMemberCSV .\Groups.csv

    .NOTES
    Use with caution as this will remove all the members to all the groups you tell it to!!
    #>


    [CmdletBinding()]
    Param
    (

        [Parameter(Mandatory)]
        $LogPath,

        [Parameter(Mandatory)]
        $NewMemberCSV,

        [Parameter(Mandatory, ValueFromPipeline)]
        $GroupList

    )
    begin {
        $NewMemberList = Import-Csv $NewMemberCSV

        $NewMemberHash = @{ }

        foreach ($NewMember in $NewMemberList) {
            if (-not $NewMemberHash.Contains($NewMember.Group)) {
                $NewMemberHash[$NewMember.Group] = [system.collections.arraylist]::new()
            }
            $null = $NewMemberHash[$NewMember.Group].Add($NewMember.Email)
        }
    }
    process {
        foreach ($Group in $GroupList) {
            try {
                $GetSplat = @{
                    Identity    = $Group.Group
                    erroraction = "stop"
                }

                $MemberList = Get-DistributionGroupMember @GetSplat

                Write-Host "`n"
                Write-Host "Found group: `t`t $($Group.Group)" -ForegroundColor Magenta

                foreach ($Member in $MemberList) {

                    Write-Host "Found member: `t`t $($Member.DisplayName) `t $($Member.PrimarySmtpAddress)"  -ForegroundColor Magenta

                    [PSCustomObject]@{
                        Action               = 'GETGROUPMEMBERSHIP'
                        Result               = 'SUCCESS'
                        Group                = $Group.Group
                        Member               = $Member.PrimarySmtpAddress
                        DisplayName          = $Member.DisplayName
                        Identity             = $Member.Identity
                        RecipientTypeDetails = $Member.RecipientTypeDetails
                        Guid                 = $Member.Guid
                        ExtendedMessage      = 'SUCCESS'
                        Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                    try {
                        $RemoveSplat = @{
                            Identity    = $Group.Group
                            Member      = [string]$Member.Guid
                            Confirm     = $false
                            erroraction = "stop"
                        }

                        Remove-DistributionGroupMember @RemoveSplat
                        Write-Host "Removed member: `t $($Member.DisplayName) `t $($Member.PrimarySmtpAddress)" -ForegroundColor Yellow

                        [PSCustomObject]@{
                            Action               = 'REMOVEGROUPMEMBER'
                            Result               = 'SUCCESS'
                            Group                = $Group.Group
                            Member               = $Member.PrimarySmtpAddress
                            DisplayName          = $Member.DisplayName
                            Identity             = $Member.Identity
                            RecipientTypeDetails = $Member.RecipientTypeDetails
                            Guid                 = $Member.Guid
                            ExtendedMessage      = 'SUCCESS'
                            Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    }
                    catch {
                        Write-Host "Failed to remove member: `t $($Member.PrimarySmtpAddress)" -ForegroundColor Red
                        [PSCustomObject]@{
                            Action               = 'REMOVEGROUPMEMBER'
                            Result               = 'FAILED'
                            Group                = $Group.Group
                            Member               = $Member.PrimarySmtpAddress
                            DisplayName          = $Member.DisplayName
                            Identity             = $Member.Identity
                            RecipientTypeDetails = $Member.RecipientTypeDetails
                            Guid                 = $Member.Guid
                            ExtendedMessage      = $_.Exception.Message
                            Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    }
                }
                foreach ($New in $NewMemberHash[$Group.Group]) {
                    try {
                        $AddSplat = @{
                            Identity    = $Group.Group
                            Member      = $New
                            erroraction = "stop"
                        }

                        Add-DistributionGroupMember @AddSplat
                        Write-Host "New member added: `t $New" -ForegroundColor Green

                        [PSCustomObject]@{
                            Action               = 'ADDGROUPMEMBER'
                            Result               = 'SUCCESS'
                            Group                = $Group.Group
                            Member               = $Member.PrimarySmtpAddress
                            DisplayName          = $Member.DisplayName
                            Identity             = $Member.Identity
                            RecipientTypeDetails = $Member.RecipientTypeDetails
                            Guid                 = $Member.Guid
                            ExtendedMessage      = 'SUCCESS'
                            Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    }

                    catch {
                        Write-Host "Failed to add new member: `t $New" -ForegroundColor Red

                        [PSCustomObject]@{
                            Action               = 'ADDGROUPMEMBER'
                            Result               = 'FAILED'
                            Group                = $Group.Group
                            Member               = $New
                            DisplayName          = 'FAILED'
                            Identity             = 'FAILED'
                            RecipientTypeDetails = 'FAILED'
                            Guid                 = 'FAILED'
                            ExtendedMessage      = $_.Exception.Message
                            Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    }
                }
            }
            catch {
                Write-Host "Group lookup failed: `t $($Group.Group)" -ForegroundColor Red

                [PSCustomObject]@{
                    Action               = 'GETGROUPMEMBERSHIP'
                    Result               = 'FAILED'
                    Group                = $Group.Group
                    Member               = "GROUPNOTFOUND"
                    DisplayName          = "GROUPNOTFOUND"
                    Identity             = "GROUPNOTFOUND"
                    RecipientTypeDetails = "GROUPNOTFOUND"
                    Guid                 = "GROUPNOTFOUND"
                    ExtendedMessage      = $_.Exception.Message
                    Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append
            }
        }
    }
    end {

    }
}