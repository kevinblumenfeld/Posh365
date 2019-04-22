function Compare-GroupMembership {
    param (

        [Parameter(Mandatory)]
        [string] $SourceFile,

        [Parameter(Mandatory)]
        [string] $TargetFile,

        [Parameter(Mandatory)]
        [string] $TestGroup,

        [Parameter(Mandatory)]
        [ValidateSet('NotInTarget', 'NotInSource', 'Both')]
        [string] $NotInSourceOrTarget

    )

    $SourceList = Import-Csv $SourceFile
    $SourceHash = @{ }
    foreach ($Source in $SourceList) {
        if (-not $SourceHash.Contains($Source.GroupEmail)) {
            $SourceHash[$Source.GroupEmail] = [system.collections.arraylist]::new()
        }
        $null = $SourceHash[$Source.GroupEmail].Add($Source.MemberEmail)
    }

    $TargetList = Import-Csv $TargetFile
    $TargetHash = @{ }
    foreach ($Target in $TargetList) {
        if (-not $TargetHash.Contains($Target.GroupEmail)) {
            $TargetHash[$Target.GroupEmail] = [system.collections.arraylist]::new()
        }
        $TargetHash[$Target.GroupEmail] = ($Target.MemberEmail).split('|')
    }

    if ($NotInSourceOrTarget -eq "NotInTarget" -or $NotInSourceOrTarget -eq "Both") {
        $NotInTarget = @{ }
        foreach ($Group in $SourceHash.Keys) {
            if (-not $NotInTarget.Contains($Group)) {
                $NotInTarget[$Group] = [system.collections.arraylist]::new()
            }
            foreach ($Member in $SourceHash.$Group) {
                if (-not ($Member -in $TargetHash.$Group)) {
                    $null = $NotInTarget[$Group].Add($Member)
                }
            }
        }
    }
    if ($NotInSourceOrTarget -eq "NotInSource" -or $NotInSourceOrTarget -eq "Both") {
        $NotInSource = @{ }
        foreach ($Group in $TargetHash.Keys) {
            if (-not $NotInSource.Contains($Group)) {
                $NotInSource[$Group] = [system.collections.arraylist]::new()
            }
            foreach ($Member in $TargetHash.$Group) {
                if (-not ($Member -in $SourceHash.$Group)) {
                    $null = $NotInSource[$Group].Add($Member)
                }
            }
        }
    }

    $SourceHash.$TestGroup | Out-GridView -Title "In Source Environment (GOOGLE)"
    $TargetHash.$TestGroup | Out-GridView -Title "In Target Environment (OFFICE 365)"
    if ($NotInSourceOrTarget -eq "NotInTarget" -or $NotInSourceOrTarget -eq "Both") {
        $NotInTarget.$TestGroup | Out-GridView -Title "In Source (GOOGLE) but not in Target (OFFICE 365)"
    }
    if ($NotInSourceOrTarget -eq "NotInSource" -or $NotInSourceOrTarget -eq "Both") {
        $NotInSource.$TestGroup | Out-GridView -Title "In Target (OFFICE 365) but not in Source (GOOGLE)"
    }
}