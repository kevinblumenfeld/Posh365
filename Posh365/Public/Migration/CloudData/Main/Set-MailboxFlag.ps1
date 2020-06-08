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
    Invoke-SetMailboxFlag -ELCMailboxFlags $ELCMailboxFlags | Out-GridView -Title 'Results of Setting flag'
}