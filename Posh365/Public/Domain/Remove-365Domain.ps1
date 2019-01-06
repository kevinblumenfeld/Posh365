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
        Write-HostLog -Message "`nTotal Msol Users Found: $($MsolUser.count)" -Status "Success"
        Write-HostLog -Message "Total MailUsers Found: $($MailUser.count)" -Status "Success"
        Write-HostLog -Message "Total Mailboxes Found: $($Mailbox.count)" -Status "Success"

        $MsolProps = @(
            'DisplayName', 'BlockCredential', 'UserPrincipalName', 'UserType', 'ImmutableId'
        )

        $MsolCalcProps = @(
            @{n = "proxyAddresses" ; e = {($_.proxyAddresses | Where-Object {$_ -ne $null}) -join ";" }}
        )

        $MailProps = @(
            'DisplayName', 'Alias', 'LegacyExchangeDN', 'HiddenFromAddressListsEnabled', 'PrimarySmtpAddress'
            'UserPrincipalName', 'SkuAssigned', 'LitigationHoldEnabled', 'IsDirSynced', 'AccountDisabled', 'RecipientTypeDetails'
        )

        $MailCalcProps = @(
            @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join ";" }}
        )

        $MsolUser | Select-Object ($MsolProps + $MsolCalcProps) | Export-Csv ".\MsolUsers.csv" -NoTypeInformation -Encoding UTF8
        $Mailbox | Select-Object ($MailProps + $MailCalcProps) | Export-Csv ".\Mailboxes.csv" -NoTypeInformation -Encoding UTF8
        $MailUser | Select-Object ($MailProps + $MailCalcProps) | Export-Csv ".\MailUsers.csv" -NoTypeInformation -Encoding UTF8

        Write-HostLog -Message "Exported Users, MailUsers & Mailbox details in CSV`n"

        Write-HostLog -Message "Running discovery on Group accounts"
        $DistributionGroup = Get-DistributionGroup -ResultSize unlimited
        $UnifiedGroup = Get-UnifiedGroup -ResultSize unlimited
        Write-HostLog -Message "`nTotal Distribution Groups Found: $($DistributionGroup.count)" -Status "Success"
        Write-HostLog -Message "Total O365 Groups Found: $($UnifiedGroup.count)" -Status "Success"

        $GroupProps = @(
            'DisplayName', 'BlockCredential', 'UserPrincipalName', 'UserType', 'ImmutableId'
        )

        $GroupCalcProps = @(
            @{n = "EmailAddresses" ; e = {($_.EmailAddresses | Where-Object {$_ -ne $null}) -join ";" }}
        )

        $DistributionGroup |  Select-Object ($GroupProps + $GroupCalcProps)  | Export-Csv ".\DistributionGroups.csv" -NoTypeInformation
        $UnifiedGroup | Select-Object ($GroupProps + $GroupCalcProps) | Export-Csv ".\O365Groups.csv" -NoTypeInformation
        Write-HostLog -Message "Exported Distribution Groups & O365 Groups details in CSV`n"
    }

    if ($FlipUPN) {
        $MsolUser = Get-MsolUser -All | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal Msol Users Found: $($MsolUser.count)" -Status "Success"

        $Total = $MsolUser.Count
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
            $EndNumber = Read-Host "Enter EndNumber"

            Write-HostLog -Message "`n"

            $SplitMsol = $MsolUser[$StartNumber..$EndNumber]
            $i = 1
            $Total = $SplitMsol.count

            ForEach ($CurSplitMsol in $SplitMsol) {
                if ($CurSplitMsol.UserPrincipalName -notlike $RoutingDomain) {
                    $MsolProxyAddress = $CurSplitMsol.UserPrincipalName.Split("@")[0] + $DomainSuffix
                    try {
                        Set-MsolUserPrincipalName -UserPrincipalName $($CurSplitMsol.UserPrincipalName) -NewUserPrincipalName $MsolProxyAddress -ErrorAction Stop
                        Write-HostLog -Message "$($CurSplitMsol.UserPrincipalName)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurSplitMsol.UserPrincipalName)" -Status "Failed" -Total $Total -Count $i
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No UPN Flip required: $($CurSplitMsol.UserPrincipalName)" -Status Neutral
                }
                $i++
            }
        }

        if ($ConfirmCount -eq 'n') {
            $i = 1

            ForEach ($CurMsoluser in $MsolUser) {
                if ($CurMsoluser.UserPrincipalName -notlike $RoutingDomain) {
                    $MsolProxyAddress = $CurMsoluser.UserPrincipalName.Split("@")[0] + $DomainSuffix
                    try {
                        Set-MsolUserPrincipalName -UserPrincipalName $($CurMsoluser.UserPrincipalName) -NewUserPrincipalName $MsolProxyAddress -ErrorAction Stop
                        Write-HostLog -Message "$($CurMsoluser.UserPrincipalName)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurMsoluser.UserPrincipalName)" -Status "Failed" -Total $Total -Count $i
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No UPN Flip required: " -NoNewline; Write-HostLog -Message $($CurMsoluser.UserPrincipalName) -Status Neutral
                }
                $i++
            }
        }
        Write-HostLog -Message "`nMsolUsers Completed`n"
    }

    if ($FlipMailbox) {
        $Mailbox = Get-Mailbox -ResultSize Unlimited | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal Mailboxes Found: $($Mailbox.count)" -Status "Success" -Total $Total -Count $i

        $Total = $Mailbox.Count
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
            $EndNumber = Read-Host "Enter EndNumber"

            Write-HostLog -Message "`n"

            $SplitMailbox = $Mailbox[$StartNumber..$EndNumber]
            $i = 1
            $Total = $SplitMailbox.count

            ForEach ($CurMailbox in $SplitMailbox) {
                if ($CurMailbox.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $NewPrimary = $CurMailbox.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix
                    try {
                        Set-Mailbox -Identity $($CurMailbox.PrimarySmtpAddress) -WindowsEmailAddress $NewPrimary -ErrorAction Stop
                        Write-HostLog -Message "$($CurMailbox.PrimarySmtpAddress)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurMailbox.PrimarySmtpAddress)" -Status "Failed" -Total $Total -Count $i
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
                if ($CurMailbox.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $NewPrimary = $CurMailbox.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix
                    try {
                        Set-Mailbox -Identity $($CurMailbox.PrimarySmtpAddress) -WindowsEmailAddress $NewPrimary -ErrorAction Stop
                        Write-HostLog -Message "$($CurMailbox.PrimarySmtpAddress): $NewPrimary" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurMailbox.PrimarySmtpAddress): $NewPrimary" -Status "Failed" -Total $Total -Count $i
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
        $MailUser = Get-MailUser -ResultSize unlimited | Where-Object { $_.RecipientTypeDetails -ne "GuestMailUser" } | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal MailUsers Found: $($MailUser.count)" -Status "Success"
        $Total = $MailUser.Count
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
            $EndNumber = Read-Host "Enter EndNumber"

            Write-Host "`n"

            $SplitMailUser = $MailUser[$StartNumber..$EndNumber]
            $i = 1
            $Total = $SplitMailUser.count
            ForEach ($CurMailUser in $SplitMailUser) {
                if ($CurMailUser.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $MailUsrPrimary = $CurMailUser.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix
                    Try {
                        Set-MailUser -Identity $($CurMailUser.PrimarySmtpAddress) -WindowsEmailAddress $MailUsrPrimary -ErrorAction Stop
                        Write-HostLog -Message "$($CurMailUser.PrimarySmtpAddress)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurMailUser.PrimarySmtpAddress)" -Status "Failed" -Total $Total -Count $i
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
                if ($CurMailUser.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $MailUsrPrimary = $CurMailUser.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix
                    Try {
                        Set-MailUser -Identity $($CurMailUser.PrimarySmtpAddress) -WindowsEmailAddress $MailUsrPrimary -ErrorAction Stop
                        Write-HostLog -Message "$($CurMailUser.PrimarySmtpAddress)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurMailUser.PrimarySmtpAddress)" -Status "Failed" -Total $Total -Count $i
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
        Write-HostLog -Message "`nTotal Mailboxes Found: $($Mailbox.count)" -Status "Success"

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
            $EndNumber = Read-Host "Enter EndNumber"
            Write-HostLog -Message "`n"

            $SplitMailbox = $Mailbox[$StartNumber..$EndNumber]

            $i = 1
            $Total = $SplitMailbox.count

            ForEach ($CurMailbox in $SplitMailbox) {
                if ($CurMailbox.PrimarySmtpAddress -like $RoutingDomain) {
                    $ProxyAddress = $CurMailbox.EmailAddresses | Where-Object {
                        $_ -notlike $WildCardDomain -and $_ -like "smtp*"
                    }
                    Write-HostLog -Message "`tDomains Found for user $($CurMailbox.PrimarySmtpAddress): $($ProxyAddress.count)" -Status "Success"

                    if ($ProxyAddress.Count -gt '1') {
                        ForEach ($CurProxyAddress in $ProxyAddress) {
                            try {
                                Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $CurProxyAddress} -ErrorAction Stop
                                Write-HostLog -Message "t`tRemoving $CurProxyAddress" -Status "Success" -Total $Total -Count $i
                            }
                            catch {
                                Write-HostLog -Message "t`tRemoving $CurProxyAddress" -Status "Failed" -Total $Total -Count $i
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    if ($ProxyAddress.count -eq '1') {
                        try {
                            Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyAddress} -ErrorAction Stop
                            Write-HostLog -Message "`t`tRemoving $ProxyAddress" -Status "Success" -Total $Total -Count $i
                        }
                        catch {
                            Write-HostLog -Message "`t`tRemoving $ProxyAddress" -Status "Failed" -Total $Total -Count $i
                        }
                        Start-Sleep -Seconds 2
                    }
                    $i++
                }
            }
            if ($ConfirmCount -eq 'n') {
                $i = 1
                $Total = $Mailbox.Count

                ForEach ($CurMailbox in $Mailbox) {
                    if ($CurMailbox.PrimarySmtpAddress -like $RoutingDomain) {
                        $ProxyAddress = $CurMailbox.EmailAddresses | Where-Object {$_ -notlike $WildCardDomain -and $_ -like "smtp*"}
                        Write-HostLog -Message "`tDomains Found for user $($CurMailbox.PrimarySmtpAddress): $($ProxyAddress.count)" -Status "Success"

                        if ($ProxyAddress.Count -gt '1') {
                            ForEach ($CurProxyAddress in $ProxyAddress) {
                                try {
                                    Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $CurProxyAddress} -ErrorAction Stop
                                    Write-HostLog -Message "`t`tRemoving $CurProxyAddress " -Status "Success" -Total $Total -Count $i
                                }
                                catch {
                                    Write-HostLog -Message "`t`tRemoving $CurProxyAddress " -Status "Failed" -Total $Total -Count $i
                                }
                                Start-Sleep -Seconds 2
                            }
                        }
                        if ($ProxyAddress.count -eq '1') {
                            try {
                                Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyAddress} -ErrorAction Stop
                                Write-HostLog -Message "`t`tRemoving $ProxyAddress" -Status "Success" -Total $Total -Count $i
                            }
                            catch {
                                Write-HostLog -Message "`t`tRemoving $ProxyAddress" -Status "Failed" -Total $Total -Count $i
                            }
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
            Write-HostLog -Message "`nTotal MailUsers Found: $($MailUser.count)" -Status "Success"

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
                $EndNumber = Read-Host "Enter EndNumber"

                Write-HostLog -Message "`n"

                $SplitMailUser = $MailUser[$StartNumber..$EndNumber]
                $i = 1
                $Total = $SplitMailUser.count

                ForEach ($CurMailUser in $SplitMailUser) {
                    if ($CurMailUser.PrimarySmtpAddress -like $RoutingDomain) {
                        $MailUsrProxyAddress = $CurMailUser.EmailAddresses | Where-Object {
                            $_ -notlike $WildCardDomain -and $_ -like "smtp*"
                        }
                        Write-HostLog -Message "`tDomains Found for user $($CurMailUser.PrimarySmtpAddress): $($MailUsrProxyAddress.count)" -Status "Success"

                        if ($MailUsrProxyAddress.Count -gt '1') {
                            ForEach ($MailProxy in $MailUsrProxyAddress) {
                                try {
                                    Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailProxy} -ErrorAction Stop
                                    Write-HostLog -Message "`t`tRemoving $MailProxy" -Status "Success"
                                }
                                catch {
                                    Write-HostLog -Message "`t`tRemoving $MailProxy" -Status "Failed"
                                }
                                Start-Sleep -Seconds 2
                            }
                        }
                        if ($MailUsrProxyAddress.count -eq '1') {
                            try {
                                Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailUsrProxyAddress} -ErrorAction Stop
                                Write-HostLog -Message "`t`tRemoving $MailUsrProxyAddress" -Status "Success"
                            }
                            catch {
                                Write-HostLog -Message "`t`tRemoving $MailUsrProxyAddress" -Status "Failed"
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    $i++
                }
            }

            if ($ConfirmCount -eq 'n') {
                $i = 1
                $Total = $MailUser.Count

                ForEach ($CurMailUser in $MailUser) {
                    if ($CurMailUser.PrimarySmtpAddress -like $RoutingDomain) {
                        $MailUsrProxyAddress = $CurMailUser.EmailAddresses | Where-Object {$_ -notlike $WildCardDomain -and $_ -like "smtp*"}
                        Write-HostLog -Message "`tDomains Found for user $($CurMailUser.PrimarySmtpAddress): " -NoNewline; Write-HostLog -Message $($MailUsrProxyAddress.count) -Status "Success"

                        if ($MailUsrProxyAddress.Count -gt '1') {
                            ForEach ($MailProxy in $MailUsrProxyAddress) {
                                Write-HostLog -Message "`t`tRemoving $MailProxy : " -NoNewline
                                try {
                                    Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailProxy} -ErrorAction Stop
                                    Write-HostLog -Message "SUCCESS" -Status "Success"
                                }
                                catch {
                                    Write-HostLog -Message "FAILED" -Status "Failed"
                                }
                                Start-Sleep -Seconds 2
                            }
                        }
                        if ($MailUsrProxyAddress.count -eq '1') {
                            try {
                                Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $MailUsrProxyAddress} -ErrorAction Stop
                                Write-HostLog -Message "Removing $MailUsrProxyAddress" -Status "Success"
                            }
                            catch {
                                Write-HostLog -Message "Removing $MailUsrProxyAddress" -Status "Failed"
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
            $DistributionGroup = Get-DistributionGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal Distribution Groups Found: $($DistributionGroup.count)" -Status "Success"

            $i = 1
            $Total = $DistributionGroup.Count

            ForEach ($CurDistributionGroup in $DistributionGroup) {
                if ($CurDistributionGroup.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $NewDLPrimary = $CurDistributionGroup.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix
                    try {
                        Set-DistributionGroup -Identity $($CurDistributionGroup.PrimarySmtpAddress) -PrimarySmtpAddress $NewDLPrimary -ErrorAction Stop
                        Write-HostLog -Message "$($CurDistributionGroup.PrimarySmtpAddress)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurDistributionGroup.PrimarySmtpAddress)" -Status "Failed" -Total $Total -Count $i
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip required: $($CurDistributionGroup.PrimarySmtpAddress)" -Status Neutral
                }
                $i++
            }
            Write-HostLog -Message "`nFlipping Primary for Distribution Groups is Complete`n"
        }

        if ($FlipO365Primary) {
            $UnifiedGroup = Get-UnifiedGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal O365 Groups Found: $($UnifiedGroup.count)" -Status "Success"

            $i = 1
            $Total = $UnifiedGroup.Count

            ForEach ($CurUnifiedGroup in $UnifiedGroup) {
                if ($CurUnifiedGroup.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $NewO365Primary = $CurUnifiedGroup.PrimarySmtpAddress.Split("@")[0] + $DomainSuffix

                    try {
                        Set-UnifiedGroup -Identity $($CurUnifiedGroup.PrimarySmtpAddress) -PrimarySmtpAddress $NewO365Primary -ErrorAction Stop
                        Write-HostLog -Message "$($CurUnifiedGroup.PrimarySmtpAddress):" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostLog -Message "$($CurUnifiedGroup.PrimarySmtpAddress):" -Status "Failed" -Total $Total -Count $i
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip required: $($CurUnifiedGroup.PrimarySmtpAddress)"
                }
                $i++
            }
            Write-HostLog -Message "`nFlipping Primary for O365 Groups is Complete`n"
        }

        if ($RemoveO365Proxy) {
            $UnifiedGroup = Get-UnifiedGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal O365 Groups Found: $($UnifiedGroup.count)" -Status "Success"

            $i = 1
            $Total = $UnifiedGroup.Count

            ForEach ($CurUnifiedGroup in $UnifiedGroup) {
                if ($CurUnifiedGroup.PrimarySmtpAddress -like $RoutingDomain) {
                    $ProxyUGAddress = $CurUnifiedGroup.EmailAddresses | Where-Object { $_ -notlike $WildCardDomain -and $_ -like "smtp*" }
                    Write-HostLog -Message "`tDomains Found for O365 Group $($CurUnifiedGroup.PrimarySmtpAddress): $($ProxyUGAddress.count)" -Status "Success"

                    if ($ProxyUGAddress.Count -gt '1') {
                        ForEach ($CurProxyUGAddress in $ProxyUGAddress) {
                            try {
                                Set-UnifiedGroup -Identity $CurUnifiedGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $CurProxyUGAddress} -ErrorAction Stop
                                Write-HostLog -Message "t`tRemoving $CurProxyUGAddress" -Status "Success" -Total $Total -Count $i
                            }
                            catch {
                                Write-HostLog -Message "t`tRemoving $CurProxyUGAddress" -Status "Failed" -Total $Total -Count $i
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    if ($ProxyUGAddress.count -eq '1') {
                        try {
                            Set-UnifiedGroup -Identity $CurUnifiedGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyUGAddress} -ErrorAction Stop
                            Write-HostLog -Message "`t`tRemoving $ProxyUGAddress" -Status "Success" -Total $Total -Count $i
                        }
                        catch {
                            Write-HostLog -Message "`t`tRemoving $ProxyUGAddress" -Status "Failed" -Total $Total -Count $i
                        }
                        Start-Sleep -Seconds 2
                    }
                }
                $i++
            }
            Write-HostLog -Message "`nProxies removal task from O365 Groups is Complete`n"
        }

        if ($RemoveDLProxy) {
            $DistributionGroup = Get-DistributionGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
            Write-HostLog -Message "`nTotal Distribution Groups Found: $($DistributionGroup.count)" -Status "Success"
            $Total = $DistributionGroup.Count

            ForEach ($CurDistributionGroup in $DistributionGroup) {
                if ($CurDistributionGroup.PrimarySmtpAddress -like $RoutingDomain) {
                    $ProxyDLAddress = $CurDistributionGroup.EmailAddresses | Where-Object { $_ -notlike $WildCardDomain -and $_ -like "smtp*" }
                    Write-HostLog -Message "`tDomains Found for DL $($CurDistributionGroup.PrimarySmtpAddress): $($ProxyDLAddress.count)" -Status "Success"

                    if ($ProxyDLAddress.Count -gt '1') {
                        ForEach ($CurProxyDLAddress in $ProxyDLAddress) {
                            try {
                                Set-DistributionGroup -Identity $CurDistributionGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $CurProxyDLAddress} -ErrorAction Stop
                                Write-HostLog -Message "t`tRemoving $CurProxyDLAddress" -Status "Success" -Total $Total -Count $i
                            }
                            catch {
                                Write-HostLog -Message "t`tRemoving $CurProxyDLAddress" -Status "Failed" -Total $Total -Count $i
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    if ($ProxyDLAddress.count -eq '1') {
                        try {
                            Set-DistributionGroup -Identity $CurDistributionGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $ProxyDLAddress} -ErrorAction Stop
                            Write-HostLog -Message "`t`tRemoving $ProxyDLAddress" -Status "Success" -Total $Total -Count $i
                        }
                        catch {
                            Write-HostLog -Message "`t`tRemoving $ProxyDLAddress" -Status "Failed" -Total $Total -Count $i
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