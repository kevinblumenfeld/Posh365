function Get-ADUserGuid {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $UserList
    )
    process {
        foreach ($User in $UserList) {
            $FilterString = "UserPrincipalName -eq '{0}'" -f $User.UserPrincipalName
            (Get-ADUser -filter $filterString).ObjectGUID
        }
    }
}
