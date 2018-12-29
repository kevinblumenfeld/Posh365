function Import-GoogleToEXOGroup {
    <#
    .SYNOPSIS
    Import CSV of Google Groups into Office 365 as Distribution Groups

    .DESCRIPTION
    Import CSV of Google Groups into Office 365 as Distribution Groups

    .PARAMETER Groups
    CSV of new groups and attributes to create.

    .EXAMPLE
    Import-Csv .\importgroups.csv | Import-EXOGroup


    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Groups,

        [Parameter()]
        [switch]$DontAddOwnersToManagedBy,

        [Parameter()]
        [switch]$DontAddManagersToManagedBy
    )
    Begin {

    }
    Process {
        ForEach ($CurGroup in $Groups) {
            $Alias = ($CurGroup.Email -split "@")[0]
            $ManagedBy = [System.Collections.Generic.List[psobject]]::new()

            if (-not $DontAddOwnersToManagedBy -and -not [string]::IsNullOrWhiteSpace($CurGroup.Managers)) {
                $CurGroup.Managers -split "`r`n" | ForEach-Object {
                    $ManagedBy.Add($_)
                }
            }
            if (-not $DontAddManagersToManagedBy -and -not [string]::IsNullOrWhiteSpace($CurGroup.Owners)) {
                $CurGroup.Owners -split "`r`n" | ForEach-Object {
                    $ManagedBy.Add($_)
                }
            }

            $NewHash = @{

                Name               = $CurGroup.Name
                DisplayName        = $CurGroup.DisplayName
                Alias              = $Alias
                ManagedBy          = $ManagedBy
                PrimarySmtpAddress = $CurGroup.Email

            }
            $SetHash = @{

                Identity                      = $CurGroup.Email
                HiddenFromAddressListsEnabled = -not [bool]::Parse($CurGroup.includeInGlobalAddressList)

            }

            $NewParams = @{}
            ForEach ($h in $NewHash.keys) {
                if ($($NewHash.item($h))) {
                    $NewParams.add($h, $($NewHash.item($h)))
                }
            }
            $SetParams = @{}
            ForEach ($h in $SetHash.keys) {
                if ($($SetHash.item($h))) {
                    $SetParams.add($h, $($SetHash.item($h)))
                }
            }

            New-DistributionGroup @NewParams
            Set-DistributionGroup @SetParams
        }
    }
    End {

    }
}
