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
        $ADHashDisplay
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
                Write-Verbose "Has Full Access:`t$($_.User)"
                New-Object -TypeName psobject -property @{
                    Object             = $ADHashDN["$ADUser"].DisplayName
                    UserPrincipalName  = $ADHashDN["$ADUser"].UserPrincipalName
                    PrimarySMTPAddress = $ADHashDN["$ADUser"].PrimarySMTPAddress
                    Granted            = $ADHash["$($_.User)"].DisplayName
                    GrantedUPN         = $ADHash["$($_.User)"].UserPrincipalName
                    GrantedSMTP        = $ADHash["$($_.User)"].PrimarySMTPAddress
                    Checking           = $_.User
                    TypeDetails        = $ADHashType."$($ADHash["$($_.User)"].msExchRecipientTypeDetails)"
                    DisplayType        = $ADHashDisplay."$($ADHash["$($_.User)"].msExchRecipientDisplayType)"
                    Permission         = "FullAccess"
                }
            }
        }
    }
    end {

    }
}
