function Get-GSGraphExchangeUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant
    )

    end {
        $ExchangeSet = [System.Collections.Generic.HashSet[string]]::new()
        (Get-GSGraphUserAll $Tenant).where{
            $_.provisionedplans.service -eq 'exchange' -and $_.provisionedplans.capabilityStatus -eq 'enabled'
        } | ForEach-Object { $null = $ExchangeSet.Add($_.id) }
        $Script:ExchangeSet = $ExchangeSet
    }

}