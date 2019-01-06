function Remove-365Domain {

    param (
        [Parameter()]
        [switch] $ExportOnly,

        [Parameter()]
        [switch] $FlipMailbox,

        [Parameter()]
        [switch] $FlipMailUser,

        [Parameter()]
        [switch] $FlipUPN,

        [Parameter()]
        [switch] $FlipDLPrimary,

        [Parameter()]
        [switch] $FlipO365Primary,

        [Parameter()]
        [switch] $RemoveMailUserProxy,

        [Parameter()]
        [switch] $RemoveMbxProxy,

        [Parameter()]
        [switch] $RemoveO365Proxy,

        [Parameter()]
        [switch] $RemoveDLProxy
    )

    $RoutingDomain = "*@qualyssoftware.onmicrosoft.com"
    $DomainSuffix = "@qualyssoftware.onmicrosoft.com"
    $WildCardDomain = "*.onmicrosoft.com"

    if ($ExportOnly) {
        Write-HostLog -Message "Creating`t$($NewDL.Name)`t$($NewDL.PrimarySmtpAddress)"
        Write-HostLog -Message "Running discovery on user accounts"
        $MsolUser = Get-MsolUser -All | Sort-Object -Property UserPrincipalName
        $Mailbox = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Name -notlike "DiscoverySearchMailbox*" } | Sort-Object -Property UserPrincipalName
        $MailUser = Get-MailUser -ResultSize Unlimited | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal Msol Users Found: $($MsolUser.count)" -Status Success
        Write-HostLog -Message "Total MailUsers Found: $($MailUser.count)" -Status Success
        Write-HostLog -Message "Total Mailboxes Found: $($Mailbox.count)" -Status Success

        $MSOLProps = @(
            'DisplayName', 'BlockCredential', 'UserPrincipalName', 'UserType', 'ImmutableId'
        )

        $MSOLCalcProps = @(
            @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join ";" }}
        )

        $MailProps = @(
            'DisplayName', 'Alias', 'LegacyExchangeDN', 'HiddenFromAddressListsEnabled', 'PrimarySmtpAddress'
            'UserPrincipalName', 'SkuAssigned', 'LitigationHoldEnabled', 'IsDirSynced', 'AccountDisabled', 'RecipientTypeDetails'
        )

        $MailCalcProps = @(
            @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join ";" }}
        )

        $MsolUser | Select-Object ($MSOLProps + $MSOLCalcProps) | Export-Csv ".\MsolUsers.csv" -NoTypeInformation -Encoding UTF8
        $Mailbox | Select-Object ($MailProps + $MailCalcProps) | Export-Csv ".\Mailboxes.csv" -NoTypeInformation -Encoding UTF8
        $MailUser | Select-Object ($MailProps + $MailCalcProps) | Export-Csv ".\MailUsers.csv" -NoTypeInformation -Encoding UTF8

        Write-HostLog -Message "Exported Users, MailUsers & Mailbox details in CSV`n"

        Write-HostLog -Message "Running discovery on Group accounts"
        $DistributionGroups = Get-DistributionGroup -ResultSize unlimited
        $UnifiedGroups = Get-UnifiedGroup -ResultSize unlimited
        Write-HostLog -Message "`nTotal Distribution Groups Found: $($DistributionGroups.count)" -Status Success
        Write-HostLog -Message "Total O365 Groups Found: $($UnifiedGroups.count)" -Status Success

        $GroupProps = @(
            'DisplayName', 'BlockCredential', 'UserPrincipalName', 'UserType', 'ImmutableId'
        )

        $GroupCalcProps = @(
            @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join ";" }}
        )

        $DistributionGroups |  Select-Object ($GroupProps + $GroupCalcProps)  | Export-Csv ".\DistributionGroups.csv" -NoTypeInformation
        $UnifiedGroups | Select-Object ($GroupProps + $GroupCalcProps) | Export-Csv ".\O365Groups.csv" -NoTypeInformation
        Write-HostLog -Message "Exported Distribution Groups & O365 Groups details in CSV`n"
    }

    if ($FlipUPN) {
        $MsolUser = Get-MsolUser -All | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal Msol Users Found: $($MsolUser.count)" -Status Success

        $Count = $MsolUser.Count
        $ConfirmCount = Read-Host "Do you want to split the count?:(y/n)"

        if ($ConfirmCount -eq 'y') {
            Write-HostLog "You need the 'StartNumber' and 'EndNumber' to split the accounts"
            Write-HostLog "################## FOR EXAMPLE ##############################"
            Write-HostLog "If you want to run for first 1000 users"
            Write-HostLog "Enter 'StartNumber' as '0' and 'EndNumber' as '999'`n"
            Write-HostLog "If you want to run for second 1000 users"
            Write-HostLog "Enter 'StartNumber' as '1000' and 'EndNumber' as '1999' and so on...`n"
            Write-HostLog "#############################################################`n"
            $StartNumber = Read-Host "Enter StartNumber"
            $EndNumber = Read-Host "Enter Lastnumber"

            Write-HostLog -Message "`n"

            $NewCount = $MsolUser[$StartNumber..$EndNumber]
            $i = 1
            $Counting = $NewCount.count

            ForEach ($newuser in $NewCount) {
                $pct = [int](($i / $Counting) * 100)
                Write-Progress -Activity "Flipping Primary for MsolUser" -Status " $($newuser.UserPrincipalName) ($i of $Counting)" -PercentComplete $pct

                if ($newuser.UserPrincipalName -notlike $RoutingDomain) {
                    $MSOLproxyAddress = $newuser.userprincipalname.Split("@")[0] + $DomainSuffix
                    Write-HostLog -Message "$($newuser.UserPrincipalName): " -NoNewline
                    try {
                        Set-MsolUserPrincipalName -UserPrincipalName $($newuser.userprincipalname) -NewUserPrincipalName $MSOLproxyAddress -ErrorAction Stop
                        Write-HostLog -Message "SUCCESS" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "FAILED" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No UPN Flip required: $($newuser.userprincipalName)" -Status Neutral
                }
                $i++
            }
        }

        if ($ConfirmCount -eq 'n') {

            $i = 1

            ForEach ($CurMsoluser in $MsolUser) {
                $pct = [int](($i / $Count) * 100)
                Write-Progress -Activity "Flipping Primary for MsolUser" -Status " $($CurMsoluser.UserPrincipalName) ($i of $Count)" -PercentComplete $pct

                if ($CurMsoluser.UserPrincipalName -notlike $RoutingDomain) {
                    $MSOLproxyAddress = $CurMsoluser.userprincipalname.Split("@")[0] + $DomainSuffix
                    Write-HostLog -Message "$($CurMsoluser.UserPrincipalName): " -NoNewline
                    try {
                        Set-MsolUserPrincipalName -UserPrincipalName $($CurMsoluser.userprincipalname) -NewUserPrincipalName $MSOLproxyAddress -ErrorAction Stop
                        Write-HostLog -Message "SUCCESS" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "FAILED" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No UPN Flip required: " -NoNewline; Write-HostLog -Message $($CurMsoluser.userprincipalName) -Status Neutral
                }
                $i++
            }
        }
        Write-HostLog -Message "`nMsolUsers Completed`n"
    }

    if ($FlipMailbox) {
        $Mailbox = Get-Mailbox -ResultSize Unlimited | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal Mailboxes Found: $($Mailbox.count)" -Status Success

        $Count = $Mailbox.Count
        $ConfirmCount = Read-Host "Do you want to split the count?:(y/n)"

        if ($ConfirmCount -eq 'y') {
            Write-HostLog "You need the 'StartNumber' and 'EndNumber' to split the accounts"
            Write-HostLog "################## FOR EXAMPLE ##############################"
            Write-HostLog "If you want to run for first 1000 users"
            Write-HostLog "Enter 'StartNumber' as '0' and 'EndNumber' as '999'`n"
            Write-HostLog "If you want to run for second 1000 users"
            Write-HostLog "Enter 'StartNumber' as '1000' and 'EndNumber' as '1999' and so on...`n"
            Write-HostLog "#############################################################`n"

            $StartNumber = Read-Host "Enter StartNumber"
            $EndNumber = Read-Host "Enter Lastnumber"

            Write-HostLog -Message "`n"

            $NewCount = $Mailbox[$StartNumber..$EndNumber]
            $i = 1
            $Counting = $NewCount.count

            ForEach ($CurMailbox in $NewCount) {
                $pct = [int](($i / $Counting) * 100)
                Write-Progress -Activity "Flipping Primary for Mailbox" -Status " $($CurMailbox.PrimarySmtpAddress) ($i of $Counting)" -PercentComplete $pct

                if ($CurMailbox.PrimarySmtpAddress -notlike $RoutingDomain) {
                    Write-HostLog -Message "$($CurMailbox.PrimarySmtpAddress): " -NoNewline
                    $NewPrimary = $CurMailbox.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix

                    try {
                        Set-Mailbox -Identity $($CurMailbox.PrimarySmtpAddress) -WindowsEmailAddress $NewPrimary -ErrorAction Stop
                        Write-HostLog -Message "SUCCESS" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "FAILED" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip required: $($CurMailbox.PrimarySmtpAddress)" -Status Neutral
                }
                $i++
            }
        }
        if ($ConfirmCount -eq 'n') {
            $i = 1
            ForEach ($CurMailbox in $Mailbox) {
                $pct = [int](($i / $Count) * 100)
                Write-Progress -Activity "Flipping Primary for Mailbox" -Status " $($CurMailbox.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct

                if ($CurMailbox.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $NewPrimary = $CurMailbox.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix
                    try {
                        Set-Mailbox -Identity $($CurMailbox.PrimarySmtpAddress) -WindowsEmailAddress $NewPrimary -ErrorAction Stop
                        Write-HostLog -Message "$($CurMailbox.PrimarySmtpAddress): $NewPrimary" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "$($CurMailbox.PrimarySmtpAddress): $NewPrimary" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip required: $($CurMailbox.PrimarySmtpAddress)" -Status Neutral
                }
                $i++
            }
        }
        Write-HostLog -Message "`nMailboxes Completed`n"
    }

    if ($FlipMailUser) {
        $MailUser = Get-MailUser -ResultSize unlimited | Where-Object {
            $_.RecipientTypeDetails -ne "GuestMailUser"
        } | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal MailUsers Found: $($MailUser.count)" -Status Success

        $Count = $MailUser.Count
        $ConfirmCount = Read-Host "Do you want to split the count?:(y/n)"

        if ($ConfirmCount -eq 'y') {
            Write-HostLog "You need the 'StartNumber' and 'EndNumber' to split the accounts"
            Write-HostLog "################## FOR EXAMPLE ##############################"
            Write-HostLog "If you want to run for first 1000 users"
            Write-HostLog "Enter 'StartNumber' as '0' and 'EndNumber' as '999'`n"
            Write-HostLog "If you want to run for second 1000 users"
            Write-HostLog "Enter 'StartNumber' as '1000' and 'EndNumber' as '1999' and so on...`n"
            Write-HostLog "#############################################################`n"

            $StartNumber = Read-Host "Enter StartNumber"
            $EndNumber = Read-Host "Enter Lastnumber"

            Write-Host "`n"

            $NewCount = $MailUser[$StartNumber..$EndNumber]
            $i = 1
            $Counting = $NewCount.count
            ForEach ($CurMailUser in $NewCount) {
                $pct = [int](($i / $Counting) * 100)
                Write-Progress -Activity "Flipping Primary for MailUser" -Status " $($CurMailUser.PrimarySmtpAddress) ($i of $Counting)" -PercentComplete $pct

                if ($CurMailUser.PrimarySmtpAddress -notlike $RoutingDomain) {
                    Write-HostLog -Message "$($CurMailUser.PrimarySmtpAddress): " -NoNewline
                    $MailUsrPrimary = $CurMailUser.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix

                    Try {
                        Set-MailUser -Identity $($CurMailUser.PrimarySmtpAddress) -WindowsEmailAddress $MailUsrPrimary -ErrorAction Stop
                        Write-HostLog -Message "SUCCESS" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "FAILED" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip Required: " -NoNewline; Write-HostLog -Message $($CurMailUser.PrimarySmtpAddress) -Status Neutral
                }
                $i++
            }
        }
        if ($ConfirmCount -eq 'n') {
            $i = 1
            ForEach ($CurMailUser in $MailUser) {
                $pct = [int](($i / $Count) * 100)
                Write-Progress -Activity "Flipping Primary for MailUser" -Status " $($CurMailUser.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct
                if ($CurMailUser.PrimarySmtpAddress -notlike $RoutingDomain) {
                    Write-HostLog -Message "$($CurMailUser.PrimarySmtpAddress): " -NoNewline
                    $MailUsrPrimary = $CurMailUser.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix
                    Try {
                        Set-MailUser -Identity $($CurMailUser.PrimarySmtpAddress) -WindowsEmailAddress $MailUsrPrimary -ErrorAction Stop
                        Write-HostLog -Message "SUCCESS" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "FAILED" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip Required: " -NoNewline; Write-HostLog -Message $($CurMailUser.PrimarySmtpAddress) -Status Neutral
                }
                $i++
            }
        }
        Write-HostLog -Message "`nMailUsers Completed`n"
    }

    if ($RemoveMbxProxy) {
        $Mailbox = Get-Mailbox -ResultSize Unlimited | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal Mailboxes Found: $($Mailbox.count)" -Status Success

        $ConfirmCount = Read-Host "Do you want to split the count?:(y/n)"

        if ($ConfirmCount -eq 'y') {
            Write-HostLog "You need the 'StartNumber' and 'EndNumber' to split the accounts"
            Write-HostLog "################## FOR EXAMPLE ##############################"
            Write-HostLog "If you want to run for first 1000 users"
            Write-HostLog "Enter 'StartNumber' as '0' and 'EndNumber' as '999'`n"
            Write-HostLog "If you want to run for second 1000 users"
            Write-HostLog "Enter 'StartNumber' as '1000' and 'EndNumber' as '1999' and so on...`n"
            Write-HostLog "#############################################################`n"

            $StartNumber = Read-Host "Enter StartNumber"
            $EndNumber = Read-Host "Enter Lastnumber"
            Write-HostLog -Message "`n"

            $NewCount = $Mailbox[$StartNumber..$EndNumber]

            $i = 1
            $Counting = $NewCount.count

            ForEach ($CurMailbox in $NewCount) {
                $pct = [int](($i / $Counting) * 100)
                Write-Progress -Activity "Removing ProxyAddresses for Mailbox" -Status " $($CurMailbox.PrimarySmtpAddress) ($i of $Counting)" -PercentComplete $pct

                if ($CurMailbox.PrimarySmtpAddress -like $RoutingDomain) {
                    $ProxyAddress = $CurMailbox.EmailAddresses | Where-Object {
                        $_ -notlike $WildCardDomain -and $_ -like "smtp*"
                    }
                    Write-HostLog -Message "`tDomains Found for user $($CurMailbox.PrimarySmtpAddress): " -NoNewline; Write-HostLog -Message $($ProxyAddress.count) -Status Success

                    if ($ProxyAddress.Count -gt '1') {

                        ForEach ($proxy in $ProxyAddress) {
                            try {
                                Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $proxy} -ErrorAction Stop
                                Write-HostLog -Message "t`tRemoving $proxy" -Status Success
                            }
                            catch {
                                Write-HostLog -Message "t`tRemoving $proxy" -Status Failed
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    if ($ProxyAddress.count -eq '1') {
                        try {
                            Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyAddress} -ErrorAction Stop
                            Write-HostLog -Message "`t`tRemoving $ProxyAddress" -Status Success
                        }
                        catch {
                            Write-HostLog -Message "`t`tRemoving $ProxyAddress" -Status Failed
                        }
                        Start-Sleep -Seconds 2
                    }
                    $i++
                }
            }
            if ($ConfirmCount -eq 'n') {
                #Progress
                $i = 1
                $Count = $Mailbox.Count

                ForEach ($CurMailbox in $Mailbox) {
                    $pct = [int](($i / $Count) * 100)
                    Write-Progress -Activity "Removing PrimarySmtpAddress for Mailbox" -Status " $($CurMailbox.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct

                    if ($CurMailbox.PrimarySmtpAddress -like $RoutingDomain) {
                        $ProxyAddress = $CurMailbox.EmailAddresses | Where-Object {$_ -notlike $WildCardDomain -and $_ -like "smtp*"}
                        Write-HostLog -Message "`tDomains Found for user $($CurMailbox.PrimarySmtpAddress): $($ProxyAddress.count)" -Status Success

                        if ($ProxyAddress.Count -gt '1') {

                            ForEach ($proxy in $ProxyAddress) {

                                Write-HostLog -Message "`t`tRemoving $proxy : " -NoNewline
                                try {Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $proxy} -ErrorAction Stop
                                    Write-HostLog -Message "SUCCESS" -Status Success
                                }
                                catch {Write-HostLog -Message "FAILED" -Status Failed}
                                Start-Sleep -Seconds 2
                            }
                        }
                        if ($ProxyAddress.count -eq '1') {

                            Write-HostLog -Message "`t`tRemoving $ProxyAddress :" -Status Neutral -NoNewline
                            try {Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyAddress} -ErrorAction Stop
                                Write-HostLog -Message "SUCCESS" -Status Success
                            }
                            catch {Write-HostLog -Message "FAILED" -Status Failed}
                            Start-Sleep -Seconds 2
                        }
                    }
                    $i++
                }
            }
            Write-HostLog -Message "`nProxies removed from Mailboxes`n"
        }

        if ($RemoveMailUserProxy) {
            $MailUser = Get-MailUser -ResultSize unlimited | Where-Object {$_.RecipientTypeDetails -ne "GuestMailUser"}| Sort-Object -Property UserPrincipalName
            Write-HostLog -Message "`nTotal MailUsers Found: $($MailUser.count)" -Status Success

            $ConfirmCount = Read-Host "Do you want to split the count?:(y/n)"

            if ($ConfirmCount -eq 'y') {
                Write-HostLog "Please provide a 'StartNumber' and 'EndNumber' to split the accounts"
                Write-HostLog "################## FOR EXAMPLE ##############################"
                Write-HostLog "If you want to run for first 1000 users"
                Write-HostLog "Enter 'StartNumber' as '0' and 'EndNumber' as '999'`n"
                Write-HostLog "If you want to run for second 1000 users"
                Write-HostLog "Enter 'StartNumber' as '1000' and 'EndNumber' as '1999' and so on...`n"
                Write-HostLog "#############################################################`n"

                $StartNumber = Read-Host "Enter StartNumber"
                $EndNumber = Read-Host "Enter Lastnumber"

                Write-HostLog -Message "`n"

                $NewCount = $MailUser[$StartNumber..$EndNumber]

                $i = 1
                $Counting = $NewCount.count

                ForEach ($CurMailUser in $NewCount) {
                    $pct = [int](($i / $Counting) * 100)
                    Write-Progress -Activity "Flipping Primary for MailUser" -Status " $($CurMailUser.PrimarySmtpAddress) ($i of $Counting)" -PercentComplete $pct

                    if ($CurMailUser.PrimarySmtpAddress -like $RoutingDomain) {
                        $MailUsrProxyAddress = $CurMailUser.EmailAddresses | Where-Object {
                            $_ -notlike $WildCardDomain -and $_ -like "smtp*"
                        }
                        Write-HostLog -Message "`tDomains Found for user $($CurMailUser.PrimarySmtpAddress): $($MailUsrProxyAddress.count)" -Status Success

                        if ($MailUsrProxyAddress.Count -gt '1') {
                            ForEach ($MailProxy in $MailUsrProxyAddress) {
                                Write-HostLog -Message "`t`tRemoving $MailProxy : " -NoNewline

                                try {
                                    Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailProxy} -ErrorAction Stop
                                    Write-HostLog -Message "SUCCESS" -Status Success
                                }
                                catch {
                                    Write-HostLog -Message "FAILED" -Status Failed
                                }
                                Start-Sleep -Seconds 2
                            }
                        }
                        if ($MailUsrProxyAddress.count -eq '1') {
                            try {
                                Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailUsrProxyAddress} -ErrorAction Stop
                                Write-HostLog -Message "`t`tRemoving $MailUsrProxyAddress" -Status Success
                            }
                            catch {
                            Write-HostLog -Message "`t`tRemoving $MailUsrProxyAddress" -Status Failed
                        }
                            Start-Sleep -Seconds 2
                        }
                    }
                    $i++
                }
            }

            if ($ConfirmCount -eq 'n') {
                $i = 1
                $Count = $MailUser.Count

                ForEach ($CurMailUser in $MailUser) {
                    $pct = [int](($i / $Count) * 100)
                    Write-Progress -Activity "Flipping Primary for MailUser" -Status " $($CurMailUser.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct

                    if ($CurMailUser.PrimarySmtpAddress -like $RoutingDomain) {
                        $MailUsrProxyAddress = $CurMailUser.EmailAddresses | Where-Object {$_ -notlike $WildCardDomain -and $_ -like "smtp*"}
                        Write-HostLog -Message "`tDomains Found for user $($CurMailUser.PrimarySmtpAddress): " -NoNewline; Write-HostLog -Message $($MailUsrProxyAddress.count) -Status Success

                        if ($MailUsrProxyAddress.Count -gt '1') {
                            ForEach ($MailProxy in $MailUsrProxyAddress) {
                                Write-HostLog -Message "`t`tRemoving $MailProxy : " -NoNewline
                                try {
                                    Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailProxy} -ErrorAction Stop
                                    Write-HostLog -Message "SUCCESS" -Status Success
                                }
                                catch {
                                    Write-HostLog -Message "FAILED" -Status Failed
                                }
                                Start-Sleep -Seconds 2
                            }
                        }
                        if ($MailUsrProxyAddress.count -eq '1') {
                            try {
                                Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailUsrProxyAddress} -ErrorAction Stop
                                Write-HostLog -Message "Removing $MailUsrProxyAddress" -Status Success
                            }
                            catch {
                                Write-HostLog -Message "Removing $MailUsrProxyAddress" -Status Failed
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    $i++
                    Start-Sleep -Seconds 5
                }
            }
            Write-HostLog -Message "`nProxies removed from MailUsers`n"
        }

        if ($FlipDLPrimary) {
            $DistributionGroups = Get-DistributionGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal Distribution Groups Found: $($DistributionGroups.count)" -Status Success

            $i = 1
            $Count = $DistributionGroups.Count

            ForEach ($DistGroup in $DistributionGroups) {
                $pct = [int](($i / $Count) * 100)
                Write-Progress -Activity "Flipping Primary for DL" -Status " $($DistGroup.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct

                if ($DistGroup.PrimarySmtpAddress -notlike $RoutingDomain) {
                    Write-HostLog -Message "$($DistGroup.PrimarySmtpAddress): " -NoNewline
                    $NewDLPrimary = $DistGroup.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix

                    try {
                        Set-DistributionGroup -Identity $($DistGroup.PrimarySmtpAddress) -PrimarySmtpAddress $NewDLPrimary -ErrorAction Stop
                        Write-HostLog -Message "SUCCESS" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "FAILED" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip required: $($DistGroup.PrimarySmtpAddress)" -Status Neutral
                }
                $i++
            }
            Write-HostLog -Message "`nFlipping Primary for Distribution Groups is Complete`n"
        }

        if ($FlipO365Primary) {
            $UnifiedGroups = Get-UnifiedGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal O365 Groups Found: $($UnifiedGroups.count)" -Status Success

            $i = 1
            $Count = $UnifiedGroups.Count

            ForEach ($O365Group in $UnifiedGroups) {
                $pct = [int](($i / $Count) * 100)
                Write-Progress -Activity "Flipping Primary for O365 Group" -Status " $($O365Group.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct

                if ($O365Group.PrimarySmtpAddress -notlike $RoutingDomain) {
                    Write-HostLog -Message "$($O365Group.PrimarySmtpAddress): " -NoNewline
                    $NewO365Primary = $O365Group.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix

                    try {
                        Set-UnifiedGroup -Identity $($O365Group.PrimarySmtpAddress) -PrimarySmtpAddress $NewO365Primary -ErrorAction Stop
                        Write-HostLog -Message "SUCCESS" -Status Success
                    }
                    catch {
                        Write-HostLog -Message "FAILED" -Status Failed
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip required: $($O365Group.PrimarySmtpAddress)"
                }
                $i++
            }
            Write-HostLog -Message "`nFlipping Primary for O365 Groups is Complete`n"
        }

        if ($RemoveO365Proxy) {
            $UnifiedGroups = Get-UnifiedGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal O365 Groups Found: $($UnifiedGroups.count)" -Status Success

            $i = 1
            $Count = $UnifiedGroups.Count

            ForEach ($O365Group in $UnifiedGroups) {
                $pct = [int](($i / $Count) * 100)
                Write-Progress -Activity "Removing Proxies from O365 Group" -Status " $($O365Group.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct

                if ($O365Group.PrimarySmtpAddress -like $RoutingDomain) {
                    $ProxyUGAddress = $O365Group.EmailAddresses | Where-Object {
                        $_ -notlike $WildCardDomain -and $_ -like "smtp*"
                    }
                    Write-HostLog -Message "`tDomains Found for O365 Group $($O365Group.PrimarySmtpAddress): $($ProxyUGAddress.count)" -Status Success

                    if ($ProxyUGAddress.Count -gt '1') {
                        ForEach ($proxyUG in $ProxyUGAddress) {
                            try {
                                Set-UnifiedGroup -Identity $O365Group.PrimarySmtpAddress -EmailAddresses @{Remove = $proxyUG} -ErrorAction Stop
                                Write-HostLog -Message "t`tRemoving $proxyUG" -Status Success
                            }
                            catch {
                                Write-HostLog -Message ": FAILED" -Status Failed
                            }
                            Start-Sleep -Seconds 2
                        }

                    }
                    if ($ProxyUGAddress.count -eq '1') {
                        try {
                            Set-UnifiedGroup -Identity $O365Group.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyUGAddress} -ErrorAction Stop
                            Write-HostLog -Message "`t`tRemoving $ProxyUGAddress" -Status Success
                        }
                        catch {
                            Write-HostLog -Message "`t`tRemoving $ProxyUGAddress" -Status Failed
                        }
                        Start-Sleep -Seconds 2
                    }
                }
                $i++
            }
            Write-HostLog -Message "`nProxies removal task from O365 Groups is Complete`n"
        }

        if ($RemoveDLProxy) {
            $DistributionGroups = Get-DistributionGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal Distribution Groups Found: $($DistributionGroups.count)" -Status Success
            $Count = $DistributionGroups.Count

            ForEach ($DistGroup in $DistributionGroups) {
                $pct = [int](($i / $Count) * 100)
                Write-Progress -Activity "Removing proxies for DL" -Status " $($DistGroup.PrimarySmtpAddress) ($i of $Count)" -PercentComplete $pct

                if ($DistGroup.PrimarySmtpAddress -like $RoutingDomain) {
                    $ProxyDLAddress = $DistGroup.EmailAddresses | Where-Object {
                        $_ -notlike $WildCardDomain -and $_ -like "smtp*"
                    }
                    Write-HostLog -Message "`tDomains Found for DL $($DistGroup.PrimarySmtpAddress): $($ProxyDLAddress.count)" -Status Success

                    if ($ProxyDLAddress.Count -gt '1') {
                        ForEach ($ProxyDL in $ProxyDLAddress) {
                            try {
                                Set-DistributionGroup -Identity $DistGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyDL} -ErrorAction Stop
                                Write-HostLog -Message "t`tRemoving $ProxyDL" -Status Success
                            }
                            catch {
                                Write-HostLog -Message "t`tRemoving $ProxyDL" -Status Failed
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    if ($ProxyDLAddress.count -eq '1') {
                        try {
                            Set-DistributionGroup -Identity $DistGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyDLAddress} -ErrorAction Stop
                            Write-HostLog -Message "`t`tRemoving $ProxyDLAddress" -Status Success
                        }
                        catch {
                            Write-HostLog -Message "`t`tRemoving $ProxyDLAddress" -Status Failed
                        }
                        Start-Sleep -Seconds 2
                    }
                }
                $i++
            }
            Write-HostLog -Message "`nProxies removal task from Distribution Groups is Complete`n"
        }
    }
}