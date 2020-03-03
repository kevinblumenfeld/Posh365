Function Invoke-SearchAuditLog {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        $StartDate,

        [Parameter()]
        $EndDate,

        [Parameter()]
        $SessionCommand,

        [Parameter()]
        $SessionId,

        [Parameter()]
        $RecordType,

        [Parameter()]
        $Operations,

        [Parameter()]
        $ResultSize
    )

    do {
        Search-UnifiedAuditLog @params | ForEach-Object {
            $Count = $_.ResultCount
            $Index = $_.ResultIndex
            $AuditData = $_.AuditData | ConvertFrom-Json
            $ModList = $AuditData.ModifiedProperties
            if ($ModList) {
                foreach ($Mod in $ModList) {
                    [PSCustomObject]@{
                        ResultIndex  = $Index
                        Operations   = $_.Operations
                        RecordType   = $_.RecordType
                        CreationDate = $_.CreationDate.ToLocalTime()
                        UserIds      = $_.UserIds
                        UserId       = $AuditData.UserId
                        ModName      = $Mod.Name
                        NewValue     = $Mod.OldValue
                        OldValue     = $Mod.NewValue
                        ResultCount  = $Count
                    }
                }
            }
            else {
                [PSCustomObject]@{
                    ResultIndex  = $Index
                    Operations   = $_.Operations
                    RecordType   = $_.RecordType
                    CreationDate = $_.CreationDate.ToLocalTime()
                    UserIds      = $_.UserIds
                    UserId       = $AuditData.UserId
                    ModName      = ''
                    NewValue     = ''
                    OldValue     = ''
                    ResultCount  = $Count
                }
            }
        }
    } until ($Index[-1] -ge $Count[-1])
}
