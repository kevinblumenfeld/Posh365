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

    foreach ($Key in $Cloud.Keys) {
        [PSCustomObject]@{
            TargetDisplayName  = $Local[$Key]['DisplayName']
            SourceDisplayName  = $Cloud[$Key]['DisplayName']
            TargetType         = $Local[$Key]['RecipientTypeDetails']
            PrimarySmtpAddress = $Key
            GUID               = $Local[$Key]['GUID']
            TargetIdentity     = $Local[$Key]['Identity']
            SourceName  = $Cloud[$Key]['DisplayName']
        }
    }
    $OutputXml = Join-Path -Path $PoshPath -ChildPath 'OnPremRecipientHash_PrimaryToGUID.xml'
    Write-Host "Hash has been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$OutputXml" -ForegroundColor Green
    $Hash | Export-Clixml $OutputXml
}
