function Get-DistributionGroupMembershipHash {
    <#
    .SYNOPSIS
        Creates a hash table from data returned from Get-DistributionGroupMembership

    .DESCRIPTION
        Creates a hash table from data returned from Get-DistributionGroupMembership

    .PARAMETER Recurse
        Reveals nested group membership

    .EXAMPLE
        "john@contoso.com" | Get-DistributionGroupMembershipHash -Recurse -Verbose
    
    .EXAMPLE
        Get-Content ./primaries.txt | Get-DistributionGroupMembershipHash -Recurse -Verbose

#>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$Identity,

        [Parameter()]
        [switch]$Recurse
    )
    begin {
        $GroupHash = @{}
    }    
    process {
        foreach ($CurIdentity in $Identity) {
            Write-Verbose "Looking up memberships for '$CurIdentity'."
            if ($Recurse) {
                $GroupHash.$CurIdentity = $CurIdentity | Get-DistributionGroupMembership -Recurse
            }
            else {
                $GroupHash.$CurIdentity = $CurIdentity | Get-DistributionGroupMembership
            }
        }
    }
    end {
        $GroupHash
    }
}