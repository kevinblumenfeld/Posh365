function Find-Spill {
    [CmdletBinding()]
    param ()
    do {
        $Splat = try {
            Invoke-Expression (Show-Command -NoCommonParameter -PassThru SpillFinder) -ErrorAction Stop
        }
        catch {
            Write-Host "Show-Command Error: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    } until ($Splat.count -gt 2)
    if ($Splat.ContainsKey('OptionToDeleteMessages')) {
        Invoke-FindSpill @Splat | Out-GridView -PassThru -Title 'Choose Messages to Delete and Click OK' | Remove-GraphMailMessage
    }
    else {
        Invoke-FindSpill @Splat | Out-GridView -PassThru -Title 'Choose Messages to Delete and Click OK'
    }
}
