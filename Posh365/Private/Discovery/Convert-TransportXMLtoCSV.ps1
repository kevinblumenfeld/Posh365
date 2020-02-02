function Convert-TransportXMLtoCSV {
    param (
        [Parameter(Mandatory)]
        $TRuleColList,

        [Parameter()]
        [hashtable]
        $TransportHash
    )
    foreach ($TRule in $TRuleColList) {
        foreach ($Rule in $TRule.rules.rule) {
            [PSCustomObject]@{
                Name        = $Rule.name
                Priority    = $TransportHash[$Rule.Name].Priority
                State       = $TransportHash[$Rule.Name].State
                Description = $TransportHash[$Rule.Name].Description
                Command     = $Rule.version.commandblock."#cdata-section"
            }
        }
    }
}
