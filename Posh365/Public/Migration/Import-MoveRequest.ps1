function Import-MoveRequest {
    param (
        [Parameter(Mandatory = $true)]
        [string] $CsvFileName,

        [Parameter(Mandatory = $true)]
        [string] $Tenant,

        [Parameter(Mandatory = $true)]
        [string] $RemoteHostName
    )

    if ($Tenant -match 'onmicrosoft') {
        $Tenant = $Tenant.Split(".")[0]
    }
    
    $TargetDeliveryDomain = "$tenant.mail.onmicrosoft.com"

    $Imported = Import-CSV $CSVFilePath

    $ReadyToMigrate = $Imported | Where-Object {
        $_.PreFlightComplete -eq $TRUE -and $_.MoveRequest -eq $FALSE
    }

    $OnPremisesCredential = Get-Cred -Tenant $Tenant -Type OnPremMigration
}

foreach ($CurReady in $ReadyToMigrate) {
    $MoveSplat = @{
        Remote                     = $True
        Identity                   = $CurReady.UserPrincipalName
        BatchName                  = $CurReady.BatchName
        RemoteHostName             = $CurReady.RemoteHostName
        RemoteCredential           = $OnPremisesCredential
        TargetDeliveryDomain       = $TargetDeliveryDomain
        BadItemLimit               = 50
        LargeItemLimit             = 50
        AcceptLargeDataLoss        = $True
        SuspendWhenReadyToComplete = $True
    }

    New-MoveRequest @MoveSplat
    Start-Sleep -Seconds 2

}
