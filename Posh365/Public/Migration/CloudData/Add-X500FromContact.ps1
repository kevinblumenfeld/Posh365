function Add-X500FromContact {
    [CmdletBinding()]
    param (

    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $OnPremHash = Join-Path -Path $PoshPath -ChildPath 'OnPremRecipientHash_PrimaryToGUID.xml'
    $CloudHash = Join-Path -Path $PoshPath -ChildPath 'ContactHash_ExternalToX500.xml'
    if (-not $OnPremHash -or -not $CloudHash) {
        Write-Host "Missing one or both files" -ForegroundColor Red
        Write-Host "1) $OnPremHash" -ForegroundColor Cyan
        Write-Host "2) $CloudHash" -ForegroundColor Cyan
        return
    }
    else {
        $Local = Import-Clixml $OnPremHash
        $Cloud = Import-Clixml $CloudHash
    }

    $MatchingPrimaryCSV = Join-Path -Path $PoshPath -ChildPath 'MatchingPrimary.csv'
    $ResultObject = Invoke-AddX500FromContact -Local $Local -Cloud $Cloud

    $ResultObject | Out-GridView -Title "Results of comparison between source and target"
    $ResultObject | Export-Csv $MatchingPrimaryCSV
    Write-Host "Results have been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$MatchingPrimaryCSV" -ForegroundColor Green
}
