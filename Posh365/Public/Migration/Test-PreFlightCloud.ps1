function Test-PreFlightCloud {
    param (
        [Parameter(Mandatory = $true)]
        [string] $CsvFileName,

        [Parameter(Mandatory = $true)]
        [string] $Tenant
    )

    if ($Tenant -match 'onmicrosoft') {
        $Tenant = $Tenant.Split(".")[0]
    }

    $ImportList = Import-Csv $CsvFileName
    $AcceptedDomains = Get-AcceptedDomain

    foreach ($Import in $ImportList) {
        $WhyFailed = ""
        $UPN = $Import.Check
        $Import.Check = $UPN
        $Import.BatchName = $Import.BatchName

        if ($Import.PreFlightComplete -ne "TRUE") {

            try {
                $MailUser = Get-MailUser $UPN -ErrorAction Stop
                write-host $MailUser
                $Import.IsSynchronized = "TRUE"
                $Import.DisplayName = $MailUser.DisplayName
                $Import.PrimarySMTP = $MailUser.WindowsEmailAddress
                $Import.CloudUPN = $MailUser.UserPrincipalName

                if ($Import.CloudUPN -eq $Import.UserPrincipalName ) {
                    $Import.UPNsMatch = "TRUE"
                }
                else {
                    $Import.UPNsMatch = "FALSE"
                }

                if ($MailUser.WindowsEmailAddress -eq $MailUser.MicrosoftOnlineServicesID) {
                    $Import.UpnSmtpMatch = "TRUE"
                }
                else {
                    $Import.UpnSmtpMatch = "FALSE"
                }

                try {
                    $IsExchangeLicensed = (Get-MsolUser -UserPrincipalName $UPN -ErrorAction stop).Licenses.ServiceStatus |
                    Where-Object { $_.Serviceplan.Servicename -like "Exchange*" } | ForEach-Object {
                        Where-Object $_.ProvisioningStatus -ne "Disabled"
                    }
                }
                catch {
                    $WhyFailedMSOL = (($_.Exception.Message) -replace ",", ";") -replace "\n", "|**|"
                    $WhyFailed += $WhyFailedMSOL
                }

                if ($IsExchangeLicensed) {
                    $Import.IsLicensed = "TRUE"
                }
                else {
                    $Import.IsLicensed = "FALSE"
                }

                $ErrorAddress = $null
                $BadAddresses = $MailUser.EmailAddresses |
                Where-Object { $_ -like 'smtp:*' } |
                ForEach-Object { $_ -replace '^.+@' } |
                Where-Object { $_ -notin $AcceptedDomains.DomainName }

                if ($BadAddresses) {
                    $Import.GoodAddresses = "FALSE"
                    $ErrorAddress = $BadAddresses -join (';')
                    $WhyFailed += $ErrorAddress
                }
                else {
                    $Import.GoodAddresses = "TRUE"
                }

                $FoundRouting = ""
                $FoundRouting = $MailUser.EmailAddresses |
                Where-Object { $_ -like 'smtp:*' } |
                ForEach-Object { $_ -replace '^.+@' } |
                Where-Object { $_ -eq ($tenant + ".mail.onmicrosoft.com") }

                if ($FoundRouting) {
                    $Import.RoutingAddress = "TRUE"
                }
                else {
                    $Import.RoutingAddress = "FALSE"
                }

                if ($Import.MailboxType -eq "Generic") {
                    if ($Import.RecipientType -eq "SharedMailbox") {
                        $Import.isLicensed = "Shared Mailbox"
                    }
                    else {
                        $Import.isLicensed = "Not Shared Mailbox"
                    }
                }
            }
            catch {
                $WhyFailed = (($_.Exception.Message) -replace ",", ";") -replace "\n", "|**|"
                Write-Verbose "Error executing: Get-MailUser $UPN"
                Write-Verbose $WhyFailed
                $Import.ErrorCloud = $WhyFailed
                $Import.IsSynchronized = "FALSE"
                $Import.DisplayName = "NOT FOUND"
                $Import.PrimarySMTP = "NOT FOUND"
                $Import.CloudUPN = "NOT FOUND"
                if (Get-Mailbox $UPN -ErrorAction SilentlyContinue) {
                    $Import.PreFlightComplete = "Already Exists in O365"
                    $Import.IsSynchronized = "Already Exists in O365"
                    $Import.DisplayName = "Already Exists in O365"
                    $Import.PrimarySMTP = "Already Exists in O365"
                    $Import.CloudUPN = "Already Exists in O365"
                    $Import.RoutingAddress = "Already Exists in O365"
                    $Import.UpnSmtpMatch = "Already Exists in O365"
                    $Import.GoodAddresses = "Already Exists in O365"
                    $Import.UPNsMatch = "Already Exists in O365"
                    $Import.IsLicensed = "Already Exists in O365"
                }
            }

            if ($WhyFailed) {
                $Import.ErrorCloud = $WhyFailed
            }
            else {
                $Import.ErrorCloud = ""
            }
            if (
                $Import.DisplayName -ne "" -and
                $Import.PrimarySMTP -ne "" -and
                $Import.IsSynchronized -eq "TRUE" -and
                (
                    $Import.IsLicensed -eq "TRUE" -or
                    $Import.MailboxType -eq "Generic" -or
                    $Import.MailboxType -eq "Room"
                ) -and
                $Import.RoutingAddress -eq "TRUE" -and
                $Import.UpnSmtpMatch -eq "TRUE" -and
                $Import.GoodAddresses -eq "TRUE" -and
                $Import.UPNsMatch -eq "TRUE"
            ) {
                $Import.PreFlightComplete = "TRUE"
                Start-Sleep -Seconds 2
            }
        }
    }
    $ImportList | Export-Csv $CsvFileName -NoTypeInformation -Encoding UTF8
}
