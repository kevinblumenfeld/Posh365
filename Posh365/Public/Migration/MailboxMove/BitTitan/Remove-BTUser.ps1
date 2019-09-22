function Remove-BTUser {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Invoke-RemoveBTUser | Out-GridView -Title "Results of Remove BitTitan User"
    }
}
