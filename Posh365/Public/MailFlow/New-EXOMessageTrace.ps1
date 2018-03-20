Function New-EXOMessageTrace {
    <#
    .SYNOPSIS
    Search message trace logs in Exchange Online "by day" start and end times

    .DESCRIPTION
    Search message trace logs in Exchange Online by day start and end times

    Many thanks to Matt Marchese for this function.
    The original function was written by Matt Marchese, https://github.com/General-Gouda
    
    .PARAMETER SenderAddress
    Senders Email Address
    
    .PARAMETER RecipientAddress
    Recipients Email Address
    
    .PARAMETER StartDate
    Number of days from today to start the search.
    
    .PARAMETER EndDate
    Number of days from today to end the search. Now (the number "0") is the default.
    
    .PARAMETER FromIP
    The IP address from which the email originated.
    
    .PARAMETER ToIP
    The IP address to which the email was destined.
    
    .PARAMETER Status
    The Status parameter filters the results by the delivery status of the message. Valid values for this parameter are:

    None: The message has no delivery status because it was rejected or redirected to a different recipient.
    Failed: Message delivery was attempted and it failed or the message was filtered as spam or malware, or by transport rules.
    Pending: Message delivery is underway or was deferred and is being retried.
    Delivered: The message was delivered to its destination.
    Expanded: There was no message delivery because the message was addressed to a distribution group, and the membership of the distribution was expanded.
    
    .PARAMETER FilePath
    To Export to file, the location of the file.
    
    .EXAMPLE
    New-EXOMessageTrace -SenderAddress "User@domain.com" -RecipientAddress "recipient@domain.com" -StartDate 3 -EndDate 2 -FromIP "xx.xx.xx.xx" -FilePath "C:\Output\FileName.csv"

    #>  
    [CmdletBinding()]
    param
    (
        [string]$SenderAddress,
        [string]$RecipientAddress,
        [int]$StartDate,
        [int]$EndDate,
        [string]$FromIP,
        [string]$ToIP,
        [string]$Status,
        [string]$FilePath
    )

    class MessageTraceResults {
        [string]$Received
        [string]$SenderAddress
        [string]$RecipientAddress
        [string]$Subject
        [string]$Status
    }

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    if ($StartDate) {
        [DateTime]$StartDate = ((Get-Date).AddDays( - $StartDate))
        $StartDate = $StartDate.ToUniversalTime()
    }

    if ($StartDate) {
        [DateTime]$EndDate = ((Get-Date).AddDays( - $EndDate))
        $EndDate = $EndDate.ToUniversalTime()
    }

    $cmdletParams = (Get-Command $PSCmdlet.MyInvocation.InvocationName).Parameters.Keys

    $params = @{}

    foreach ($cmdletParam in $cmdletParams) {
        if ($cmdletParam -notmatch "FilePath|Debug|Verbose|ErrorAction|WarningAction|InformationAction|ErrorVariable|WarningVariable|InformationVariable|OutVariable|OutBuffer|PipelineVariable") {
            if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $cmdletParam).Value) -ne $true) {
                $params.Add($cmdletParam, (Get-Variable -Name $cmdletParam).Value)
            }
        }
    }

    $counter = 1
    $continue = $false
    $allMessageTraceResults = New-Object System.Collections.ArrayList

    do {
        Write-Verbose "Checking message trace results on page $counter."
        try {
            $messageTrace = Get-MessageTrace @params -Page $counter

            if ($messageTrace) {
                $messageTrace | ForEach-Object {
                    $messageTraceResults = New-Object MessageTraceResults
                    $messageTraceResults.Received = $_.Received
                    $messageTraceResults.SenderAddress = $_.SenderAddress
                    $messageTraceResults.RecipientAddress = $_.RecipientAddress
                    $messageTraceResults.Subject = $_.Subject
                    $messageTraceResults.Status = $_.Status
                    [void]$allMessageTraceResults.Add($messageTraceResults)
                }

                $counter++
                Start-Sleep -Seconds 2
            }
            else {
                Write-Verbose "`tNo results found on page $counter."
                $continue = $true
            }
        }
        catch {
            Write-Verbose "`tException gathering message trace data on page $counter. Trying again in 30 seconds."
            Start-Sleep -Seconds 30
        }
    } while ($continue -eq $false)

    if ($allMessageTraceResults.count -gt 0) {
        Write-Verbose "`n$($allMessageTraceResults.count) results returned."
        $allMessageTraceResults

        if ($FilePath) {
            Write-Verbose "Writing results to $FilePath"
            $allMessageTraceResults | Export-Csv $FilePath -NoTypeInformation
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}