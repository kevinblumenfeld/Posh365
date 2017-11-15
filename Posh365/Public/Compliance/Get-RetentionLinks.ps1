
function Get-RetentionLinks {

    [CmdletBinding()]
    Param
    (

    )
    Begin {

    }
    Process {
        $resultArray = @()
        $findParameter = "RetentionPolicyTagLinks"
        $retPols = Get-RetentionPolicy | Select name, identity, IsDefault, RetentionPolicyTagLinks
        $retTags = Get-RetentionPolicyTag
        $retPolProps = $retPols | Get-Member -MemberType 'NoteProperty' | Select Name
        
        $tagHash = @{}
        foreach ($tag in $retTags) {
            foreach ($id in $tag.name) {
                $tagHash[$id] = $tag 
            }
        }
      
        foreach ($row in $retPols) {           
            ForEach ($link in $row.$findParameter) {
                $polHash = @{}
                $polHash['TagName'] = ($tagHash[$link]).name
                $polHash['TagType'] = ($tagHash[$link]).type
                $polHash['TagEnabled'] = ($tagHash[$link]).RetentionEnabled
                $polHash['TagAgeLimit'] = ($tagHash[$link]).AgeLimitForRetention  
                $polHash['TagAction'] = ($tagHash[$link]).RetentionAction
                $polHash['TagComment'] = ($tagHash[$link]).Comment                                             
                foreach ($field in $retPolProps.name) {
                    $polHash[$field] = ($row.$field) -join ","
                }  
                $resultArray += [psCustomObject]$polHash        
            }
        }
        $links = @()
        foreach ($nPolicy in $RetPols) {
            foreach ($nId in $nPolicy.RetentionPolicyTagLinks) {
                $links += $nId 
            }
        }
        foreach ($nTag in $retTags) {
            if ($links -notcontains $nTag.name) {
                $polHash = @{}
                $polHash['TagName'] = $nTag.name
                $polHash['TagType'] = $nTag.type
                $polHash['TagEnabled'] = $nTag.RetentionEnabled
                $polHash['TagAgeLimit'] = $nTag.AgeLimitForRetention  
                $polHash['TagAction'] = $nTag.RetentionAction
                $polHash['TagComment'] = $nTag.Comment 
                foreach ($field in $retPolProps.name) {
                    $polHash[$field] = "Tag_Not_Linked" -join ","
                }  
                $resultArray += [psCustomObject]$polHash  
            }
           
        }
    }
    End {
            $resultArray | Select "IsDefault", "Name", "TagName", "TagAgeLimit", "TagAction", "TagType", "TagEnabled", "TagComment", "RetentionPolicyTagLinks", "Identity" | Sort Name
    }
}
