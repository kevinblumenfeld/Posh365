function Get-SPOWeb {

    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$UsernameString,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Url,
        [Parameter(Mandatory = $true, Position = 3)]
        $PwdSecureString,
        [Parameter(Mandatory = $true, Position = 4)]
        $CSVPath
    )

    $errorActionPreference = 'Stop'

    # Connecting to particular personal site
    $clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($Url)
    $clientContext.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UsernameString, $PwdSecureString)
    $clientContext.Load($clientContext.Web)
    $clientContext.Load($clientContext.Site)
    $errorMessage = $null

    try {
        $clientContext.ExecuteQuery()
    }
    catch {
        $errorMessage = $_.Exception
        $_
    }
    
    Invoke-LoadMethod -Object $clientContext.Site -PropertyName "Usage"

    if (-Not $clientContext.Site.Usage.StoragePercentageUsed -eq 0) {
        $storageAvailable = $clientContext.Site.Usage.Storage / $clientContext.Site.Usage.StoragePercentageUsed / 1GB 
        $storageUsed_GB = ([Math]::Round($clientContext.Site.Usage.Storage / 1GB, 2))
        $percentageUsed = ([decimal]::Round(($clientContext.Site.Usage.StoragePercentageUsed), 2))
        $freeStorage = ([Math]::Round(1099511627776 - $clientContext.Site.Usage.Storage), 4)
    }

    # User output, feel free to modify the message content
    if ($storageAvailable -ne $null) {
        Write-Verbose "Storage available: $storageAvailable GB"
        Write-Verbose "Storage: $(($clientContext.Site.Usage.Storage / 1GB))"
        Write-Verbose "Percentage used: $(([decimal]::Round(($clientContext.Site.Usage.StoragePercentageUsed), 2)))"
        Write-Verbose "Storage free: $freeStorage"
    }
    else {
        Write-Verbose "Failed"
    }

    [PSCustomObject]@{
        Url                 = $Url
        StorageAvailable_GB = $storageAvailable
        StorageUsed_GB      = $storageUsed_GB
        PercentageUsed      = $percentageUsed
        StorageFree_GB      = $freeStorage
        Message             = $errorMessage
            
    } 

    $clientContext.Dispose()
}