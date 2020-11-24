function Get-IntunePolicyHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Policy
    )

    $PropertyHash = @{ }

    foreach ($Item in $Policy.psobject.properties) {
        $PropertyHash[$Item.Name] = $Item.value

    }

    $PropertyHash
}