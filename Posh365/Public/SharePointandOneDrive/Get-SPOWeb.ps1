function Get-SPOWeb {

    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$UsernameString,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Url,
        [Parameter(Mandatory = $true, Position = 3)]
        $PwdSecureString,
        [Parameter(Mandatory = $true, Position = 4)]
        $curUser,
        [Parameter(Mandatory = $true, Position = 5)]
        $Display
        
        
    )

    $errorActionPreference = 'Stop'

    # Connecting to particular personal site
    $clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($Url)
    $clientContext.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UsernameString, $PwdSecureString)
    $null = $clientContext.Load($clientContext.Web)
    $null = $clientContext.Load($clientContext.Site)
    $errorMessage = $null

    try {
      $null =  $clientContext.ExecuteQuery()
    }
    catch {
        if ($_.exception.Message -like "*(404)*") {
            $errorMessage = "(404)NotFound"
        }
        else {
            $_
        }
    }
    
    Invoke-LoadMethod -Object $clientContext.Site -PropertyName "Usage"
    Try {
      $null =  $clientContext.ExecuteQuery()
    }
    Catch {
        if ($_.exception.Message -like "*(404)*" -or $_.exception.Message -like "*Not Found*"  ) {
            $errorMessage = "(404)NotFound"
        }
        if (-not $_.Exception.Message) {
            $errorMessage = 'NoError'
        }
        else {
            $errorMessage = $_.exception.Message
        }
        
    }

    if (-Not $clientContext.Site.Usage.StoragePercentageUsed -eq 0) {
        $storageAvailable = $clientContext.Site.Usage.Storage / $clientContext.Site.Usage.StoragePercentageUsed / 1GB 
        $storageUsed_GB = ([Math]::Round($clientContext.Site.Usage.Storage / 1GB, 2))
        $percentageUsed = ([decimal]::Round(($clientContext.Site.Usage.StoragePercentageUsed), 10))
        $BytesUsed = ($clientContext.Site.Usage.Storage)
    }

    # User output, feel free to modify the message content
    if ($storageAvailable -ne $null) {
        Write-Verbose "Storage available: $storageAvailable GB"
        Write-Verbose "Storage: $(($clientContext.Site.Usage.Storage / 1GB))"
        Write-Verbose "Percentage used: $(([decimal]::Round(($clientContext.Site.Usage.StoragePercentageUsed), 2)))"
        Write-Verbose "Bytes Used: $BytesUsed"
    }
    else {
        Write-Verbose "Null"
    }

    [PSCustomObject]@{
        SPOUser             = $curUser
        DisplayName         = $Display
        Url                 = $Url
        StorageAvailable_GB = $storageAvailable
        StorageUsed_GB      = $storageUsed_GB
        PercentageUsed      = $percentageUsed
        BytesUsed           = $BytesUsed
        Message             = $errorMessage
            
    } 

    $null = $clientContext.Dispose()
}