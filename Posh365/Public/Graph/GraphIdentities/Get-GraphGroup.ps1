function Get-GraphGroup {
    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    param (
        [Parameter(ParameterSetName = 'GroupID')]
        $GroupId,

        [Parameter(ParameterSetName = 'Name')]
        $Name
    )

    if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
    switch ($PSCmdlet.ParameterSetName) {
        'GroupID' {
            Get-GraphGroupData -GroupId $GroupId
        }
        'Name' {
            Get-GraphGroupData -Name $Name | Select-Object -ExpandProperty Value
        }
        default {
            Get-GraphGroupData | Select-Object -ExpandProperty Value
        }
    }
}
