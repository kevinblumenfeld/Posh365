function Get-ADConnectError {
    <#
    .SYNOPSIS
    Provides in readable format, all AD Connect provisioning errors within MSOnline

    .DESCRIPTION
    Provides in readable format, all AD Connect provisioning errors within MSOnline

    .EXAMPLE
    Get-ADConnectError | Export-Csv .\ADConnectErrors.csv -notypeinformation

    .NOTES
    Connect to MSOnline first

    Connect-Cloud can be used to do this:
    Connect-Cloud contoso -msonline
    #>

    Param (

    )
    $ErrList = Get-MsolDirSyncProvisioningError -All

    foreach ($Err in $ErrList) {
        $ProvList = $Err.ProvisioningErrors
        foreach ($Prov in $ProvList) {
            [PSCustomObject]@{
                DisplayName     = $Err.DisplayName
                ImmutableId     = $Err.ImmutableId
                ObjectType      = $Err.ObjectType
                ErrorCategory   = $Prov.ErrorCategory
                PropertyName    = $Prov.PropertyName
                PropertyValue   = $Prov.PropertyValue
                WhenStarted     = $Prov.WhenStarted
                ProxyAddresses  = @($Err.ProxyAddresses) -ne '' -join '|'
                ObjectId        = $Err.ObjectId
                LastDirSyncTime = $Err.LastDirSyncTime
            }
        }
    }
}
