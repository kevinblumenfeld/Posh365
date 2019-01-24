
function Get-RetentionLinks {

    [CmdletBinding()]
    Param
    (

    )

    $LinkedTag = New-Object System.Collections.Generic.List[string]
    $Policy = Get-RetentionPolicy
    $RetTag = Get-RetentionPolicyTag

    $TagHash = @{}
    foreach ($Tag in $RetTag) {
        foreach ($Name in $Tag.name) {
            $TagHash[$Name] = $Tag
        }
    }

    foreach ($CurPolicy in $Policy) {
        Foreach ($CurLink in $CurPolicy.RetentionPolicyTagLinks) {
            $LinkedTag.Add($CurLink)
            $Linked = New-Object -TypeName PSObject -Property @{
                IsDefault   = $CurPolicy.IsDefault
                PolicyName  = $CurPolicy.Name
                TagName     = $CurLink
                TagAgeLimit = $TagHash."$CurLink".AgeLimitForRetention
                TagAction   = $TagHash."$CurLink".RetentionAction
                TagType     = $TagHash."$CurLink".Type
                TagEnabled  = $TagHash."$CurLink".RetentionEnabled
            }
            $Linked | Select IsDefault, PolicyName, TagName, TagAgeLimit, TagAction, TagType, TagEnabled
        }
    }
    foreach ($CurRetTag in $RetTag) {
        if ($LinkedTag -notcontains $CurRetTag.name) {
            $UnLinked = New-Object -TypeName PSObject -Property @{
                IsDefault   = 'Tag Not Linked'
                PolicyName  = 'Tag Not Linked'
                TagName     = $CurRetTag.name
                TagAgeLimit = $TagHash."$CurRetTag".AgeLimitForRetention
                TagAction   = $TagHash."$CurRetTag".RetentionAction
                TagType     = $TagHash."$CurRetTag".Type
                TagEnabled  = $TagHash."$CurRetTag".RetentionEnabled
            }
            $UnLinked | Select IsDefault, PolicyName, TagName, TagAgeLimit, TagAction, TagType, TagEnabled
        }
    }
}
