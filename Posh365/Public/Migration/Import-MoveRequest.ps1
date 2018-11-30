function Import-MoveRequest {
    param (
        [Parameter(Mandatory = $true)]
        [string] $CsvFileName,

        [Parameter(Mandatory = $true)]
        [string] $Tenant,

        [Parameter()]
        [string] $RemoteHostName
    )

    if ($Tenant -match 'onmicrosoft') {
        $Tenant = $Tenant.Split(".")[0]
    }
    
    $TargetDeliveryDomain = "$tenant.mail.onmicrosoft.com"

    $Imported = Import-CSV $CSVFilePath | Select *

    $OnPremisesCredential = Get-Cred -Tenant $Tenant -Type OnPremMigration

    foreach ($CurImported in $Imported) {
        
        if ($_.PreFlightComplete -eq $FALSE -and $_.MoveRequest -eq $TRUE) {
            continue
        }

        if ($RemoteHostName) {
            $RemoteHost = $RemoteHostName
        }
        else {
            $RemoteHost = $CurImported.RemoteHostName
        }
        $MoveSplat = @{
            Remote                     = $True
            Identity                   = $CurImported.UserPrincipalName
            BatchName                  = $CurImported.BatchName
            RemoteHostName             = $RemoteHost
            RemoteCredential           = $OnPremisesCredential
            TargetDeliveryDomain       = $TargetDeliveryDomain
            BadItemLimit               = 50
            LargeItemLimit             = 50
            AcceptLargeDataLoss        = $True
            SuspendWhenReadyToComplete = $True
        }
        try {
            New-MoveRequest @MoveSplat -ErrorAction Stop
            Write-Verbose "Created Move Request:`t $($CurImported.UserPrincipalName)"
        }
        catch {
            Write-Verbose "Error Creating Move Request:`t $($CurImported.UserPrincipalName)"
            # Add to csv column named ErrorCreating_Move
        }
        Start-Sleep -Seconds 2
    }
}
