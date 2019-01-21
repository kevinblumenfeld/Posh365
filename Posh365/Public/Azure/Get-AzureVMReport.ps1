function Get-AzureVMReport {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory)]
        $VM
    )

    $MaxDataDisks = ($VM.foreach( {$_.StorageProfile.DataDisks.count}) | Measure-Object -Maximum).Maximum
    $MaxOsDisks = ($VM.foreach( {$_.StorageProfile.OsDisk.count}) | Measure-Object -Maximum).Maximum

    $VM | Get-AzureVMHelper -MaxDataDisks $MaxDataDisks -MaxOsDisks $MaxOsDisks
}