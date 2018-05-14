function Test-PreFlight {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $csvFileName,
        
        [Parameter(Mandatory = $true)]
        [string] $Tenant
    )

    Write-Host "`r`n"
    Write-Host "Importing CSV from: `"$csvFileName`"" -ErrorAction Stop
    $mailboxes = Import-Csv $csvFileName
    $i = 1
    $count = $mailboxes.count
		
    $AcceptedDomains = Get-AcceptedDomain

    foreach ($mailbox in $mailboxes) {
    	
        $percent = [int](($i / $Count) * 100)
        Write-Progress -Activity "Running PreChecks" -Status "Processing $upn ($i of $Count)" -PercentComplete $percent
            
        $upn = $mailbox.mailUser
            
        if ($mailbox.PreflightComplete -eq "FALSE") {

            Write-Host "`nBegining preflight checks for: " -NoNewline
            Write-Host " $upn `n" -ForegroundColor Yellow
	
            Write-Host "`tObject synchronized to Exchange Online (MailUser): " -NoNewLine
            $mailUser = Get-MailUser $upn -ErrorAction SilentlyContinue
            if ($mailUser) {
                Write-Host "TRUE" -ForegroundColor Green
                $mailbox.IsSynchronized = "TRUE"
	
                Write-Host "`tUpdating preflight metadata"
                $mailbox.DisplayName = $mailUser.DisplayName
                $mailbox.PrimarySMTP = $mailUser.WindowsEmailAddress
                $mailbox.UserPrincipalName = $mailUser.userprincipalname
	
                Write-Host "`tUPN matches Primary SMTP Address: " -NoNewLine
                if ([string]($mailUser.WindowsEmailAddress) -eq [string]($mailUser.MicrosoftOnlineServicesID)) {
                    $mailbox.UpnSmtpMatch = "TRUE"
                    Write-Host "TRUE" -ForegroundColor Green
                }
                else {
                    $mailbox.UpnSmtpMatch = "FALSE"
                    Write-Host "FALSE" -ForegroundColor Red
                }
	
                Write-Host "`tExchange Online licensed: " -NoNewLine
                $isExchangeLicensed = (Get-MsolUser -UserPrincipalName $upn).licenses.servicestatus | 
                    Where-Object {$_.serviceplan.servicename -like "Exchange*" } | 
                    ForEach-Object {$_ | Where-Object $_.ProvisioningStatus -ne "Disabled"}

                if ($isExchangeLicensed) {
                    Write-Host "TRUE" -ForegroundColor Green
                    $mailbox.IsLicensed = "TRUE"
                }
                else {
                    Write-Host "FALSE" -ForegroundColor Red
                    $mailbox.IsLicensed = "FALSE"
                }
	
                Write-Host "`tSMTP addresses with unverified domain: " -NoNewLine
                $errorAddress = $null
                $hasBadAddress = $mailUser.EmailAddresses |
                    Where-Object { $_ -like 'smtp:*' } |
                    ForEach-Object { $_ -replace '^.+@' } |
                    Where-Object { $_ -notin $acceptedDomains }
                if ($hasBadAddress) {
                    Write-Host "TRUE" -ForegroundColor Red
                    $mailbox.NoBadAddresses = "FALSE"
                    $errorAddress = $hasBadAddress -join ', '
                }
                else {
                    Write-Host "FALSE" -ForegroundColor Green
                    $mailbox.NoBadAddresses = "TRUE"
                }
	
                Write-Host "`tRouting Proxy Addresses: " -NoNewline
                $foundRouting = $null
                $foundRouting = $mailUser.EmailAddresses |
                    Where-Object { $_ -like 'smtp:*' } |
                    ForEach-Object { $_ -replace '^.+@' } |
                    Where-Object { $_ -eq ($tenant + ".mail.onmicrosoft.com") }
                if ($foundRouting) {
                    Write-Host "Found Routing Address" -ForegroundColor Green
                    $mailbox.RoutingAddress = "TRUE"
                }
                else {
                    Write-Host "Did not fing Routing Address" -ForegroundColor Red
                    $mailbox.RoutingAddress = "FALSE"
                }

                if ($mailbox.Mailboxtype -eq "Generic") {
                    Write-Host "`tGeneric Account Type: " -NoNewline
                    if ($mailbox.RecipientType -eq "SharedMailbox") {
                        Write-Host "SHARED MBX" -ForegroundColor Green
                        $mailbox.isLicensed = "Shared Mailbox"
                    }
                    else {
                        Write-Host "NOT SHARED MBX" -ForegroundColor Red
                        $mailbox.isLicensed = "Not Shared Mailbox"
                    }
                }
            }
	
            else {
                Write-Host "FALSE" -ForegroundColor Red
                Write-Host "`n`tUser already has an Office 365 Mailbox: " -NoNewline
                if (Get-Mailbox $upn -ErrorAction SilentlyContinue) {
                    Write-Host "TRUE" -ForegroundColor Green
                    $mailbox.IsSynchronized = "Already Exists in O365"
                    $mailbox.PreFlightComplete = "Already Exists in O365"
                }
                else {
                    Write-Host "FALSE" -ForegroundColor Red
                    $mailbox.IsSynchronized = "User Not Found"
                }
            }
	
            if ($mailbox.DisplayName -ne "" -and
                $mailbox.PrimarySMTP -ne "" -and
                $mailbox.IsSynchronized -eq "TRUE" -and
                ($mailbox.IsLicensed -eq "TRUE" -or
                    $mailbox.MailboxType -eq "Generic" -or
                    $mailbox.Mailboxtype -eq "Room") -and
                $mailbox.RoutingAddress -eq "TRUE" -and
                $mailbox.UpnSmtpMatch -eq "TRUE" -and
                $mailbox.NoBadAddresses -eq "TRUE") {
                Write-Host "`tPREFLIGHT COMPLETE!!`n" -ForegroundColor Green
                $mailbox.PreFlightComplete = "TRUE"
                Start-Sleep -Seconds 2
            }
        }
	
        else {
            Write-Host "PREFLIGHT ALREADY COMPLETE: SKIPPING CHECKS FOR $upn"
        }
        $i++
    }
    $mailboxes | Export-Csv $csvfile -NoTypeInformation -Encoding UTF8
}
