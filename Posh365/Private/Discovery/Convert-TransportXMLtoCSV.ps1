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
                Description = $TransportHash[$Rule.Id].Description
                Command     = $Rule.version.commandblock."#cdata-section"
            }
        }
    }
}
