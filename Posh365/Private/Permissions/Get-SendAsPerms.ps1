function Get-SendAsPerms {
    <#
    .SYNOPSIS
    Outputs Send As permissions for each mailbox that has permissions assigned.
    This is for On-Premises Exchange 2010, 2013, 2016+

    .EXAMPLE

    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DistinguishedName,

        [parameter()]
        [hashtable] $ADHashDN,

        [parameter()]
        [hashtable] $ADHash
    )

    process {
        foreach ($DN in $DistinguishedName) {
            Write-Verbose "Inspecting: `t $DN"
            Get-ADPermission $DN | Where-Object {
                $_.ExtendedRights -like "*Send-As*" -and
                ($_.IsInherited -eq $false) -and
                !($_.User -like "NT AUTHORITY\SELF") -and
                !($_.User.tostring().startswith('S-1-5-21-')) -and
                !$_.Deny
            } | ForEach-Object {
                Write-Verbose "Has Send As:`t $($_.User)"
                Get-ADGroupMember ($_.user -split "\\")[1] -Recursive -ErrorAction stop |
                ForEach-Object {
                    New-Object -TypeName psobject -property @{
                        Object             = $ADHashDN["$DN"].DisplayName
                        UserPrincipalName  = $ADHashDN["$DN"].UserPrincipalName
                        PrimarySMTPAddress = $ADHashDN["$DN"].PrimarySMTPAddress
                        Granted            = $ADHashDN["$($_.distinguishedname)"].DisplayName
                        GrantedUPN         = $ADHashDN["$($_.distinguishedname)"].UserPrincipalName
                        GrantedSMTP        = $ADHashDN["$($_.distinguishedname)"].PrimarySMTPAddress
                        Checking           = $($_.User)
                        GroupMember        = $($_.distinguishedname)
                        Type               = "GroupMember"
                        Permission         = "SendAs"
                    }
                }
            }
        }
    }
    end {

    }
}
