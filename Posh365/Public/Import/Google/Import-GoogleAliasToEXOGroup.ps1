
function Import-GoogleAliasToEXOGroup {
    Add-Content -Path "C:\Scripts\AliasImportFailures.csv" -Value ("ERROR" + "," + "GROUP" + "," + "EMAIL")
    $GroupsWithAliases | ForEach-Object {
        $Name = $_.Name
        $Aliases = $_.Aliases
        Write-Host "GroupName:`t $Name"
        try {
            $DG = Get-DistributionGroup $Name -ErrorAction Stop
            $Aliases -split " " | ForEach-Object {
                $email = $_
                try {
                    $DG | Set-DistributionGroup -EmailAddresses @{add = $email} -ErrorAction Stop
                    Write-Host "SUCCESS: $DGName`t$email" -ForegroundColor Green
                }
                catch {
                    Write-Host "FAILED: $DGName`t$email" -ForegroundColor Red
                    Add-Content -Path "C:\Scripts\AliasImportFailures.csv" -Value ("FAILEDADDEMAIL" + "," + "$DGName" + "," + "$Email")
                }
            }
        }
        catch {
            Add-Content -Path "C:\Scripts\AliasImportFailures.csv" -Value ("FAILEDGETGROUP" + "," + "$Name" + "," + "NOEMAIL")
        }
        $DGName = $DG.name
    }
}