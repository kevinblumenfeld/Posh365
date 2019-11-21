function Remove-365Domain {
    <#
    .SYNOPSIS
    Used to remove an Office 365 Domain by flipping Primaries and UPNs to onmicrosoft addresses
    For removal of secondary proxy addresses use Remove-MailboxAddress, Remove-GroupAddress and Remove-UnifiedGroupAddress
    Each has proper PS help.

    .DESCRIPTION
    Used to remove an Office 365 Domain by flipping Primaries and UPNs to onmicrosoft addresses

    .PARAMETER FlipMailbox
    Parameter description

    .PARAMETER FlipMailUser
    Parameter description

    .PARAMETER FlipUPN
    Parameter description

    .PARAMETER FlipDLPrimary
    Parameter description

    .PARAMETER FlipUGPrimary
    Parameter description

    .PARAMETER RoutingDomain
    For example: "contoso.onmicrosoft.com"

    .PARAMETER DomainSuffix
    For example: "contoso.onmicrosoft.com"

    .PARAMETER WildCardDomain
    For example: "*.onmicrosoft.com"

    .EXAMPLE
    Remove-365Domain -FlipUPN -RoutingDomain 'contoso.onmicrosoft.com' -DomainSuffix 'contoso.onmicrosoft.com' -WildCardDomain "*.onmicrosoft.com"

    .EXAMPLE
    Remove-365Domain -FlipMailbox -RoutingDomain 'contoso.onmicrosoft.com' -DomainSuffix 'contoso.onmicrosoft.com' -WildCardDomain "*.onmicrosoft.com"

    .NOTES
    For removal of secondary proxy addresses use Remove-MailboxAddress, Remove-GroupAddress and Remove-UnifiedGroupAddress. each has proper PS help.
    #>

    param (
        [Parameter()]
        [switch]
        $FlipMailbox,

        [Parameter()]
        [switch]
        $FlipMailUser,

        [Parameter()]
        [switch]
        $FlipUPN,

        [Parameter()]
        [switch]
        $FlipDLPrimary,

        [Parameter()]
        [switch]
        $FlipUGPrimary,

        [Parameter(Mandatory)]
        [string]
        $RoutingDomain,

        [Parameter(Mandatory)]
        [string]
        $DomainSuffix,

        [Parameter(Mandatory)]
        [string]
        $WildCardDomain

        <#

        [Parameter()]
        [switch]
        $RemoveMailUserProxy,

        [Parameter()]
        [switch]
        $RemoveMbxProxy,

        [Parameter()]
        [switch]
        $RemoveUGProxy,

        [Parameter()]
        [switch]
        $RemoveDLProxy

        #>
    )
    if ($FlipUPN) {
        $MsolUser = Get-MsolUser -All | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal MsolUsers Found: $($MsolUser.count)" -Status "Success"

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

            $MsolUser = $MsolUser[$StartNumber..$EndNumber]
        }

        if ($ConfirmCount -eq 'n' -or $ConfirmCount -eq 'y') {

            $i = 1
            $Total = $MsolUser.count

            ForEach ($CurMsoluser in $MsolUser) {
                if ($CurMsoluser.UserPrincipalName -notmatch $RoutingDomain) {
                    $MsolProxyAddress = '{0}@{1}' -f $CurMsoluser.UserPrincipalName.Split("@")[0], $DomainSuffix
                    try {
                        Set-MsolUserPrincipalName -ObjectId $($CurMsoluser.ObjectId).ToString() -NewUserPrincipalName $MsolProxyAddress -ErrorAction Stop
                        Write-HostProgress -Message "$($CurMsoluser.UserPrincipalName)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostProgress -Message "$($CurMsoluser.UserPrincipalName)" -Status "Failed" -Total $Total -Count $i
                        $_
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No UPN Flip required: $($CurMsoluser.UserPrincipalName)" -Status "Neutral"
                }
                $i++
            }
        }
        Write-HostLog -Message "`nMsolUsers Completed`n"
    }

    if ($FlipMailbox) {
        $Mailbox = Get-EXOMailbox -ResultSize Unlimited | Sort-Object -Property UserPrincipalName
        Write-HostProgress -Message "`nTotal Mailboxes Found: $($Mailbox.count)" -Status "Success" -Total $Total -Count $i

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

            $Mailbox = $Mailbox[$StartNumber..$EndNumber]

        }
        if ($ConfirmCount -eq 'n' -or $ConfirmCount -eq 'y') {

            $i = 1
            $Total = $Mailbox.count

            ForEach ($CurMailbox in $Mailbox) {
                if ($CurMailbox.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $NewPrimary = '{0}@{1}' -f $CurMailbox.PrimarySmtpAddress.Split("@")[0], $DomainSuffix
                    try {
                        Set-Mailbox -Identity $($CurMailbox.PrimarySmtpAddress) -WindowsEmailAddress $NewPrimary -ErrorAction Stop
                        Write-HostProgress -Message "$($CurMailbox.PrimarySmtpAddress): $NewPrimary" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostProgress -Message "$($CurMailbox.PrimarySmtpAddress): $NewPrimary" -Status "Failed" -Total $Total -Count $i
                        $_.Exception.Message
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip required: $($CurMailbox.PrimarySmtpAddress)" -Status "Neutral"
                }
                $i++
            }
        }
        Write-HostLog -Message "`nMailboxes Completed`n"
    }

    if ($FlipMailUser) {
        $MailUser = Get-MailUser -ResultSize unlimited | Where-Object { $_.RecipientTypeDetails -ne "GuestMailUser" } | Sort-Object -Property UserPrincipalName
        Write-HostLog -Message "`nTotal MailUsers Found: $($MailUser.count)" -Status "Success"

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

            $MailUser = $MailUser[$StartNumber..$EndNumber]
        }
        if ($ConfirmCount -eq 'n' -or $ConfirmCount -eq 'y') {

            $i = 1
            $Total = $MailUser.Count

            ForEach ($CurMailUser in $MailUser) {
                if ($CurMailUser.PrimarySmtpAddress -notlike $RoutingDomain) {
                    $MailUsrPrimary = '{0}@{1}' -f $CurMailUser.PrimarySmtpAddress.Split("@")[0], $DomainSuffix
                    Try {
                        Set-MailUser -Identity $($CurMailUser.PrimarySmtpAddress) -WindowsEmailAddress $MailUsrPrimary -ErrorAction Stop
                        Write-HostProgress -Message "$($CurMailUser.PrimarySmtpAddress)" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostProgress -Message "$($CurMailUser.PrimarySmtpAddress)" -Status "Failed" -Total $Total -Count $i
                        $_.Exception.Message
                    }
                    Start-Sleep -Seconds 2
                }
                else {
                    Write-HostLog -Message "No Primary Flip Required: $($CurMailUser.PrimarySmtpAddress)" -Status "Neutral"
                }
                $i++
            }
        }
        Write-HostLog -Message "`nMailUsers Completed`n"
    }
    <#
    if ($RemoveMbxProxy) {
        $Mailbox = Get-EXOMailbox -ResultSize Unlimited | Sort-Object -Property UserPrincipalName
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

            $Mailbox = $Mailbox[$StartNumber..$EndNumber]

            if ($ConfirmCount -eq 'n' -or $ConfirmCount -eq 'y') {

                $i = 1
                $Total = $Mailbox.Count

                ForEach ($CurMailbox in $Mailbox) {
                    if ($CurMailbox.PrimarySmtpAddress -like $RoutingDomain) {
                        $ProxyAddress = $CurMailbox.EmailAddresses | Where-Object { $_ -notlike $WildCardDomain -and $_ -like "smtp*" }
                        Write-HostLog -Message "`tAddresses Found for user $($CurMailbox.PrimarySmtpAddress): $($ProxyAddress.count)" -Status "Success"
                        ForEach ($CurProxyAddress in $ProxyAddress) {
                            try {
                                Set-Mailbox -Identity $CurMailbox.PrimarySmtpAddress -EmailAddresses @{Remove = $CurProxyAddress } -ErrorAction Stop
                                Write-HostProgress -Message "`t`tRemoving $CurProxyAddress " -Status "Success" -Total $Total -Count $i
                            }
                            catch {
                                Write-HostProgress -Message "`t`tRemoving $CurProxyAddress " -Status "Failed" -Total $Total -Count $i
                                $_.Exception.Message
                            }
                            Start-Sleep -Seconds 2
                        }
                    }
                    $i++
                }
            }
            Write-HostLog -Message "`nProxies removed from Mailboxes`n"
        }
    }
    if ($RemoveMailUserProxy) {
        $MailUser = Get-MailUser -ResultSize unlimited | Where-Object { $_.RecipientTypeDetails -ne "GuestMailUser" } | Sort-Object -Property UserPrincipalName
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

            $MailUser = $MailUser[$StartNumber..$EndNumber]

        }

        if ($ConfirmCount -eq 'n' -or $ConfirmCount -eq 'y') {
            $i = 1
            $Total = $MailUser.count

            ForEach ($CurMailUser in $MailUser) {
                if ($CurMailUser.PrimarySmtpAddress -like $RoutingDomain) {
                    $MailUserProxy = $CurMailUser.EmailAddresses | Where-Object { $_ -notlike $WildCardDomain -and $_ -like "smtp*" }
                    Write-HostLog -Message "`tDomains Found for user: $($MailUserProxy.count)" -Status "Success"
                    ForEach ($CurMailProxy in $MailUserProxy) {
                        try {
                            Set-MailUser -Identity $CurMailUser.PrimarySmtpAddress -EmailAddresses @{Remove = $CurMailProxy } -ErrorAction Stop
                            Write-HostProgress -Message "`t`tRemoving $CurMailProxy" -Status "Success" -Total $Total -Count $i
                        }
                        catch {
                            Write-HostProgress -Message "`t`tRemoving $CurMailProxy" -Status "Failed" -Total $Total -Count $i
                            $_.Exception.Message
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
#>
    if ($FlipDLPrimary) {
        $DistributionGroup = Get-DistributionGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
        Write-HostLog -Message "`nTotal Distribution Groups Found: $($DistributionGroup.count)" -Status "Success"

        $i = 1
        $Total = $DistributionGroup.Count

        ForEach ($CurDistributionGroup in $DistributionGroup) {
            if ($CurDistributionGroup.PrimarySmtpAddress -notlike $RoutingDomain) {
                $NewDLPrimary = '{0}@{1}' -f $CurDistributionGroup.PrimarySmtpAddress.Split("@")[0], $DomainSuffix
                try {
                    Set-DistributionGroup -Identity $($CurDistributionGroup.PrimarySmtpAddress) -PrimarySmtpAddress $NewDLPrimary -ErrorAction Stop
                    Write-HostProgress -Message "$($CurDistributionGroup.PrimarySmtpAddress)" -Status "Success" -Total $Total -Count $i
                }
                catch {
                    Write-HostProgress -Message "$($CurDistributionGroup.PrimarySmtpAddress)" -Status "Failed" -Total $Total -Count $i
                    $_.Exception.Message
                }
                Start-Sleep -Seconds 2
            }
            else {
                Write-HostLog -Message "No Primary Flip required: $($CurDistributionGroup.PrimarySmtpAddress)" -Status "Neutral"
            }
            $i++
        }
        Write-HostLog -Message "`nFlipping Primary for Distribution Groups is Complete`n"
    }

    if ($FlipUGPrimary) {
        $UnifiedGroup = Get-UnifiedGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
        Write-HostLog -Message "`nTotal Office 365 Groups (Unified Groups) Found: $($UnifiedGroup.count)" -Status "Success"

        $i = 1
        $Total = $UnifiedGroup.Count

        ForEach ($CurUnifiedGroup in $UnifiedGroup) {
            if ($CurUnifiedGroup.PrimarySmtpAddress -notlike $RoutingDomain) {
                $NewUGPrimary = '{0}@{1}' -f $CurUnifiedGroup.PrimarySmtpAddress.Split("@")[0], $DomainSuffix

                try {
                    Set-UnifiedGroup -Identity $($CurUnifiedGroup.PrimarySmtpAddress) -PrimarySmtpAddress $NewUGPrimary -ErrorAction Stop
                    Write-HostProgress -Message "$($CurUnifiedGroup.PrimarySmtpAddress)" -Status "Success" -Total $Total -Count $i
                }
                catch {
                    Write-HostProgress -Message "$($CurUnifiedGroup.PrimarySmtpAddress)" -Status "Failed" -Total $Total -Count $i
                    $_.Exception.Message
                }
                Start-Sleep -Seconds 2
            }
            else {
                Write-HostLog -Message "No Primary Flip required: $($CurUnifiedGroup.PrimarySmtpAddress)" -Status "Neutral"
            }
            $i++
        }
        Write-HostLog -Message "`nFlipping Primary for O365 Groups is Complete`n" -Status "Success"
    }
    <#
    if ($RemoveUGProxy) {
        $UnifiedGroup = Get-UnifiedGroup -ResultSize unlimited | Sort-Object -Property PrimarySmtpAddress
        Write-HostLog -Message "`nTotal O365 Groups Found: $($UnifiedGroup.count)" -Status "Success"

        $i = 1
        $Total = $UnifiedGroup.Count

        ForEach ($CurUnifiedGroup in $UnifiedGroup) {
            if ($CurUnifiedGroup.PrimarySmtpAddress -like $RoutingDomain) {
                $ProxyUGAddress = $CurUnifiedGroup.EmailAddresses | Where-Object { $_ -notlike $WildCardDomain -and $_ -like "smtp*" }
                Write-HostLog -Message "`tDomains Found for O365 Group $($CurUnifiedGroup.PrimarySmtpAddress): $($ProxyUGAddress.count)" -Status "Success"

                ForEach ($CurProxyUGAddress in $ProxyUGAddress) {
                    try {
                        Set-UnifiedGroup -Identity $CurUnifiedGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $CurProxyUGAddress } -ErrorAction Stop
                        Write-HostProgress -Message "t`tRemoving $CurProxyUGAddress" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostProgress -Message "t`tRemoving $CurProxyUGAddress" -Status "Failed" -Total $Total -Count $i
                        $_.Exception.Message
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

        $i = 1
        $Total = $DistributionGroup.Count

        ForEach ($CurDistributionGroup in $DistributionGroup) {
            if ($CurDistributionGroup.PrimarySmtpAddress -like $RoutingDomain) {
                $ProxyDLAddress = $CurDistributionGroup.EmailAddresses | Where-Object { $_ -notlike $WildCardDomain -and $_ -like "smtp*" }
                Write-HostLog -Message "`tDomains Found for DL $($CurDistributionGroup.PrimarySmtpAddress): $($ProxyDLAddress.count)" -Status "Success"

                ForEach ($CurProxyDLAddress in $ProxyDLAddress) {
                    try {
                        Set-DistributionGroup -Identity $CurDistributionGroup.PrimarySmtpAddress -EmailAddresses @{Remove = $CurProxyDLAddress } -ErrorAction Stop
                        Write-HostProgress -Message "t`tRemoving $CurProxyDLAddress" -Status "Success" -Total $Total -Count $i
                    }
                    catch {
                        Write-HostProgress -Message "t`tRemoving $CurProxyDLAddress" -Status "Failed" -Total $Total -Count $i
                        $_.Exception.Message
                    }
                    Start-Sleep -Seconds 2
                }
            }
            $i++
        }
        Write-HostLog -Message "`nProxies removal task from Distribution Groups is Complete`n" -Status "Success"
    }
#>
}

<#
$mailboxList = Get-EXOMailbox -ResultSize unlimited

foreach ($Mailbox in $mailboxList) {
    Write-Host "Mailbox: $($Mailbox.DisplayName)"
    foreach ($Email in $Mailbox.EmailAddresses | Where-Object { $_ -notmatch 'x500' -and $_ -match 'contoso.com' }) {
        try {
            Write-Host "Attemptingx: $Email" -ForegroundColor White
            Set-Mailbox -identity ($Mailbox.ExchangeObjectId).ToString() -EmailAddresses @{remove = '$Email' } -ErrorAction Stop
            Write-Host "Removing Email Succeeded: $Email" -ForegroundColor Green
        }
        catch {
            Write-Host "Removing Email Failed: $Email" -ForegroundColor Red
            $_.Exception.Message
        }
    }
}
#>
