function Get-AzureStorageReport {
    Param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $StorageAcct
    )
    begin {
    }
    process {
        foreach ($CurStorageAcct in $StorageAcct) {
            [PSCustomObject]@{
                ResourceGroupName  = $CurStorageAcct.ResourceGroupName
                StorageAccountName = $CurStorageAcct.StorageAccountName
                Location           = $CurStorageAcct.Location
                StorageTier        = $CurStorageAcct.Sku.Tier
                ReplicationType    = $CurStorageAcct.Sku.Name
            }
        }
    }
    end {

    }
}
