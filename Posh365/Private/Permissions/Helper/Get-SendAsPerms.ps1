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
        [hashtable]
        $ADHashDN,

        [parameter()]
        [hashtable]
        $ADHash,

        [parameter()]
        [hashtable]
        $ADHashType,

        [parameter()]
        [hashtable]
        $ADHashDisplay
    )
    process {
        foreach ($DN in $DistinguishedName) {
            Write-Verbose "Inspecting:`t $DN"
            Get-ADPermission $DN | Where-Object {
                $_.ExtendedRights -like "*Send-As*" -and
                ($_.IsInherited -eq $false) -and
                !($_.User -like "NT AUTHORITY\SELF") -and
                !($_.User.tostring().startswith('S-1-5-21-')) -and
                !$_.Deny
            } | ForEach-Object {
                Write-Verbose "Has Send As:`t $($_.User)"
                New-Object -TypeName psobject -property @{
                    Object             = $ADHashDN["$DN"].DisplayName
                    UserPrincipalName  = $ADHashDN["$DN"].UserPrincipalName
                    PrimarySMTPAddress = $ADHashDN["$DN"].PrimarySMTPAddress
                    Granted            = $ADHash["$($_.User)"].DisplayName
                    GrantedUPN         = $ADHash["$($_.User)"].UserPrincipalName
                    GrantedSMTP        = $ADHash["$($_.User)"].PrimarySMTPAddress
                    Checking           = $_.User
                    TypeDetails        = $ADHashType."$($ADHash["$($_.User)"].msExchRecipientTypeDetails)"
                    DisplayType        = $ADHashDisplay."$($ADHash["$($_.User)"].msExchRecipientDisplayType)"
                    Permission         = "SendAs"
                }
            }
        }
    }
    end {

    }
}
