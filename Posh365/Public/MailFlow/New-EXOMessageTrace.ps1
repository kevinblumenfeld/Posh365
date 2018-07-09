Function New-EXOMessageTrace {
    <#
    .SYNOPSIS
    Search message trace logs in Exchange Online by minute start and end times

    .DESCRIPTION
    Search message trace logs in Exchange Online by minute start and end times

    Many thanks to Matt Marchese for this function.
    The original function was written by Matt Marchese, https://github.com/General-Gouda
    
    .PARAMETER SenderAddress
    Senders Email Address
    
    .PARAMETER RecipientAddress
    Recipients Email Address

    .PARAMETER StartSearchMinutesAgo
    Number of minutes from today to start the search. Default is 10 Minutes
    
    .PARAMETER EndSearchMinutesAgo
    Number of minutes from today to end the search. "Now" is the default, the number "0"
    
    .PARAMETER Subject
    Partial or full subject of message(s) of which are being searched
    
    .PARAMETER SelectMessageForDetails
    Switch that allows for selection of one or more messages via Out-GridView.
    Resultingly, the MessageTraceDetails will be shown for each.
    The output is one Out-GridView per message selected.
    The title of the Out-Grid shows the original message details.
    
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
    
    .EXAMPLE
    New-EXOMessageTrace -StartSearchMinutesAgo 10 -EndSearchMinutesAgo 5 -Subject "Letter from the CEO" -SelectMessageForDetails

    .EXAMPLE
    New-EXOMessageTrace -SenderAddress "User@domain.com" -RecipientAddress "recipient@domain.com" -StartSearchMinutesAgo 15 -FromIP "xx.xx.xx.xx"

    #>  
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string] $SenderAddress,

        [Parameter()]
        [string] $RecipientAddress,

        [Parameter()]
        [int] $StartSearchMinutesAgo = "10",

        [Parameter()]
        [int] $EndSearchMinutesAgo,

        [Parameter()]
        [string] $Subject,

        [Parameter()]
        [string] $FromIP,

        [Parameter()]
        [string] $ToIP,

        [Parameter()]
        [string] $Status
    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    if ($StartSearchMinutesAgo) {
        [DateTime]$StartSearchMinutesAgo = ((Get-Date).AddMinutes( - $StartSearchMinutesAgo))
        $StartSearchMinutesAgo = $StartSearchMinutesAgo.ToUniversalTime()
    }

    if ($StartSearchMinutesAgo) {
        [DateTime]$EndSearchMinutesAgo = ((Get-Date).AddMinutes( - $EndSearchMinutesAgo))
        $EndSearchMinutesAgo = $EndSearchMinutesAgo.ToUniversalTime()
    }

    $cmdletParams = (Get-Command $PSCmdlet.MyInvocation.InvocationName).Parameters.Keys

    $params = @{}
    $NotArray = 'StartSearchMinutesAgo', 'EndSearchMinutesAgo', 'Subject', 'Debug', 'Verbose', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
    foreach ($cmdletParam in $cmdletParams) {
        if ($cmdletParam -notin $NotArray) {
            if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $cmdletParam).Value) -ne $true) {
                $params.Add($cmdletParam, (Get-Variable -Name $cmdletParam).Value)
            }
        }
    }
    $params.Add('StartDate', $StartSearchMinutesAgo)
    $params.Add('EndDate', $EndSearchMinutesAgo)


    $counter = 1
    $continue = $false
    $allMessageTraceResults = [System.Collections.Generic.List[PSObject]]::New()

    do {
        Write-Verbose "Checking message trace results on page $counter."
        try {
            if (-not $Subject) {
                $messageTrace = Get-MessageTrace @params -Page $counter
            }
            else {
                $messageTrace = Get-MessageTrace @params -Page $counter | Where-Object {$_.Subject -match "$Subject"}
            }

            if ($messageTrace) {
                $messageTrace | ForEach-Object {
                    $messageTraceResults = [PSCustomObject]@{
                        Received         = $_.Received
                        Status           = $_.Status
                        SenderAddress    = $_.SenderAddress
                        RecipientAddress = $_.RecipientAddress
                        Subject          = $_.Subject
                        FromIP           = $_.FromIP
                        ToIP             = $_.ToIP                                                
                        MessageTraceId   = $_.MessageTraceId
                        MessageId        = $_.MessageId
                    }
                    $allMessageTraceResults.Add($messageTraceResults)
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

        $WantsDetailOnTheseMessages = $allMessageTraceResults | Out-GridView -PassThru -Title "Message Trace Results. Select one or more then click OK for detailed report."
        if ($WantsDetailOnTheseMessages) {
            Foreach ($Wants in $WantsDetailOnTheseMessages) {
                $Splat = @{
                    MessageTraceID   = $Wants.MessageTraceID
                    RecipientAddress = $Wants.RecipientAddress
                    MessageId        = $Wants.MessageId
                }
                Get-MessageTraceDetail @Splat |
                    Select-Object Date, Event, Action, Detail, Data, MessageTraceID, MessageID | 
                    Out-GridView -Title "DATE: $($Wants.Received) STATUS: $($Wants.Status) FROM: $($Wants.SenderAddress) TO: $($Wants.RecipientAddress) TRACEID: $($Wants.MessageTraceId)" 
            }
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}