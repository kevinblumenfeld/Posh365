function Get-DistributionGroupMembership {
    <#
    .SYNOPSIS
        Determines the Groups that a recipient is a member of.  Either recursively or not.
        Original function developed my Mark Kraus.  https://www.reddit.com/r/PowerShell/comments/5ndp4n/get_all_distribution_groups_for_a_user_with/
        Check out his blog here: https://get-powershellblog.blogspot.com

    .DESCRIPTION
        Determines the Groups that a recipient is a member of.  Either recursively or not.

    .PARAMETER Recurse
        Reveals nested group membership

    .PARAMETER Processed
        Parameter used internally by function to hold those that have been processed (loopback detection)

    .EXAMPLE
        Get-Recipient pat@contoso.com | Get-DistributionGroupMembership -Recurse

    .EXAMPLE
        Get-Recipient pat@contoso.com | Get-DistributionGroupMembership -Recurse -Verbose

    .EXAMPLE
        Get-Recipient pat@contoso.com | Get-DistributionGroupMembership -Recurse | Export-Csv .\membership.csv -notypeinformation

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Identity,

        [Parameter()]
        [switch]$Recurse,

        [Parameter()]
        [System.Collections.Generic.List[string[]]]$Processed
    )
    begin {
        if (-not $processed) {
            $Processed = [System.Collections.Generic.List[string[]]]::New()
        }
    }
    process {
        foreach ($Item in $Identity) {
            Write-Verbose "Looking up memberships for '$Item'."
            try {
                $Recipient = $null
                $Recipient = Get-Recipient -Identity $Item -ErrorAction Stop
                Write-Host ("R: {0}" -f $Recipient.DisplayName) -ForegroundColor Cyan
                Write-Host ("T: {0}" -f $Recipient.RecipientTypeDetails) -ForegroundColor Cyan
                Write-Host ("E: {0}" -f $Recipient.PrimarySmtpAddress) -ForegroundColor Cyan
            }
            catch {
                Write-Error "Unable to find recipient '{0}': {1}" -f $Item, $_.exception.message
                continue
            }

            Write-Verbose "Adding '$($Recipient.PrimarySmtpAddress)' to processed list"
            $Processed.Add($Recipient.PrimarySmtpAddress.ToString())

            $GroupObject = [System.Collections.Generic.List[PSObject]]::New()

            $Filter = "members -eq '{0}'" -f $Recipient.DistinguishedName
            $GroupList = Get-Group -ResultSize Unlimited -filter $Filter
            foreach ($Group in $GroupList) {
                if ($Group.RecipientTypeDetails -notin 'NonUniversalGroup', 'GroupMailbox', 'RoleGroup' -and $Group.WindowsEmailAddress -notin $Processed) {
                    [PSCustomObject]@{
                        DisplayName             = $Recipient.DisplayName
                        Identity                = $Item
                        PrimarySmtpAddress      = $Recipient.PrimarySmtpAddress
                        RecipientType           = $Recipient.RecipientTypeDetails
                        RecipientTypeDetails    = $Group.RecipientTypeDetails
                        Group                   = $Group.DisplayName
                        GroupPrimarySmtpAddress = $Group.WindowsEmailAddress
                        Guid                    = $Group.Guid.ToString()
                        GroupType               = $Group.GroupType
                    }
                    $GroupObject.Add($Group)
                }
            }
            if (-not $Recurse) {
                continue
            }
            foreach ($GroupObj in $GroupObject) {
                #Skip "Office 365 Groups" as they fail recipient checks and cannot be members of other groups
                if ($GroupObj.RecipientTypeDetails -in 'NonUniversalGroup', 'GroupMailbox', 'RoleGroup') {
                    continue
                }
                Write-Host ("Start recursing for '{0}'." -f $GroupObj.WindowsEmailAddress) -ForegroundColor Green
                Get-DistributionGroupMembership -Identity $GroupObj.Guid.ToString() -Recurse -Processed $Processed
                Write-Verbose "Done recursing for '$($GroupObj.WindowsEmailAddress)'."
            }
        }
    }
}
