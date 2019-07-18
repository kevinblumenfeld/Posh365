
function Get-RetentionLinks {
    [CmdletBinding()]
    Param
    (

    )

    $LinkedTag = New-Object System.Collections.Generic.List[string]
    $Policy = Get-RetentionPolicy
    $RetTag = Get-RetentionPolicyTag

    $SelectRetention = @(
        'IsDefault', 'PolicyName', 'RetentionPolicyID', 'TagName'
        'TagAgeLimit', 'TagAction', 'TagType', 'TagEnabled'
    )
    $TagHash = @{ }
    foreach ($Tag in $RetTag) {
        foreach ($Name in $Tag.name) {
            $TagHash[$Name] = $Tag
        }
    }
    foreach ($CurPolicy in $Policy) {
        Foreach ($CurLink in $CurPolicy.RetentionPolicyTagLinks) {
            $LinkedTag.Add($CurLink)
            $Linked = New-Object -TypeName PSObject -Property @{
                IsDefault         = $CurPolicy.IsDefault
                PolicyName        = $CurPolicy.Name
                RetentionPolicyID = $CurPolicy.RetentionId
                TagName           = $CurLink
                TagAgeLimit       = $TagHash."$CurLink".AgeLimitForRetention
                TagAction         = $TagHash."$CurLink".RetentionAction
                TagType           = $TagHash."$CurLink".Type
                TagEnabled        = $TagHash."$CurLink".RetentionEnabled
                TagDescription    = $TagHash."$CurLink".Description
                TagTrigger        = $TagHash."$CurLink".TriggerForRetention
            }
            $Linked | Select-Object $SelectRetention
        }
    }
    foreach ($CurRetTag in $RetTag) {
        if ($LinkedTag -notcontains $CurRetTag.name) {
            $UnLinked = New-Object -TypeName PSObject -Property @{
                IsDefault         = 'Tag Not Linked'
                PolicyName        = 'Tag Not Linked'
                RetentionPolicyID = 'Tag Not Linked'
                TagName           = $CurRetTag.name
                TagAgeLimit       = $TagHash."$CurRetTag".AgeLimitForRetention
                TagAction         = $TagHash."$CurRetTag".RetentionAction
                TagType           = $TagHash."$CurRetTag".Type
                TagEnabled        = $TagHash."$CurRetTag".RetentionEnabled
                TagDescription    = $TagHash."$CurRetTag".Description
                TagTrigger        = $TagHash."$CurRetTag".TriggerForRetention
            }
            $UnLinked | Select-Object $SelectRetention
        }
    }
}
