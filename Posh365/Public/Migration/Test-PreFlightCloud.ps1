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
        $UPN = ""
        $UPN = $CurImport.Check
        $CurImport.Check = $UPN

        if ($CurImport.PreFlightComplete -ne "TRUE") {

            try {
                $MailUser = ""
                $MailUser = Get-MailUser $UPN -ErrorAction Stop
            }
            catch {
                $WhyFailed = (($_.Exception.Message) -replace ",",";") -replace "\n","|**|"
                Write-Verbose "Error executing: Get-MailUser $UPN"
                Write-Verbose $WhyFailed
                continue
            }

            if ($MailUser) {
                $CurImport.IsSynchronized = "TRUE"
                $CurImport.DisplayName = $MailUser.DisplayName
                $CurImport.PrimarySMTP = $MailUser.WindowsEmailAddress

                if ($MailUser.WindowsEmailAddress -eq $MailUser.MicrosoftOnlineServicesID) {
                    $CurImport.UpnSmtpMatch = "TRUE"  
                }
                else {
                    $CurImport.UpnSmtpMatch = "FALSE"
                }

                $IsExchangeLicensed = (Get-MsolUser -UserPrincipalName $UPN).Licenses.ServiceStatus | 
                    Where-Object {$_.Serviceplan.Servicename -like "Exchange*"} | ForEach-Object {
                    $_ | Where-Object $_.ProvisioningStatus -ne "Disabled"
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
            else {
                if (Get-Mailbox $UPN -ErrorAction SilentlyContinue) {
                    $CurImport.IsSynchronized = "Already Exists in O365"
                    $CurImport.PreFlightComplete = "Already Exists in O365"
                }
                else {
                    $CurImport.IsSynchronized = "Not a 365 Mailbox"
                }
            }
            if ($WhyFailed) {
                $CurImport.ErrorCloud = $WhyFailed
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
                $CurImport.GoodAddresses -eq "TRUE"
            ) {
                $CurImport.PreFlightComplete = "TRUE"
                Start-Sleep -Seconds 2
            }
        }        
    }
    $Import | Export-Csv $CsvFileName -NoTypeInformation -Encoding UTF8
}
