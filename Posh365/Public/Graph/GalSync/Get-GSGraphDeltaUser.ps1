function Get-GSGraphDeltaUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter()]
        [switch] $Delta
    )
    begin {
        # Get-GSGraphExchangeUser $Tenant
        $SelectString = 'DisplayName, mail, mobilePhone, City, State'
    }
    process {
        $Token = Connect-PoshGraph -Tenant $Tenant
        $Headers = @{
            "Authorization" = "Bearer $Token"
            prefer          = "return=minimal"
        }
        $RestSplat = @{
            Uri     = 'https://graph.microsoft.com/v1.0/users/delta?$select={0}' -f $SelectString
            Headers = $Headers
            Method  = 'Get'
        }
        do {
            if ($Delta) {
                $Headers = @{
                    "Authorization" = "Bearer $Token"
                    prefer          = "return=minimal"
                }
                $RestSplat = @{
                    Uri     = $DN
                    Headers = $Headers
                    Method  = 'Get'
                }
                $Response = Invoke-RestMethod @RestSplat -Verbose:$false
            }
            else {
                $Response = Invoke-RestMethod @RestSplat -Verbose:$false
                if ($Response.'@odata.nextLink') {
                    $Next = $Response.'@odata.nextLink'
                    $Headers = @{
                        "Authorization" = "Bearer $Token"
                        prefer          = "return=minimal"
                    }
                    $RestSplat = @{
                        Uri     = $Next
                        Headers = $Headers
                        Method  = 'Get'
                    }
                }
                elseif ($Response.'@odata.deltaLink') {
                    $DeltaNext = $Response.'@odata.deltaLink'
                    $Headers = @{
                        "Authorization" = "Bearer $Token"
                        prefer          = "return=minimal"
                    }
                    $RestSplat = @{
                        Uri     = $DeltaNext
                        Headers = $Headers
                        Method  = 'Get'
                    }
                    $Script:DN = $DeltaNext
                    $Next = $null
                }
                else {
                    $Next = $null
                }
            }
        } until (-not $Next -or $Delta)

    }
    end {
        $Response
        #$Response.value | Where-Object { $_.id -in $ExchangeSet }
    }

}