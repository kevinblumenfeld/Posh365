
function Remove-ExchangeGroupMember {

    <#
    .SYNOPSIS
    This will remove all members from all groups that are fed via the pipeline. Then add the new members from the same list.

    .DESCRIPTION
    This will remove all members from all groups that are fed via the pipeline. Then add the new members from the same list.

    .PARAMETER LogPath
    Log of all success and failures

    .PARAMETER NewMemberCSV
    List of (new) members and groups to which they will be added

    .PARAMETER GroupList
    Pipeline input of a list of (new) members and groups to which they will be added

    .EXAMPLE
    Import-Csv .\Groups.csv| Remove-ExchangeGroupMember -LogPath .\MemberLog.csv -NewMemberCSV .\Groups.csv

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
    Begin {
        $NewMemberList = Import-Csv $NewMemberCSV
        $NewMemberHash = @{ }
        foreach ($NewMember in $NewMemberList) {
            if (-not $NewMemberHash.Contains($NewMember.PrimarySMTPAddress)) {
                $NewMemberHash[$NewMember.PrimarySmtpAddress] = [system.collections.arraylist]::new()
            }
            $null = $NewMemberHash[$NewMember.PrimarySmtpAddress].Add($NewMember.MemberEmail)
        }
        $NewMemberHash
    }
    Process {

        ForEach ($Group in $GroupList) {
            try {
                $MemberList = Get-DistributionGroupMember -identity $Group.PrimarySmtpAddress -erroraction stop
                Write-Host "Found group: `t $($Group.PrimarySmtpAddress)" -ForegroundColor White
                # Remote Members
                foreach ($Member in $MemberList) {
                    Write-Host "Found member: `t $($Member.PrimarySmtpAddress)" -ForegroundColor White
                    [PSCustomObject]@{
                        Group                = $Group.PrimarySmtpAddress
                        Member               = $Member.PrimarySmtpAddress
                        DisplayName          = $Member.DisplayName
                        Identity             = $Member.Identity
                        EmailAddresses       = [string]::join("|", [String[]]$Member.EmailAddresses -ne '')
                        Name                 = $Member.Name
                        RecipientTypeDetails = $Member.RecipientTypeDetails
                        Guid                 = $Member.Guid
                        Action               = 'GETGROUPMEMBERSHIP'
                        Result               = 'SUCCESS'
                        ExtendedMessage      = 'SUCCESS'
                        Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")

                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    try {
                        [string]$Guid = $Member.Guid
                        Remove-DistributionGroupMember -Identity $Group.PrimarySmtpAddress -Member $Guid -erroraction stop
                        Write-Host "Removed member: `t $($Member.PrimarySmtpAddress)" -ForegroundColor Green
                        [PSCustomObject]@{
                            Group                = $Group.PrimarySmtpAddress
                            Member               = $Member.PrimarySmtpAddress
                            DisplayName          = $Member.DisplayName
                            Identity             = $Member.Identity
                            EmailAddresses       = [string]::join("|", [String[]]$Member.EmailAddresses -ne '')
                            Name                 = $Member.Name
                            RecipientTypeDetails = $Member.RecipientTypeDetails
                            Guid                 = $Member.Guid
                            Action               = 'REMOVEGROUPMEMBER'
                            Result               = 'SUCCESS'
                            ExtendedMessage      = 'SUCCESS'
                            Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")

                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    }
                    catch {
                        Write-Host "Failed to remove member: `t $($Member.PrimarySmtpAddress)" -ForegroundColor Red
                        [PSCustomObject]@{
                            Group                = $Group.PrimarySmtpAddress
                            Member               = $Member.PrimarySmtpAddress
                            DisplayName          = $Member.DisplayName
                            Identity             = $Member.Identity
                            EmailAddresses       = [string]::join("|", [String[]]$Member.EmailAddresses -ne '')
                            Name                 = $Member.Name
                            RecipientTypeDetails = $Member.RecipientTypeDetails
                            Guid                 = $Member.Guid
                            Action               = 'REMOVEGROUPMEMBER'
                            Result               = 'FAILED'
                            ExtendedMessage      = $_.Exception.Message
                            Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")

                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    }
                }
                # Removal complete
                # Add New Members
                try {
                    foreach ($New in $NewMemberHash[$Group.PrimarySmtpAddress]) {
                        Add-DistributionGroupMember -Identity $Group.PrimarySmtpAddress -Member $New -erroraction stop
                        Write-Host "New member added: `t $New" -ForegroundColor Green
                        [PSCustomObject]@{
                            Group                = $Group.PrimarySmtpAddress
                            Member               = $Member.PrimarySmtpAddress
                            DisplayName          = $Member.DisplayName
                            Identity             = $Member.Identity
                            EmailAddresses       = [string]::join("|", [String[]]$Member.EmailAddresses -ne '')
                            Name                 = $Member.Name
                            RecipientTypeDetails = $Member.RecipientTypeDetails
                            Guid                 = $Member.Guid
                            Action               = 'ADDGROUPMEMBER'
                            Result               = 'SUCCESS'
                            ExtendedMessage      = 'SUCCESS'
                            Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")

                        } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                    }
                }
                catch {
                    Write-Host "Failed to add new member: `t $New" -ForegroundColor Red
                    [PSCustomObject]@{
                        Group                = $Group.PrimarySmtpAddress
                        Member               = $Member.PrimarySmtpAddress
                        DisplayName          = $Member.DisplayName
                        Identity             = $Member.Identity
                        EmailAddresses       = [string]::join("|", [String[]]$Member.EmailAddresses -ne '')
                        Name                 = $Member.Name
                        RecipientTypeDetails = $Member.RecipientTypeDetails
                        Guid                 = $Member.Guid
                        Action               = 'ADDGROUPMEMBER'
                        Result               = 'FAILED'
                        ExtendedMessage      = $_.Exception.Message
                        Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")

                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                }
            }
            catch {
                Write-Host "Group lookup failed: `t $($Group.PrimarySmtpAddress)" -ForegroundColor Red
                [PSCustomObject]@{
                    Group                = $Group.PrimarySmtpAddress
                    Member               = "GROUPNOTFOUND"
                    DisplayName          = "GROUPNOTFOUND"
                    Identity             = "GROUPNOTFOUND"
                    EmailAddresses       = "GROUPNOTFOUND"
                    Name                 = "GROUPNOTFOUND"
                    RecipientTypeDetails = "GROUPNOTFOUND"
                    Guid                 = "GROUPNOTFOUND"
                    Action               = 'GETGROUPMEMBERSHIP'
                    Result               = 'FAILED'
                    ExtendedMessage      = $_.Exception.Message
                    Time                 = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append
                if ($_.Exception.Message -like "*couldn't be found on*") {
                    # New-DistributionGroup
                }
            }

        }

    }
    End {

    }
}