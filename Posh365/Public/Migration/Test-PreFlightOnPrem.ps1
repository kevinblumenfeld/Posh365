function Test-PreFlightOnPrem {
    param (
        [Parameter(Mandatory = $true)]
        [String] $CsvFileName,

        [Parameter(Mandatory = $true)]
        [string] $LogPath,

        [Parameter(Mandatory = $true)]
        [string] $Tenant
    )

    if ($Tenant -match 'onmicrosoft') {
        $Tenant = $Tenant.Split(".")[0]
    }

    $Import = Import-Csv $CsvFileName
    $LogFile = (Join-Path $LogPath ($(get-date -Format yyyy-MM-dd_HH-mm-ss) + "`_$($Tenant)_PreFlight_On_Premises.csv"))
    
    Add-Content -Path $LogFile -Value ("Object", "ErrorObject", "ErrorMessage" -join ',')

    foreach ($CurImport in $Import) {
        $UPN = ""
        $UPN = $CurImport.Check
        $CurImport.Check = $UPN

        if ($CurImport.PreFlightComplete -ne "TRUE") {

            try {
                $Mailbox = ""
                $Mailbox = Get-Mailbox -Identity $UPN -ErrorAction Stop

                $CurImport.RecipientType = $Mailbox.RecipientTypeDetails
                $CurImport.SamAccountName = $Mailbox.SamAccountName
            }
            catch {
                $WhyFailed = (((($_.Exception.Message).replace(',', ';')) -split '\.')[0, 1]) -join ';'

                Add-Content -Path $LogFile -Value ($UPN, $UPN, $WhyFailed -join ',')

                Write-Verbose "Error executing: Get-Mailbox $UPN"
                Write-Verbose $WhyFailed
            }
            if ($Mailbox.ForwardingAddress -ne $null) {
                $Forward = Get-Recipient $Mailbox.ForwardingAddress -ErrorAction 

                $CurImport.ForwardingAddress = $Forward.PrimarySmtpAddress
            }
            else {
                $CurImport.ForwardingAddress = "Not Found"
            }
            try {
                $CasMailbox = Get-CASMailbox -Identity $UPN -ErrorAction Stop 
                if ($CasMailbox.ActiveSyncEnabled -eq $true) {
                    $CurImport.ActiveSyncEnabled = "TRUE"
                }
                else {
                    $CurImport.ActiveSyncEnabled = "FALSE"
                }
            }
            catch {
                $WhyFailed = (((($_.Exception.Message).replace(',', ';')) -split '\.')[0, 1]) -join ';'

                Add-Content -Path $LogFile -Value ($UPN, $UPN, $WhyFailed -join ',')

                Write-Verbose "Error executing: Get-CASMailbox $UPN"
                Write-Verbose $WhyFailed
            }
        }
        $Import | Export-Csv $CsvFileName -NoTypeInformation -Encoding UTF8
    }
}