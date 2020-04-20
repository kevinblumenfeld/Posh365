function Add-X500FromContact {
    [CmdletBinding()]
    param (

    )

    Get-DestinationRemoteMailboxHash

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $TargetHash = Join-Path -Path $PoshPath -ChildPath 'TargetHash.xml'
    $SourceContactHash = Join-Path -Path $PoshPath -ChildPath 'SourceContactHash.xml'
    if (-not (Test-Path $TargetHash) -or -not (Test-Path $SourceContactHash)) {
        Write-Host "Missing one or both files" -ForegroundColor Red
        Write-Host "1) $TargetHash" -ForegroundColor Cyan
        Write-Host "2) $SourceContactHash" -ForegroundColor Cyan
        return
    }
    else {
        $Target = Import-Clixml $TargetHash
        $Source = Import-Clixml $SourceContactHash
    }

    $MatchingPrimaryCSV = Join-Path -Path $PoshPath -ChildPath 'MatchingPrimary.csv'
    $ResultObject = Invoke-AddX500FromContact -Target $Target -Source $Source

    $ResultObject | Out-GridView -Title "Results of comparison between source and target"
    $ResultObject | Export-Csv $MatchingPrimaryCSV
    Write-Host "Results have been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$MatchingPrimaryCSV" -ForegroundColor Green
}
