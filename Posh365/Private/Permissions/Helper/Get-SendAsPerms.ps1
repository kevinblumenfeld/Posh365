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
        $ADHashDisplay,

        [parameter()]
        [hashtable]
        $UserGroupHash,

        [parameter()]
        [hashtable]
        $GroupMemberHash
    )
    process {
        foreach ($ADUser in $DistinguishedName) {
            Write-Verbose "Inspecting:`t $ADUser"
            Get-ADPermission $ADUser | Where-Object {
                $_.ExtendedRights -like "*Send-As*" -and
                ($_.IsInherited -eq $false) -and
                !($_.User -like "NT AUTHORITY\SELF") -and
                !($_.User.tostring().startswith('S-1-5-21-')) -and
                !$_.Deny
            } | ForEach-Object {
                $HasPerm = $_.User
                if ($GroupMemberHash[$HasPerm].Members -and
                    $ADHashDisplay."$($ADHash["$HasPerm"].msExchRecipientDisplayType)" -match 'group') {
                    foreach ($Member in @($GroupMemberHash[$HasPerm].Members)) {
                        New-Object -TypeName psobject -property @{
                            Object             = $ADHashDN["$ADUser"].DisplayName
                            UserPrincipalName  = $ADHashDN["$ADUser"].UserPrincipalName
                            PrimarySMTPAddress = $ADHashDN["$ADUser"].PrimarySMTPAddress
                            Granted            = $UserGroupHash[$Member].DisplayName
                            GrantedUPN         = $UserGroupHash[$Member].UserPrincipalName
                            GrantedSMTP        = $UserGroupHash[$Member].PrimarySMTPAddress
                            Checking           = $HasPerm
                            TypeDetails        = "GroupMember"
                            DisplayType        = $ADHashDisplay."$($ADHash["$HasPerm"].msExchRecipientDisplayType)"
                            Permission         = "SendAs"
                        }
                    }
                }
                elseif ( $ADHash["$HasPerm"].objectClass -notmatch 'group') {
                    Write-Verbose "Has Send As:`t $($HasPerm)"
                    New-Object -TypeName psobject -property @{
                        Object             = $ADHashDN["$ADUser"].DisplayName
                        UserPrincipalName  = $ADHashDN["$ADUser"].UserPrincipalName
                        PrimarySMTPAddress = $ADHashDN["$ADUser"].PrimarySMTPAddress
                        Granted            = $ADHash["$($HasPerm)"].DisplayName
                        GrantedUPN         = $ADHash["$($HasPerm)"].UserPrincipalName
                        GrantedSMTP        = $ADHash["$($HasPerm)"].PrimarySMTPAddress
                        Checking           = $HasPerm
                        TypeDetails        = $ADHashType."$($ADHash["$($HasPerm)"].msExchRecipientTypeDetails)"
                        DisplayType        = $ADHashDisplay."$($ADHash["$($HasPerm)"].msExchRecipientDisplayType)"
                        Permission         = "SendAs"
                    }
                }
            }
        }
    }
    end {

    }
}
