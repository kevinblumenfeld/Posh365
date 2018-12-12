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

    $Import = Import-Csv $CsvFileName
    $AcceptedDomains = Get-AcceptedDomain

    foreach ($CurImport in $Import) {
        $WhyFailed = ""
        $UPN = $CurImport.Check
        $CurImport.Check = $UPN
        $CurImport.BatchName = $CurImport.BatchName

        if ($CurImport.PreFlightComplete -ne "TRUE") {

            try {
                $MailUser = Get-MailUser $UPN -ErrorAction Stop
                write-host $MailUser
                $CurImport.IsSynchronized = "TRUE"
                $CurImport.DisplayName = $MailUser.DisplayName
                $CurImport.PrimarySMTP = $MailUser.WindowsEmailAddress
                $CurImport.CloudUPN = $MailUser.UserPrincipalName

                if ($CurImport.CloudUPN -eq $CurImport.UserPrincipalName ) {
                    $CurImport.UPNsMatch = "TRUE"
                }
                else {
                    $CurImport.UPNsMatch = "FALSE"
                }

                if ($MailUser.WindowsEmailAddress -eq $MailUser.MicrosoftOnlineServicesID) {
                    $CurImport.UpnSmtpMatch = "TRUE"
                }
                else {
                    $CurImport.UpnSmtpMatch = "FALSE"
                }

                try {
                    $IsExchangeLicensed = (Get-MsolUser -UserPrincipalName $UPN -ErrorAction stop).Licenses.ServiceStatus |
                        Where-Object {$_.Serviceplan.Servicename -like "Exchange*"} | ForEach-Object {
                        Where-Object $_.ProvisioningStatus -ne "Disabled"
                    }
                }
                catch {
                    $WhyFailedMSOL = (($_.Exception.Message) -replace ",", ";") -replace "\n", "|**|"
                    $WhyFailed += $WhyFailedMSOL
                }

                if ($IsExchangeLicensed) {
                    $CurImport.IsLicensed = "TRUE"
                }
                else {
                    $CurImport.IsLicensed = "FALSE"
                }

                $ErrorAddress = $null
                $BadAddresses = $MailUser.EmailAddresses |
                    Where-Object { $_ -like 'smtp:*' } |
                    ForEach-Object { $_ -replace '^.+@' } |
                    Where-Object { $_ -notin $AcceptedDomains.DomainName }

                if ($BadAddresses) {
                    $CurImport.GoodAddresses = "FALSE"
                    $ErrorAddress = $BadAddresses -join (';')
                    $WhyFailed += $ErrorAddress
                }
                else {
                    $CurImport.GoodAddresses = "TRUE"
                }

                $FoundRouting = ""
                $FoundRouting = $MailUser.EmailAddresses |
                    Where-Object { $_ -like 'smtp:*' } |
                    ForEach-Object { $_ -replace '^.+@' } |
                    Where-Object { $_ -eq ($tenant + ".mail.onmicrosoft.com") }

                if ($FoundRouting) {
                    $CurImport.RoutingAddress = "TRUE"
                }
                else {
                    $CurImport.RoutingAddress = "FALSE"
                }

                if ($CurImport.MailboxType -eq "Generic") {
                    if ($CurImport.RecipientType -eq "SharedMailbox") {
                        $CurImport.isLicensed = "Shared Mailbox"
                    }
                    else {
                        $CurImport.isLicensed = "Not Shared Mailbox"
                    }
                }
            }
            catch {
                $WhyFailed = (($_.Exception.Message) -replace ",", ";") -replace "\n", "|**|"
                Write-Verbose "Error executing: Get-MailUser $UPN"
                Write-Verbose $WhyFailed
                $CurImport.ErrorCloud = $WhyFailed
                $CurImport.IsSynchronized = "FALSE"
                $CurImport.DisplayName = "NOT FOUND"
                $CurImport.PrimarySMTP = "NOT FOUND"
                $CurImport.CloudUPN = "NOT FOUND"
                if (Get-Mailbox $UPN -ErrorAction SilentlyContinue) {
                    $CurImport.IsSynchronized = "Already Exists in O365"
                    $CurImport.PreFlightComplete = "Already Exists in O365"
                    $CurImport.IsSynchronized = "Already Exists in O365"
                    $CurImport.DisplayName = "Already Exists in O365"
                    $CurImport.PrimarySMTP = "Already Exists in O365"
                    $CurImport.CloudUPN = "Already Exists in O365"
                    $CurImport.RoutingAddress = "Already Exists in O365"
                    $CurImport.UpnSmtpMatch = "Already Exists in O365"
                    $CurImport.GoodAddresses = "Already Exists in O365"
                    $CurImport.UPNsMatch = "Already Exists in O365"
                    $CurImport.IsLicensed = "Already Exists in O365"
                }
            }

            if ($WhyFailed) {
                $CurImport.ErrorCloud = $WhyFailed
            }
            else {
                $CurImport.ErrorCloud = ""
            }
            if (
                $CurImport.DisplayName -ne "" -and
                $CurImport.PrimarySMTP -ne "" -and
                $CurImport.IsSynchronized -eq "TRUE" -and
                (
                    $CurImport.IsLicensed -eq "TRUE" -or
                    $CurImport.MailboxType -eq "Generic" -or
                    $CurImport.MailboxType -eq "Room"
                ) -and
                $CurImport.RoutingAddress -eq "TRUE" -and
                $CurImport.UpnSmtpMatch -eq "TRUE" -and
                $CurImport.GoodAddresses -eq "TRUE" -and
                $CurImport.UPNsMatch -eq "TRUE"
            ) {
                $CurImport.PreFlightComplete = "TRUE"
                Start-Sleep -Seconds 2
            }
        }
    }
    $Import | Export-Csv $CsvFileName -NoTypeInformation -Encoding UTF8
}
