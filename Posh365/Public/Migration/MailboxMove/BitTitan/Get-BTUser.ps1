function Get-BTUser {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Invoke-GetBTUserTrimmed | Out-GridView -Title "BitTitan Users"
    }
}
