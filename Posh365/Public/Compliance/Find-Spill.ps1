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
    $EA = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        Connect-PoshGraph -Tenant $Splat.Tenant
        $NewCS = $null
        $NewCS = $Splat['UserPrincipalName'] | Get-GraphUser | Get-GraphMailFolderMessage $Splat['Top']
    }
    catch {
        Write-Host "Graph Error: $($_.Exception.Message)" -ForegroundColor Cyan
        return
    }
    # $null = Start-ComplianceSearch -Identity $NewCS.Name

    # $Prop = @('Name', 'Status', 'Contentmatchquery', 'NumBindings', 'SearchType', 'Items', 'Size')
    # do {
    #     $Pass = Get-ComplianceSearch $NewCS.Name | Select-Object $Prop |
    #     Out-Gridview -Title "Status of Compliance Search: $($NewCS.Name) - Query: $($NewCS.ContentMatchQuery)" -PassThru
    # } until (-not $Pass)
    # $PropAction = @('Name', 'SearchName', 'Action', 'RunBy', 'JobStartTime', 'JobEndTime', 'Status')
    # $PurgeStatus = New-CompliancePurge -NewCS $NewCS
    # do {
    #     $ActionResult = Get-ComplianceSearchAction -Identity $PurgeStatus.Name | Select-Object $PropAction |
    #     Out-GridView -Title "Status of Action: $($PurgeStatus.Name)" -PassThru
    # } until (-not $ActionResult)
    $ErrorActionPreference = $EA
}
