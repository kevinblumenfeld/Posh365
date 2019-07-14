function Get-FullAccessPerms {
    <#
    .SYNOPSIS
    Outputs Full Access permissions for each object that has permissions assigned.
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
    begin {

    }
    process {
        foreach ($DN in $DistinguishedName) {
            Write-Verbose "Inspecting:`t $DN"
            Get-MailboxPermission $DN |
            Where-Object {
                $_.AccessRights -like "*FullAccess*" -and
                !$_.IsInherited -and !$_.user.tostring().startswith('S-1-5-21-') -and
                !$_.user.tostring().startswith('NT AUTHORITY\SELF') -and
                !$_.Deny
            } | ForEach-Object {
                Write-Verbose "Has Full Access:`t$($_.User)"
                New-Object -TypeName psobject -property @{
                    Object             = $ADHashDN["$DN"].DisplayName
                    UserPrincipalName  = $ADHashDN["$DN"].UserPrincipalName
                    PrimarySMTPAddress = $ADHashDN["$DN"].PrimarySMTPAddress
                    Granted            = $ADHash["$($_.User)"].DisplayName
                    GrantedUPN         = $ADHash["$($_.User)"].UserPrincipalName
                    GrantedSMTP        = $ADHash["$($_.User)"].PrimarySMTPAddress
                    Checking           = $($_.User)
                    Permission         = "FullAccess"
                }
            }
        }
    }
    end {

    }
}
