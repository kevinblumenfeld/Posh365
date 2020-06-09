function Set-MailboxFlag {
    param (
        [Parameter()]
        $ELCMailboxFlags = 24
    )

    if (-not ($null = Get-Module ActiveDirectory -ListAvailable)) {
        Write-Host "ActiveDirectory module for PowerShell not found! Please run from a computer with the ActiveDirectory module"
        return
    }
    Import-Module ActiveDirectory -Force

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $Result = Invoke-SetMailboxFlag -ELCMailboxFlags $ELCMailboxFlags
    $Result | Out-GridView -Title 'Results of Setting flag'
    $Result | Export-Csv (Join-Path $PoshPath 'RESULTS_SetMailboxFlag.csv') -NoTypeInformation -Append
}