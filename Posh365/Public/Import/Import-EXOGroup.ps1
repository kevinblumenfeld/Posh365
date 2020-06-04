function Import-EXOGroup {
    <#
    .SYNOPSIS
    Import Office 365 Distribution Groups

    .DESCRIPTION
    Import Office 365 Distribution Groups

    .PARAMETER Groups
    CSV of new groups and attributes to create.

    .EXAMPLE
    Import-Csv .\importgroups.csv | Import-EXOGroup | Export-csv .\results.csv -nti


    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        $Groups
    )

    Process {
        ForEach ($CurGroup in $Groups) {
            $newhash = @{
                Alias                              = $CurGroup.Alias
                BypassNestedModerationEnabled      = [bool]::Parse($CurGroup.BypassNestedModerationEnabled)
                DisplayName                        = $CurGroup.DisplayName
                IgnoreNamingPolicy                 = $CurGroup.IgnoreNamingPolicy
                MemberDepartRestriction            = $CurGroup.MemberDepartRestriction
                MemberJoinRestriction              = $CurGroup.MemberJoinRestriction
                ModerationEnabled                  = [bool]::Parse($CurGroup.ModerationEnabled)
                Name                               = $CurGroup.Name
                Notes                              = $CurGroup.Notes
                PrimarySmtpAddress                 = $CurGroup.PrimarySmtpAddress
                RequireSenderAuthenticationEnabled = [bool]::Parse($CurGroup.RequireSenderAuthenticationEnabled)
                SendModerationNotifications        = $CurGroup.SendModerationNotifications
            }
            $sethash = @{
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
                HiddenFromAddressListsEnabled     = [bool]::Parse($CurGroup.HiddenFromAddressListsEnabled)
                Identity                          = $CurGroup.Identity
                ReportToManagerEnabled            = [bool]::Parse($CurGroup.ReportToManagerEnabled)
                ReportToOriginatorEnabled         = [bool]::Parse($CurGroup.ReportToOriginatorEnabled)
                SendOofMessageToOriginatorEnabled = [bool]::Parse($CurGroup.SendOofMessageToOriginatorEnabled)
                SimpleDisplayName                 = $CurGroup.SimpleDisplayName
                WindowsEmailAddress               = $CurGroup.WindowsEmailAddress

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
            $type = $CurGroup.RecipientTypeDetails

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
                Write-Host "Creating group:`t $($CurGroup.Name)  -  " -ForegroundColor Cyan -NoNewline
                New-DistributionGroup @newparams -ErrorAction Stop
                Write-Host "SUCCESS" -ForegroundColor Green
                $Target = $null
                $Target = Get-DistributionGroup -Identity $CurGroup.Name -ErrorAction SilentlyContinue
                [PSCustomObject]@{
                    SourceName    = $CurGroup.Name
                    TargetName    = $Target.Name
                    Action        = 'NEW'
                    Item          = $Target.DisplayName
                    Log           = 'SUCCESS'
                    SourcePrimary = $CurGroup.PrimarySmtpAddress
                    TargetPrimary = $Target.PrimarySmtpAddress
                    SourceGuid    = $CurGroup.ExchangeGuid
                    TargetGuid    = $Target.ExchangeGuid.ToString()
                }
            }
            catch {
                Write-Host "FAILED" -ForegroundColor Red
                [PSCustomObject]@{
                    SourceName    = $CurGroup.Name
                    TargetName    = ''
                    Action        = 'NEW'
                    Item          = 'FAILED'
                    Log           = $_.Exception.Message
                    SourcePrimary = $CurGroup.PrimarySmtpAddress
                    TargetPrimary = ''
                    SourceGuid    = $CurGroup.ExchangeGuid
                    TargetGuid    = ''
                }
                return
            }
            if ($Target) {
                try {
                    Write-Host "Setting group:`t $($CurGroup.Name)  -  " -ForegroundColor White -NoNewline
                    Set-DistributionGroup @setparams -ErrorAction Stop
                    Write-Host "SUCCESS" -ForegroundColor Green
                    [PSCustomObject]@{
                        SourceName    = $CurGroup.Name
                        TargetName    = $Target.Name
                        Action        = 'SET'
                        Item          = $Target.DisplayName
                        Log           = 'SUCCESS'
                        SourcePrimary = $CurGroup.PrimarySmtpAddress
                        TargetPrimary = $Target.PrimarySmtpAddress
                        SourceGuid    = $CurGroup.ExchangeGuid
                        TargetGuid    = $Target.ExchangeGuid.ToString()
                    }
                }
                catch {
                    Write-Host "FAILED" -ForegroundColor Red
                    [PSCustomObject]@{
                        SourceName    = $CurGroup.Name
                        TargetName    = $Target.Name
                        Action        = 'SET'
                        Item          = $Target.DisplayName
                        Log           = 'SUCCESS'
                        SourcePrimary = $CurGroup.PrimarySmtpAddress
                        TargetPrimary = $Target.PrimarySmtpAddress
                        SourceGuid    = $CurGroup.ExchangeGuid
                        TargetGuid    = $Target.ExchangeGuid.ToString()
                    }
                }
                if ($CurGroup.AcceptMessagesOnlyFrom) {
                    try {
                        $CurGroup.AcceptMessagesOnlyFrom -split [regex]::Escape('|') | ForEach-Object {
                            Write-Host "Set AcceptMessagesOnlyFrom:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFrom @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'AcceptMessagesOnlyFrom'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $CurGroup.Name
                            TargetName    = $Target.Name
                            Action        = 'AcceptMessagesOnlyFrom'
                            Item          = $_
                            Log           = 'FAILED'
                            SourcePrimary = $CurGroup.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $CurGroup.ExchangeGuid
                            TargetGuid    = $Target.ExchangeGuid.ToString()
                        }
                    }
                }
                if ($CurGroup.AcceptMessagesOnlyFromDLMembers) {
                    $CurGroup.AcceptMessagesOnlyFromDLMembers -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set AcceptMessagesOnlyFromDLMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -AcceptMessagesOnlyFromDLMembers @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'AcceptMessagesOnlyFromDLMembers'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'AcceptMessagesOnlyFromDLMembers'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.BypassModerationFromSendersOrMembers) {
                    $CurGroup.BypassModerationFromSendersOrMembers -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set BypassModerationFromSendersOrMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -BypassModerationFromSendersOrMembers @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'BypassModerationFromSendersOrMembers'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'BypassModerationFromSendersOrMembers'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.GrantSendOnBehalfTo) {
                    $CurGroup.GrantSendOnBehalfTo -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set GrantSendOnBehalfTo:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -GrantSendOnBehalfTo @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'GrantSendOnBehalfTo'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'GrantSendOnBehalfTo'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.ManagedBy) {
                    $CurGroup.ManagedBy -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set ManagedBy:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -ManagedBy @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ManagedBy'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ManagedBy'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.ModeratedBy) {
                    $CurGroup.ModeratedBy -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set ModeratedBy:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -ModeratedBy @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ModeratedBy'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ModeratedBy'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.RejectMessagesFrom) {
                    $CurGroup.RejectMessagesFrom -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set RejectMessagesFrom:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFrom @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'RejectMessagesFrom'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'RejectMessagesFrom'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.RejectMessagesFromDLMembers) {
                    $CurGroup.RejectMessagesFromDLMembers -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set RejectMessagesFromDLMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromDLMembers @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'RejectMessagesFromDLMembers'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'RejectMessagesFromDLMembers'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.RejectMessagesFromSendersOrMembers) {
                    $CurGroup.RejectMessagesFromSendersOrMembers -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set RejectMessagesFromSendersOrMembers:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -RejectMessagesFromSendersOrMembers @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'RejectMessagesFromSendersOrMembers'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'RejectMessagesFromSendersOrMembers'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.ExtensionCustomAttribute1) {
                    $CurGroup.ExtensionCustomAttribute1 -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set ExtensionCustomAttribute1:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute1 @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute1'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute1'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.ExtensionCustomAttribute2) {
                    $CurGroup.ExtensionCustomAttribute2 -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set ExtensionCustomAttribute2:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute2 @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute2'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute2'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.ExtensionCustomAttribute3) {
                    $CurGroup.ExtensionCustomAttribute3 -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set ExtensionCustomAttribute3:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute3 @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute3'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute3'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.ExtensionCustomAttribute4) {
                    $CurGroup.ExtensionCustomAttribute4 -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set ExtensionCustomAttribute4:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute4 @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute4'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute4'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.ExtensionCustomAttribute5) {
                    $CurGroup.ExtensionCustomAttribute5 -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set ExtensionCustomAttribute5:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -ExtensionCustomAttribute5 @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute5'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'ExtensionCustomAttribute5'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }
                if ($CurGroup.MailTipTranslations) {
                    $CurGroup.MailTipTranslations -split [regex]::Escape('|') | ForEach-Object {
                        try {
                            Write-Host "Set MailTipTranslations:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -MailTipTranslations @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'MailTipTranslations'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'MailTipTranslations'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }

                if ($CurGroup.EmailAddresses) {
                    ($CurGroup.EmailAddresses -split [regex]::Escape('|') -match '(?i)x500:.*|smtp:.*@(?!(.*onmicrosoft\.com)).*') | ForEach-Object {
                        try {
                            Write-Host "Set EmailAddresses:`t $($_)  -  " -ForegroundColor White -NoNewline
                            Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_" } -ErrorAction Stop
                            Write-Host "SUCCESS" -ForegroundColor Green
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'EmailAddresses'
                                Item          = $_
                                Log           = 'SUCCESS'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                        catch {
                            Write-Host "FAILED" -ForegroundColor Red
                            [PSCustomObject]@{
                                SourceName    = $CurGroup.Name
                                TargetName    = $Target.Name
                                Action        = 'EmailAddresses'
                                Item          = $_
                                Log           = 'FAILED'
                                SourcePrimary = $CurGroup.PrimarySmtpAddress
                                TargetPrimary = $Target.PrimarySmtpAddress
                                SourceGuid    = $CurGroup.ExchangeGuid
                                TargetGuid    = $Target.ExchangeGuid.ToString()
                            }
                        }
                    }
                }

                # if ($CurGroup.EmailAddresses) {
                #     ($CurGroup.EmailAddresses -split [regex]::Escape('|') -notmatch 'smtp:.*@(?!(.*onmicrosoft\.com|three\.com|four\.com)).*') | ForEach-Object {
                #         Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_" } -ErrorAction Stop
                #     }
                # }

                # if ($CurGroup.EmailAddresses) {
                #     $CurGroup.EmailAddresses -split [regex]::Escape('|') | Where-Object { !($_ -clike "SMTP:*") } | ForEach-Object {
                #         Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = "$_" } -ErrorAction Stop
                #     }
                # }

                if ($CurGroup.x500) {
                    try {
                        Write-Host "Set LegacyExchangeDNasX500:`t $($CurGroup.x500)  -  " -ForegroundColor White -NoNewline
                        Set-DistributionGroup -Identity $CurGroup.Identity -emailaddresses @{Add = $CurGroup.x500 } -ErrorAction Stop
                        Write-Host "SUCCESS" -ForegroundColor Green
                        [PSCustomObject]@{
                            SourceName    = $CurGroup.Name
                            TargetName    = $Target.Name
                            Action        = 'LegacyExchangeDNasX500'
                            Item          = $_
                            Log           = 'SUCCESS'
                            SourcePrimary = $CurGroup.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $CurGroup.ExchangeGuid
                            TargetGuid    = $Target.ExchangeGuid.ToString()
                        }
                    }
                    catch {
                        Write-Host "FAILED" -ForegroundColor Red
                        [PSCustomObject]@{
                            SourceName    = $CurGroup.Name
                            TargetName    = $Target.Name
                            Action        = 'LegacyExchangeDNasX500'
                            Item          = $_
                            Log           = 'FAILED'
                            SourcePrimary = $CurGroup.PrimarySmtpAddress
                            TargetPrimary = $Target.PrimarySmtpAddress
                            SourceGuid    = $CurGroup.ExchangeGuid
                            TargetGuid    = $Target.ExchangeGuid.ToString()
                        }
                    }
                    if ($CurGroup.membersSMTP) {
                        $CurGroup.membersSMTP -split [regex]::Escape('|') | ForEach-Object {
                            try {
                                Write-Host "Add Member:`t $($_)  -  " -ForegroundColor Yellow -NoNewline
                                Add-DistributionGroupMember -Identity $CurGroup.Identity -member "$_" -ErrorAction Stop
                                Write-Host "SUCCESS" -ForegroundColor Green
                                [PSCustomObject]@{
                                    SourceName    = $CurGroup.Name
                                    TargetName    = $Target.Name
                                    Action        = 'membersSMTP'
                                    Item          = $_
                                    Log           = 'SUCCESS'
                                    SourcePrimary = $CurGroup.PrimarySmtpAddress
                                    TargetPrimary = $Target.PrimarySmtpAddress
                                    SourceGuid    = $CurGroup.ExchangeGuid
                                    TargetGuid    = $Target.ExchangeGuid.ToString()
                                }
                            }
                            catch {
                                Write-Host "FAILED" -ForegroundColor Red
                                [PSCustomObject]@{
                                    SourceName    = $CurGroup.Name
                                    TargetName    = $Target.Name
                                    Action        = 'membersSMTP'
                                    Item          = $_
                                    Log           = 'FAILED'
                                    SourcePrimary = $CurGroup.PrimarySmtpAddress
                                    TargetPrimary = $Target.PrimarySmtpAddress
                                    SourceGuid    = $CurGroup.ExchangeGuid
                                    TargetGuid    = $Target.ExchangeGuid.ToString()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}