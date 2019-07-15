function Add-UsertoADGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $GuidList,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Group
    )
    process {
        foreach ($Guid in $GuidList) {
            Add-ADGroupMember -Identity $Group -Members $Guid
        }
    }
}
