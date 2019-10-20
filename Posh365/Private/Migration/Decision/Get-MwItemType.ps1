function Get-MwItemType {
    [CmdletBinding()]
    param (

    )
    end {
        $OGVType = @{
            Title      = 'Choose ItemTypes'
            OutputMode = 'Multiple'
        }
        'Mail' | Out-GridView @OGVType
        # 'Mail', 'Calendar', 'Contact', 'Journal', 'Note', 'Task', 'Rule' | Out-GridView @OGVType
    }
}
