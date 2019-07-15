function Get-MigrationChain {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $Names,

        [Parameter()]
        [PSObject[]] $DataSet,

        [Parameter(Mandatory = $false)]
        [string] $swvar = $swvar,

        [Parameter()]
        [Hashtable] $LoopDetection = @{ }
    )

    if ($swvar -notmatch "FullAccess|SendAs|SendOnBehalf") {
        $swvar = 'placeholder'
    }
    $nameAndDependencies = @()
    foreach ($Name in $Names) {
        $DataSet | Where-Object { $_.UserPrincipalName -eq $Name -and $_.Permission -notmatch $swvar } | ForEach-Object {
            if ($_.GrantedUPN -and !$LoopDetection.Contains($_.GrantedUPN)) {
                $LoopDetection.Add($_.GrantedUPN, $null)
                $nameAndDependencies += Get-MigrationChain -Name $_.GrantedUPN -DataSet $DataSet -LoopDetection $LoopDetection -swvar $swvar
            }
        }
        $DataSet | Where-Object { $_.GrantedUPN -eq $Name -and $_.Permission -notmatch $swvar } | ForEach-Object {
            if ($_.UserPrincipalName -and !$LoopDetection.Contains($_.UserPrincipalName)) {
                $LoopDetection.Add($_.UserPrincipalName, $null)
                $nameAndDependencies += Get-MigrationChain -Name $_.UserPrincipalName -DataSet $DataSet -LoopDetection $LoopDetection -swvar $swvar
            }
        }
    }
    # We add the source name only if they are not found in the dependencies
    foreach ($Name in $Names) {
        if ($name -notin $nameAndDependencies) {
            $nameAndDependencies += $Name
        }
    }
    $nameAndDependencies
}
