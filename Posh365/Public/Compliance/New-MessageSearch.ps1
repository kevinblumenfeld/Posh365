function New-MessageSearch {
    [CmdletBinding()]
    param (    )
    do {
        $NewCSearchSplat = try {
            Invoke-Expression (Show-Command -NoCommonParameter -PassThru MessageSearch) -ErrorAction Stop
        }
        catch {
            Write-Host "Show-Command Error: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    } until ($NewCSearchSplat.count -gt 2)
    $EA = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        $NewCS = $null
        $NewCS = New-ComplianceSearch @NewCSearchSplat
    }
    catch {
        Write-Host "New-ComplianceSearch Error: $($_.Exception.Message)" -ForegroundColor Cyan
        return
    }
    $null = Start-ComplianceSearch -Identity $NewCS.Name

    $Prop = @('Name', 'Status', 'Contentmatchquery', 'NumBindings', 'SearchType', 'Items', 'Size')
    do {
        $Pass = Get-ComplianceSearch $NewCS.Name | Select-Object $Prop |
        Out-Gridview -Title "Status of Compliance Search: $($NewCS.Name) - Query: $($NewCS.ContentMatchQuery)" -PassThru
    } until (-not $Pass)
    $PropAction = @('Name', 'SearchName', 'Action', 'RunBy', 'JobStartTime', 'JobEndTime', 'Status')
    $PurgeStatus = New-CompliancePurge -NewCS $NewCS
    do {
        $ActionResult = Get-ComplianceSearchAction -Identity $PurgeStatus.Name | Select-Object $PropAction |
        Out-GridView -Title "Status of Action: $($PurgeStatus.Name)" -PassThru
    } until (-not $ActionResult)
    $ErrorActionPreference = $EA
}
