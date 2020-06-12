function Import-EXOGroup {
    <#
    .SYNOPSIS
    Import Office 365 Distribution Groups

    .DESCRIPTION
    Import Office 365 Distribution Groups

    .PARAMETER CSVFilePath
    CSV of new groups and attributes to create

    .PARAMETER ConvertSourceOnMicrosoftPrimaryToTarget
    CSV of new groups and attributes to create

    .EXAMPLE
    Import-EXOGroup -CSVFilePath .\importgroups.csv | Export-csv .\results.csv -nti

    .EXAMPLE
    Import-EXOGroup -CSVFilePath .\importgroups.csv -ConvertSourceOnMicrosoftPrimaryToTarget | Export-csv .\results.csv -nti

    .NOTES
    EmailAddresses excluded from import are all onmicrosoft.com addressess
    Included are all smtp addresses
    #>


    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        $CSVFilePath,

        [Parameter()]
        [switch]
        $ConvertSourceOnMicrosoftPrimaryToTarget
    )
    $GroupList = Import-Csv $CSVFilePath
    if ($ConvertSourceOnMicrosoftPrimaryToTarget) {
        $InitialDomain = (Get-AcceptedDomain | Where-Object { $_.InitialDomain }).DomainName
        $GroupList = $GroupList | Select-Object -ExcludeProperty PrimarySmtpAddress, WindowsEmailAddress @(
            @{
                Name       = 'PrimarySmtpAddress'
                Expression = { if (($_.PrimarySmtpAddress).split('@')[1] -like '*.onmicrosoft.com' ) {
                        '{0}@{1}' -f ($_.PrimarySmtpAddress).split('@')[0], $InitialDomain
                    }
                    else {
                        $_.PrimarySmtpAddress
                    }
                }
            }
            @{
                Name       = 'WindowsEmailAddress'
                Expression = { if (($_.WindowsEmailAddress).split('@')[1] -like '*.onmicrosoft.com' ) {
                        '{0}@{1}' -f ($_.WindowsEmailAddress).split('@')[0], $InitialDomain
                    }
                    else {
                        $_.WindowsEmailAddress
                    }
                }
            }
            '*'
        )
    }
    ForEach ($Group in $GroupList) {
        $newhash = @{
            Alias                              = $Group.Alias
            BypassNestedModerationEnabled      = [bool]::Parse($Group.BypassNestedModerationEnabled)
            DisplayName                        = $Group.DisplayName
            IgnoreNamingPolicy                 = $Group.IgnoreNamingPolicy
            MemberDepartRestriction            = $Group.MemberDepartRestriction
            MemberJoinRestriction              = $Group.MemberJoinRestriction
            ModerationEnabled                  = [bool]::Parse($Group.ModerationEnabled)
            Name                               = $Group.Name
            Notes                              = $Group.Notes
            PrimarySmtpAddress                 = $Group.PrimarySmtpAddress
            RequireSenderAuthenticationEnabled = [bool]::Parse($Group.RequireSenderAuthenticationEnabled)
            SendModerationNotifications        = $Group.SendModerationNotifications
        }
        $sethash = @{
            CustomAttribute1                  = $Group.CustomAttribute1
            CustomAttribute10                 = $Group.CustomAttribute10
            CustomAttribute11                 = $Group.CustomAttribute11
            CustomAttribute12                 = $Group.CustomAttribute12
            CustomAttribute13                 = $Group.CustomAttribute13
            CustomAttribute14                 = $Group.CustomAttribute14
            CustomAttribute15                 = $Group.CustomAttribute15
            CustomAttribute2                  = $Group.CustomAttribute2
            CustomAttribute3                  = $Group.CustomAttribute3
            CustomAttribute4                  = $Group.CustomAttribute4
            CustomAttribute5                  = $Group.CustomAttribute5
            CustomAttribute6                  = $Group.CustomAttribute6
            CustomAttribute7                  = $Group.CustomAttribute7
            CustomAttribute8                  = $Group.CustomAttribute8
            CustomAttribute9                  = $Group.CustomAttribute9
            HiddenFromAddressListsEnabled     = [bool]::Parse($Group.HiddenFromAddressListsEnabled)
            Identity                          = $Group.Identity
            ReportToManagerEnabled            = [bool]::Parse($Group.ReportToManagerEnabled)
            ReportToOriginatorEnabled         = [bool]::Parse($Group.ReportToOriginatorEnabled)
            SendOofMessageToOriginatorEnabled = [bool]::Parse($Group.SendOofMessageToOriginatorEnabled)
            SimpleDisplayName                 = $Group.SimpleDisplayName
            WindowsEmailAddress               = $Group.WindowsEmailAddress

        }
        $newparams = @{ }
        ForEach ($h in $newhash.keys) {
            if ($($newhash.item($h))) {
                $newparams.add($h, $($newhash.item($h)))
            }
        }
        $setparams = @{ }
        ForEach ($h in $sethash.keys) {
            if ($($sethash.item($h))) {
                $setparams.add($h, $($sethash.item($h)))
            }
        }
        $type = $Group.RecipientTypeDetails

        switch ( $type ) {
            MailUniversalDistributionGroup {
                $newparams['Type'] = "Distribution"
            }
            MailNonUniversalGroup {
                $newparams['Type'] = "Distribution"
            }
            MailUniversalSecurityGroup {
                $newparams['Type'] = "Security"
            }
            RoomList {
                $newparams['Roomlist'] = $true
            }
        }
        try {
            Write-Host "Creating group:`t $($Group.Name)  -  " -ForegroundColor Cyan
            $null = New-DistributionGroup @newparams -ErrorAction Stop
            Write-Host "SUCCESS NEW" -ForegroundColor Green
            $Target = $null
            while (-not $Target) {
                $Target = Get-DistributionGroup -Identity $Group.Name -ErrorAction SilentlyContinue | Select-Object *
                Start-Sleep -Seconds 2
            }
            [PSCustomObject]@{
                SourceName    = $Group.Name
                TargetName    = $Target.Name
                Action        = 'NEW'
                Item          = $Target.DisplayName
                Log           = 'SUCCESS'
                SourcePrimary = $Group.PrimarySmtpAddress
                TargetPrimary = $Target.PrimarySmtpAddress
                SourceGuid    = $Group.Guid
                TargetGuid    = $Target.Guid.ToString()
            }
        }
        catch {
            Write-Host "FAILED NEW" -ForegroundColor Red
            [PSCustomObject]@{
                SourceName    = $Group.Name
                TargetName    = ''
                Action        = 'NEW'
                Item          = $Group.Name
                Log           = $_.Exception.Message
                SourcePrimary = $Group.PrimarySmtpAddress
                TargetPrimary = ''
                SourceGuid    = $Group.Guid
                TargetGuid    = ''
            }
            return
        }
        if ($Target) {
            try {
                Write-Host "Setting group:`t $($Group.Name)  -  " -ForegroundColor White -NoNewline
                Set-DistributionGroup @setparams -ErrorAction Stop
                Write-Host "SUCCESS SET" -ForegroundColor Green
                [PSCustomObject]@{
                    SourceName    = $Group.Name
                    TargetName    = $Target.Name
                    Action        = 'SET'
                    Item          = $Target.DisplayName
                    Log           = 'SUCCESS'
                    SourcePrimary = $Group.PrimarySmtpAddress
                    TargetPrimary = $Target.PrimarySmtpAddress
                    SourceGuid    = $Group.Guid
                    TargetGuid    = $Target.Guid.ToString()
                }
            }
            catch {
                Write-Host "FAILED SET" -ForegroundColor Red
                [PSCustomObject]@{
                    SourceName    = $Group.Name
                    TargetName    = $Target.Name
                    Action        = 'SET'
                    Item          = $Target.DisplayName
                    Log           = $_.Exception.Message
                    SourcePrimary = $Group.PrimarySmtpAddress
                    TargetPrimary = $Target.PrimarySmtpAddress
                    SourceGuid    = $Group.Guid
                    TargetGuid    = $Target.Guid.ToString()
                }
            }
            if ($Group.AcceptMessagesOnlyFrom) {
                try {
                    $Group.AcceptMessagesOnlyFrom -split [regex]::Escape('|') | ForEach-Object {
                        Write-Host "Set AcceptMessagesOnlyFrom:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -AcceptMessagesOnlyFrom @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $AcceptMessagesOnlyFrom = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'AcceptMessagesOnlyFrom'
                            Item          = $AcceptMessagesOnlyFrom
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
                catch {
                    Write-Host "FAILED" -ForegroundColor Red
                    [PSCustomObject]@{
                        SourceName    = $Group.Name
                        TargetName    = $Target.Name
                        Action        = 'AcceptMessagesOnlyFrom'
                        Item          = $AcceptMessagesOnlyFrom
                        Log           = $_.Exception.Message
                        SourcePrimary = $Group.PrimarySmtpAddress
                        TargetPrimary = $Target.PrimarySmtpAddress
                        SourceGuid    = $Group.Guid
                        TargetGuid    = $Target.Guid.ToString()
                    }
                }
            }
            if ($Group.AcceptMessagesOnlyFromDLMembers) {
                $Group.AcceptMessagesOnlyFromDLMembers -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set AcceptMessagesOnlyFromDLMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -AcceptMessagesOnlyFromDLMembers @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $AcceptMessagesOnlyFromDLMembers = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'AcceptMessagesOnlyFromDLMembers'
                            Item          = $AcceptMessagesOnlyFromDLMembers
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'AcceptMessagesOnlyFromDLMembers'
                            Item          = $AcceptMessagesOnlyFromDLMembers
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.BypassModerationFromSendersOrMembers) {
                $Group.BypassModerationFromSendersOrMembers -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set BypassModerationFromSendersOrMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -BypassModerationFromSendersOrMembers @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $BypassModerationFromSendersOrMembers = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'BypassModerationFromSendersOrMembers'
                            Item          = $BypassModerationFromSendersOrMembers
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'BypassModerationFromSendersOrMembers'
                            Item          = $BypassModerationFromSendersOrMembers
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.GrantSendOnBehalfTo) {
                $Group.GrantSendOnBehalfTo -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set GrantSendOnBehalfTo:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -GrantSendOnBehalfTo @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $GrantSendOnBehalfTo = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'GrantSendOnBehalfTo'
                            Item          = $GrantSendOnBehalfTo
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'GrantSendOnBehalfTo'
                            Item          = $GrantSendOnBehalfTo
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.ManagedBy) {
                $Group.ManagedBy -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set ManagedBy:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -ManagedBy @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $ManagedBy = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ManagedBy'
                            Item          = $ManagedBy
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ManagedBy'
                            Item          = $ManagedBy
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.ModeratedBy) {
                $Group.ModeratedBy -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set ModeratedBy:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -ModeratedBy @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $ModeratedBy = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ModeratedBy'
                            Item          = $ModeratedBy
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ModeratedBy'
                            Item          = $ModeratedBy
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.RejectMessagesFrom) {
                $Group.RejectMessagesFrom -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set RejectMessagesFrom:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -RejectMessagesFrom @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $RejectMessagesFrom = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'RejectMessagesFrom'
                            Item          = $RejectMessagesFrom
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'RejectMessagesFrom'
                            Item          = $RejectMessagesFrom
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.RejectMessagesFromDLMembers) {
                $Group.RejectMessagesFromDLMembers -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set RejectMessagesFromDLMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -RejectMessagesFromDLMembers @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $RejectMessagesFromDLMembers = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'RejectMessagesFromDLMembers'
                            Item          = $RejectMessagesFromDLMembers
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'RejectMessagesFromDLMembers'
                            Item          = $RejectMessagesFromDLMembers
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.RejectMessagesFromSendersOrMembers) {
                $Group.RejectMessagesFromSendersOrMembers -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set RejectMessagesFromSendersOrMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -RejectMessagesFromSendersOrMembers @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $RejectMessagesFromSendersOrMembers = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'RejectMessagesFromSendersOrMembers'
                            Item          = $RejectMessagesFromSendersOrMembers
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'RejectMessagesFromSendersOrMembers'
                            Item          = $RejectMessagesFromSendersOrMembers
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.ExtensionCustomAttribute1) {
                $Group.ExtensionCustomAttribute1 -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set ExtensionCustomAttribute1:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -ExtensionCustomAttribute1 @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $ExtensionCustomAttribute1 = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute1'
                            Item          = $ExtensionCustomAttribute1
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute1'
                            Item          = $ExtensionCustomAttribute1
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.ExtensionCustomAttribute2) {
                $Group.ExtensionCustomAttribute2 -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set ExtensionCustomAttribute2:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -ExtensionCustomAttribute2 @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $ExtensionCustomAttribute2 = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute2'
                            Item          = $ExtensionCustomAttribute2
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute2'
                            Item          = $ExtensionCustomAttribute2
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.ExtensionCustomAttribute3) {
                $Group.ExtensionCustomAttribute3 -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set ExtensionCustomAttribute3:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -ExtensionCustomAttribute3 @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $ExtensionCustomAttribute3 = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute3'
                            Item          = $ExtensionCustomAttribute3
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute3'
                            Item          = $ExtensionCustomAttribute3
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.ExtensionCustomAttribute4) {
                $Group.ExtensionCustomAttribute4 -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set ExtensionCustomAttribute4:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -ExtensionCustomAttribute4 @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $ExtensionCustomAttribute4 = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute4'
                            Item          = $ExtensionCustomAttribute4
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute4'
                            Item          = $ExtensionCustomAttribute4
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.ExtensionCustomAttribute5) {
                $Group.ExtensionCustomAttribute5 -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set ExtensionCustomAttribute5:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -ExtensionCustomAttribute5 @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute5'
                            Item          = $ExtensionCustomAttribute5
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'ExtensionCustomAttribute5'
                            Item          = $ExtensionCustomAttribute5
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }
            if ($Group.MailTipTranslations) {
                $Group.MailTipTranslations -split [regex]::Escape('|') | ForEach-Object {
                    try {
                        Write-Host "Set MailTipTranslations:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -MailTipTranslations @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $MailTipTranslations = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'MailTipTranslations'
                            Item          = $MailTipTranslations
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'MailTipTranslations'
                            Item          = $MailTipTranslations
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }

            if ($Group.EmailAddresses) {
                ($Group.EmailAddresses -split [regex]::Escape('|') -match '(?i)x500:.*|smtp:.*@(?!(.*onmicrosoft\.com)).*') | ForEach-Object {
                    try {
                        Write-Host "Set EmailAddresses:`t $($_)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $Group.Identity -emailaddresses @{Add = "$_" } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        $EmailAddresses = $_
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'EmailAddresses'
                            Item          = $EmailAddresses
                            Log           = 'SUCCESS'
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $Group.Name
                            TargetName    = $Target.Name
                            Action        = 'EmailAddresses'
                            Item          = $EmailAddresses
                            Log           = $_.Exception.Message
                            SourcePrimary = $Group.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $Group.Guid
                            TargetGuid    = $Target.Guid.ToString()
                        }
                    }
                }
            }

            # if ($Group.EmailAddresses) {
            #     ($Group.EmailAddresses -split [regex]::Escape('|') -notmatch 'smtp:.*@(?!(.*onmicrosoft\.com|three\.com|four\.com)).*') | ForEach-Object {
            #         Set-DistributionGroup -Identity $Group.Identity -emailaddresses @{Add = "$_" } -ErrorAction Stop
            #     }
            # }

            # if ($Group.EmailAddresses) {
            #     $Group.EmailAddresses -split [regex]::Escape('|') | Where-Object { !($_ -clike "SMTP:*") } | ForEach-Object {
            #         Set-DistributionGroup -Identity $Group.Identity -emailaddresses @{Add = "$_" } -ErrorAction Stop
            #     }
            # }

            if ($Group.x500) {
                try {
                    Write-Host "Set LegacyExchangeDNasX500:`t $($Group.x500)  -  " -ForegroundColor White -NoNewline
                    Set-DistributionGroup -Identity $Group.Identity -emailaddresses @{Add = $Group.x500 } -ErrorAction Stop
                    Write-Host "SUCCESS" -ForegroundColor Green
                    [PSCustomObject]@{
                        SourceName    = $Group.Name
                        TargetName    = $Target.Name
                        Action        = 'LegacyExchangeDNasX500'
                        Item          = $Group.x500
                        Log           = 'SUCCESS'
                        SourcePrimary = $Group.PrimarySmtpAddress
                        TargetPrimary = $Target.PrimarySmtpAddress
                        SourceGuid    = $Group.Guid
                        TargetGuid    = $Target.Guid.ToString()
                    }
                }
                catch {
                    Write-Host "FAILED" -ForegroundColor Red
                    [PSCustomObject]@{
                        SourceName    = $Group.Name
                        TargetName    = $Target.Name
                        Action        = 'LegacyExchangeDNasX500'
                        Item          = $Group.x500
                        Log           = $_.Exception.Message
                        SourcePrimary = $Group.PrimarySmtpAddress
                        TargetPrimary = $Target.PrimarySmtpAddress
                        SourceGuid    = $Group.Guid
                        TargetGuid    = $Target.Guid.ToString()
                    }
                }
                if ($Group.membersSMTP) {
                    $Group.membersSMTP -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Add Member:`t $($_)  -  " -ForegroundColor Yellow -NoNewline
                            Add-DistributionGroupMember -Identity $Group.Identity -member "$_" -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            $membersSMTP = $_
                            [PSCustomObject]@{
                                SourceName    = $Group.Name
                                TargetName    = $Target.Name
                                Action        = 'membersSMTP'
                                Item          = $membersSMTP
                                Log           = 'SUCCESS'
                                SourcePrimary = $Group.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $Group.Guid
                                TargetGuid    = $Target.Guid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $Group.Name
                                TargetName    = $Target.Name
                                Action        = 'membersSMTP'
                                Item          = $membersSMTP
                                Log           = $_.Exception.Message
                                SourcePrimary = $Group.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $Group.Guid
                                TargetGuid    = $Target.Guid.ToString()
                            }
                        }
                    }
                }
            }
        }
    }
}