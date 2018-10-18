function Get-DistributionGroupMembersHash {
    <#
    .SYNOPSIS
        Creates a hash table from data returned from Get-DistributionGroupMembership

    .DESCRIPTION
        Creates a hash table from data returned from Get-DistributionGroupMembership

    .PARAMETER Recurse
        Reveals nested group membership

    .EXAMPLE
        "group01@contoso.com" | Get-DistributionGroupMembersHash -Recurse -Verbose
    
    .EXAMPLE
        Get-DistributionGroup -resultsize unlimited | Get-DistributionGroupMembersHash -Recurse -Verbose

    #>
    [CmdletBinding()]
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
                $GroupHash[$CurIdentity] = $CurIdentity | Get-DistributionGroupMembers -Recurse
            }
            else {
                $GroupHash[$CurIdentity] = $CurIdentity | Get-DistributionGroupMembers
            }
        }
    }
    end {
        $GroupHash
    }
}
