function Test-PreFlightOnPrem {
    <#
    .SYNOPSIS
    Prior to migrating mailboxes to Exchange Online this outputs the results of a preflight check.
    This overwrites the original file

    .DESCRIPTION
    Prior to migrating mailboxes to Exchange Online this outputs the results of a preflight check.
    This overwrites the original file

    .PARAMETER CsvFileName
    This is the path to the original CSV file
    The mandatory headers in the CSV are:
    UserPrincipalName and Batch (The UPN and Batch of those to be checked - prior to migration)

    .PARAMETER Tenant
    For example contoso or contoso.onmicrosoft.com would both work.

    .EXAMPLE
    Test-PreFlightOnPrem -Tenant Contoso -CSVFileName .\UsersAndBatchNames.csv

    .NOTES
    This will overwrite the original file
    #>

    param (
        [Parameter(Mandatory = $true)]
        [String] $CsvFileName,

        [Parameter(Mandatory = $true)]
        [string] $Tenant
    )

    if ($Tenant -match 'onmicrosoft') {
        $Tenant = $Tenant.Split(".")[0]
    }

    $ImportList = Import-Csv $CsvFileName

    foreach ($Import in $ImportList) {
        Write-Verbose "Testing:`t$($Import.UserPrincipalName)"

        $UPN = $Import.UserPrincipalName
        $Import.UserPrincipalName = $UPN
        $Import.Batch = $Import.Batch

        if ($Import.PreFlightComplete -ne "TRUE") {

            try {
                $Mailbox = Get-Mailbox -Identity $UPN -ErrorAction Stop

                $Import.RecipientType = $Mailbox.RecipientTypeDetails
                $Import.SamAccountName = $Mailbox.SamAccountName
                $Import.ForwardingSmtpAddress = $Mailbox.ForwardingSmtpAddress
                $Import.DeliverToMailboxAndForward = $Mailbox.DeliverToMailboxAndForward
                $Import.UserPrincipalName = $Mailbox.UserPrincipalName
                $Import.PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress.Address
                $Import.UpnMatchesSmtp = ($Mailbox.PrimarySmtpAddress.Address -eq $Mailbox.UserPrincipalName)
                if ($Routing = $Mailbox.EmailAddresses.addressstring -match "$tenant.mail.onmicrosoft.com") {
                    $Import.RoutingAddress = $Routing -join '|'
                }
                else {
                    $Import.RoutingAddress = "ROUTING_MISSING"
                }

                $WhyFailed = "SUCCESS"
            }
            catch {
                $WhyFailed = (($_.Exception.Message) -replace ",", ";") -replace "\n", "|**|"

                Write-Verbose "Error executing: Get-Mailbox $UPN"
                Write-Verbose $WhyFailed
                $Import.ErrorOnPrem = $WhyFailed

                continue
            }
            if ($null -ne $Mailbox.ForwardingAddress) {
                $Forward = Get-Recipient $Mailbox.ForwardingAddress
                $Import.ForwardingAddress = $Forward.PrimarySmtpAddress.Address
            }
            else {
                $Import.ForwardingAddress = "Not Found"
            }
        }
        $ImportList | Export-Csv $CsvFileName -NoTypeInformation -Encoding UTF8
    }
}
