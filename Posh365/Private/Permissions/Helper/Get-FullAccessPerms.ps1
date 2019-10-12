function Get-FullAccessPerms {

    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $ADUserList,

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
    begin {

    }
    process {
        foreach ($ADUser in $ADUserList) {
            Write-Verbose "Inspecting:`t $ADUser"
            Get-MailboxPermission $ADUser |
            Where-Object {
                $_.AccessRights -like "*FullAccess*" -and
                !$_.IsInherited -and !$_.user.tostring().startswith('S-1-5-21-') -and
                !$_.user.tostring().startswith('NT AUTHORITY\SELF') -and
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
                            Permission         = "FullAccess"
                        }
                    }
                }
                elseif ( $ADHash["$HasPerm"].objectClass -notmatch 'group') {
                    New-Object -TypeName psobject -property @{
                        Object             = $ADHashDN["$ADUser"].DisplayName
                        UserPrincipalName  = $ADHashDN["$ADUser"].UserPrincipalName
                        PrimarySMTPAddress = $ADHashDN["$ADUser"].PrimarySMTPAddress
                        Granted            = $ADHash["$HasPerm"].DisplayName
                        GrantedUPN         = $ADHash["$HasPerm"].UserPrincipalName
                        GrantedSMTP        = $ADHash["$HasPerm"].PrimarySMTPAddress
                        Checking           = $_.User
                        TypeDetails        = $ADHashType."$($ADHash["$HasPerm"].msExchRecipientTypeDetails)"
                        DisplayType        = $ADHashDisplay."$($ADHash["$HasPerm"].msExchRecipientDisplayType)"
                        Permission         = "FullAccess"
                    }
                }
            }
        }
    }
    end {

    }
}
