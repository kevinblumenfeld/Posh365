function Get-ATPSafeAttachmentPolicy {
    [CmdletBinding()]
    param (
    )
    end {
        Get-SafeAttachmentPolicy | Select-Object @(
            'Name'
            'RedirectAddress'
            'Redirect'
            'Action'
            'ScanTimeout'
            'ConfidenceLevelThreshold'
            'OperationMode'
            'Enable'
            'ActionOnError'
            'IsDefault'
            'Identity'
            'WhenChanged'
            'WhenCreated'
            'ExchangeObjectId'
            'Guid'
        )
    }
}

