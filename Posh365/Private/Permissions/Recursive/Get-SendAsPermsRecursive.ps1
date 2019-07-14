function Get-SendAsPermsRecursive {

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
        foreach ($curDN in $DistinguishedName) {
            $mailbox = $curDN
            Write-Verbose "Inspecting: `t $mailbox"
            Get-ADPermission $curDN | Where-Object {
                $_.ExtendedRights -like "*Send-As*" -and
                ($_.IsInherited -eq $false) -and
                !($_.User -like "NT AUTHORITY\SELF") -and
                !($_.User.tostring().startswith('S-1-5-21-')) -and
                !$_.Deny
            } | ForEach-Object {
                $User = $_.User
                Write-Verbose "Has Send As: `t $User"
                try {
                    Get-ADGroupMember ($_.user -split "\\")[1] -Recursive -ErrorAction stop |
                    ForEach-Object {
                        New-Object -TypeName psobject -property @{
                            Object             = $ADHashDN["$mailbox"].DisplayName
                            UserPrincipalName  = $ADHashDN["$mailbox"].UserPrincipalName
                            PrimarySMTPAddress = $ADHashDN["$mailbox"].PrimarySMTPAddress
                            Granted            = $ADHashDN["$($_.distinguishedname)"].DisplayName
                            GrantedUPN         = $ADHashDN["$($_.distinguishedname)"].UserPrincipalName
                            GrantedSMTP        = $ADHashDN["$($_.distinguishedname)"].PrimarySMTPAddress
                            Checking           = $User
                            GroupMember        = $($_.distinguishedname)
                            Type               = "GroupMember"
                            Permission         = "SendAs"
                        }
                    }
                }
                catch {
                    New-Object -TypeName psobject -property @{
                        Object             = $ADHashDN["$mailbox"].DisplayName
                        UserPrincipalName  = $ADHashDN["$mailbox"].UserPrincipalName
                        PrimarySMTPAddress = $ADHashDN["$mailbox"].PrimarySMTPAddress
                        Granted            = $ADHash["$User"].DisplayName
                        GrantedUPN         = $ADHash["$User"].UserPrincipalName
                        GrantedSMTP        = $ADHash["$User"].PrimarySMTPAddress
                        Checking           = $User
                        GroupMember        = ""
                        Type               = "User"
                        Permission         = "SendAs"
                    }
                }
            }
        }
    }
    end {

    }
}
