function Import-ActiveDirectoryGroup { 
    <#
    .SYNOPSIS
    Import Active Directory Group
    
    .DESCRIPTION
    Import Active Directory Group
    
    .PARAMETER Groups
    CSV of new AD Groups and attributes to create.
    
    .EXAMPLE
    Import-Csv .\importgroups.csv | Import-ActiveDirectoryGroup -Match contoso.com -JoinType or -OU "OU=Groups,OU=Synced,OU=CORP,DC=Contoso,DC=com"

    #>

    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Groups,
    
        [Parameter(Mandatory = $true)]
        [ValidateSet("and", "or")]
        [String]$JoinType,
    
        [Parameter()]
        [String[]]$Match,
    
        [Parameter()]
        [String[]]$caseMatch,
    
        [Parameter()]
        [String[]]$matchAnd,
    
        [Parameter()]
        [String[]]$caseMatchAnd,
    
        [Parameter()]
        [String[]]$MatchNot,
    
        [Parameter()]
        [String[]]$caseMatchNot,
            
        [Parameter()]
        [String[]]$MatchNotAnd,
    
        [Parameter()]
        [String[]]$caseMatchNotAnd,
            
        [Parameter(Mandatory = $true)]
        [String]$OU
    )
    Begin {
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-Error_Log.csv")
    
        $filterElements = $psboundparameters.Keys | Where-Object { $_ -match 'Match' } | ForEach-Object {
    
            if ($_.EndsWith('And')) {
                $logicOperator = ' -and '
            }
            else {
                $logicOperator = ' -or '
            }
                
            $comparisonOperator = switch ($_) {
                { $_.StartsWith('case') } { '-cmatch' }
                default { '-match' }
            }
    
            if ($_.Contains('Not')) {
                $comparisonOperator = $comparisonOperator -replace '^-(c?)', '-$1not'
            }
    
            $elements = foreach ($value in $psboundparameters[$_]) {
                '$_ {0} "{1}"' -f $comparisonOperator, $value
            }
            $elements -join $logicOperator
        }
        $filterString = '({0})' -f ($filterElements -join (') -{0} (' -f $JoinType))
        $filter = [ScriptBlock]::Create($filterString)
        Write-Verbose "Filter being used: $filter"
    
        $DomainNameHash = Get-DomainNameHash

        Write-Verbose "Importing Active Directory Users that have at least one proxy address"
        $AllADUsers = Get-ADUsersWithProxyAddress -DomainNameHash $DomainNameHash

        Write-Verbose "Caching hash table. DisplayName attribute as key and value of ObjectGuid"
        $ADHashDisplayToGuid = $AllADUsers | Get-ADHashDisplayNameToGuid
    }
    Process {
        ForEach ($CurGroup in $Groups) {            

            $newhash = @{
                Alias                              = $CurGroup.Alias
                BypassNestedModerationEnabled      = [bool]::Parse($CurGroup.BypassNestedModerationEnabled)
                DisplayName                        = $CurGroup.DisplayName
                MemberDepartRestriction            = $CurGroup.MemberDepartRestriction
                MemberJoinRestriction              = $CurGroup.MemberJoinRestriction
                ModerationEnabled                  = [bool]::Parse($CurGroup.ModerationEnabled)
                Name                               = $CurGroup.Name
                Notes                              = $CurGroup.Notes
                RequireSenderAuthenticationEnabled = [bool]::Parse($CurGroup.RequireSenderAuthenticationEnabled)
                SendModerationNotifications        = $CurGroup.SendModerationNotifications
                GroupCategory                      = "Distribution"
                GroupScope                         = "Universal"
                Path                               = $OU
            }            

            <#
                CustomAttribute1                  = $CurGroup.CustomAttribute1
                CustomAttribute10                 = $CurGroup.CustomAttribute10
                CustomAttribute11                 = $CurGroup.CustomAttribute11
                CustomAttribute12                 = $CurGroup.CustomAttribute12
                CustomAttribute13                 = $CurGroup.CustomAttribute13
                CustomAttribute14                 = $CurGroup.CustomAttribute14
                CustomAttribute15                 = $CurGroup.CustomAttribute15
                CustomAttribute2                  = $CurGroup.CustomAttribute2
                CustomAttribute3                  = $CurGroup.CustomAttribute3
                CustomAttribute4                  = $CurGroup.CustomAttribute4
                CustomAttribute5                  = $CurGroup.CustomAttribute5
                CustomAttribute6                  = $CurGroup.CustomAttribute6
                CustomAttribute7                  = $CurGroup.CustomAttribute7
                CustomAttribute8                  = $CurGroup.CustomAttribute8
                CustomAttribute9                  = $CurGroup.CustomAttribute9
                #>

            $sethash = @{
                msExchHideFromAddressLists        = [bool]::Parse($CurGroup.HiddenFromAddressListsEnabled)
                reportToOwner                     = [bool]::Parse($CurGroup.ReportToManagerEnabled)
                reportToOriginator                = [bool]::Parse($CurGroup.ReportToOriginatorEnabled)
                SendOofMessageToOriginatorEnabled = [bool]::Parse($CurGroup.SendOofMessageToOriginatorEnabled)
                SimpleDisplayName                 = $CurGroup.SimpleDisplayName
                WindowsEmailAddress               = $CurGroup.WindowsEmailAddress

            }
            $newparams = @{}
            ForEach ($h in $newhash.keys) {
                if ($($newhash.item($h))) {
                    $newparams.add($h, $($newhash.item($h)))
                }
            }            
            $setparams = @{}
            ForEach ($h in $sethash.keys) {
                if ($($sethash.item($h))) {
                    $setparams.add($h, $($sethash.item($h)))
                }
            }

            $NewGroup = New-ADGroup @newparams
            Set-ADGroup -Identity $NewGroup.ObjectGUID @setparams

            $Address = $CurGroup.EmailAddresses -split ";" | Where-Object $filter
            $Address | ForEach-Object {
                Set-ADGroup -Identity $NewGroup.ObjectGUID -Add @{ProxyAddresses = "$_"}
                Write-Verbose "$($CurGroup.Displayname) `t Set ProxyAddress $($_)"
            }
            if ($CurGroup.ManagedBy) {
                $CurGroup.ManagedBy -Split ";" | ForEach-Object {
                    Set-DistributionGroup -Identity $CurGroup.Identity -ManagedBy @{Add = "$ADHashDisplayToGuid[$_]"}
                }
            }
        }
    }
    End {
        
    }
}
