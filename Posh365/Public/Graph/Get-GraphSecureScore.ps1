function Get-GraphSecureScore {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter()]
        [string] $Identifier,

        [Parameter()]
        [int] $NumberOfDays

    )

    $Token = Connect-Graph -Tenant $Tenant #-Identifier $Identifier

    $Headers = @{
        "Authorization" = "Bearer $Token"
    }

    $RestSplat = @{
        Uri     = 'https://graph.microsoft.com/beta/security/secureScores?$top=5'
        Headers = $Headers
        Method  = 'Get'
    }

    do {
        $Token = Connect-Graph -Tenant $Tenant #-Identifier $Identifier
        try {
            $Response = Invoke-RestMethod @RestSplat -Verbose:$false -ErrorAction Stop
            $ScoreList = $Response.value

            if ($Response.'@odata.nextLink' -match 'skip') {
                $Next = $Response.'@odata.nextLink'
            }
            else {
                $Next = $null
            }
            $Headers = @{
                "Authorization" = "Bearer $Token"
            }

            $RestSplat = @{
                Uri     = $Next
                Headers = $Headers
                Method  = 'Get'
            }
            foreach ($Score in $ScoreList) {
                [PSCustomObject]@{
                    CurrentScore    = $Score.currentScore
                    Date            = $Score.createdDateTime
                    LicensedUsers   = $Score.licensedUserCount
                    EnabledServices = @($Score.enabledServices) -ne '' -join '|'
                }
            }
        }
        catch {
            $_

        }
    } until (-not $next)
}
