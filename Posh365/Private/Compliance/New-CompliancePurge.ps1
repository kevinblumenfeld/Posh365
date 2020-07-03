function New-CompliancePurge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $NewCS
    )
    do {
        if ($NewCS.name) { $Name = $NewCS.Name }
        else { $Name = $NewCS }
        $CurrentStatus = Get-ComplianceSearch $Name
        $Choice = $null
        $Choice = @("Delete $($CurrentStatus.Items) emails from: $Name", 'QUIT') | ForEach-Object {
            [PSCustomObject]@{ ACTION = $_ }
        } | Out-GridView -PassThru -Title "Compliance Search: $Name Status is $($CurrentStatus.Status). Choose to delete $($CurrentStatus.Items) emails from mailboxes or quit?"
    } until ($CurrentStatus.Status -eq 'Completed' -or $Choice.Action -eq 'QUIT')
    if ($Choice.Action -like 'Delete*') {
        Get-DecisionbyOGV
        New-ComplianceSearchAction -SearchName $Name -Purge -Confirm:$false -PurgeType $Script:HardOrSoft
        $Script:HardOrSoft = $null
    }
    else {
        Write-Host "Halting script as Quit was selected" -ForegroundColor DarkRed
        continue
    }
}
