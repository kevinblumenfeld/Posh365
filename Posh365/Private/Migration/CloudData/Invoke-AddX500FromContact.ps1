function Invoke-AddX500FromContact {
    [CmdletBinding()]
    param (

    )
    foreach ($Key in $Cloud.Keys) {
        if ($Local.ContainsKey($Key)) {
            [PSCustomObject]@{
                TargetDisplayName  = $Local[$Key]['DisplayName']
                SourceDisplayName  = $Cloud[$Key]['DisplayName']
                TargetType         = $Local[$Key]['RecipientTypeDetails']
                PrimarySmtpAddress = $Key
                GUID               = $Local[$Key]['GUID']
                TargetIdentity     = $Local[$Key]['Identity']
                SourceName         = $Cloud[$Key]['DisplayName']
            }
        }
        else {
            [PSCustomObject]@{
                TargetDisplayName  = 'NOTFOUND'
                SourceDisplayName  = $Cloud[$Key]['DisplayName']
                TargetType         = 'NOTFOUND'
                PrimarySmtpAddress = $Key
                GUID               = 'NOTFOUND'
                TargetIdentity     = 'NOTFOUND'
                SourceName         = $Cloud[$Key]['Name']
            }
        }
    }
}
