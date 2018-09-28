Function New-MessageTrack {
    <#
    .SYNOPSIS
    Search message trace logs in Exchange Online by hour or partial hour start and end times
    If desired, one or more messages can be selected from the results for more detail

    .DESCRIPTION
    Search message trace logs in Exchange Online by hour or partial hour start and end times
    If desired, one or more messages can be selected from the results for more detail
    Just click OK once you have selected the message(s)

    Many thanks to Matt Marchese for the initial framework of this function
    
    .PARAMETER SenderAddress
    Senders Email Address
    
    .PARAMETER RecipientAddress
    Recipients Email Address

    .PARAMETER StartSearchHoursAgo
    Number of hours from today to start the search. Default is (.25) 15 minutes ago
    
    .PARAMETER EndSearchHoursAgo
    Number of hours from today to end the search. "Now" is the default, the number "0"
    
    .PARAMETER Subject
    Partial or full subject of message(s) of which are being searched

    .PARAMETER FromIP
    The IP address from which the email originated
    
    .PARAMETER ToIP
    The IP address to which the email was destined

    .PARAMETER Status
    The Status parameter filters the results by the delivery status of the message. Valid values for this parameter are:

    None: The message has no delivery status because it was rejected or redirected to a different recipient.
    Failed: Message delivery was attempted and it failed or the message was filtered as spam or malware, or by transport rules.
    Pending: Message delivery is underway or was deferred and is being retried.
    Delivered: The message was delivered to its destination.
    Expanded: There was no message delivery because the message was addressed to a distribution group, and the membership of the distribution was expanded.
    
    .EXAMPLE
    New-MessageTrack
        
    .EXAMPLE
    New-MessageTrack -StartSearchHoursAgo 10 -EndSearchHoursAgo 5 -Subject "arizona"

    This will find all messages with the word "arizona" somewhere in the subject, that were sent or received anywhere from 10 hours ago till 5 hours ago

    .EXAMPLE
    New-MessageTrack -StartSearchHoursAgo 10 -EndSearchHoursAgo 5 -Subject "Letter from the CEO"

    .EXAMPLE
    New-MessageTrack -SenderAddress "User@domain.com" -RecipientAddress "recipient@domain.com" -StartSearchHoursAgo 15 -FromIP "xx.xx.xx.xx"

    #>  
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string] $SenderAddress,

        [Parameter()]
        [string] $RecipientAddress,

        [Parameter()]
        [Double] $StartSearchHoursAgo = ".25",

        [Parameter()]
        [Double] $EndSearchHoursAgo = "0",

        [Parameter()]
        [string] $Subject,

        [Parameter()]
        [string] $MessageID,

        [Parameter()]
        [string] $FromIP,

        [Parameter()]
        [string] $ToIP,

        [Parameter()]
        [string] $Status
    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'

    if ($StartSearchHoursAgo) {
        [DateTime]$StartSearchHoursAgo = ((Get-Date).AddHours( - $StartSearchHoursAgo))
        $StartSearchHoursAgo = $StartSearchHoursAgo.ToUniversalTime()
    }

    if ($StartSearchHoursAgo) {
        [DateTime]$EndSearchHoursAgo = ((Get-Date).AddHours( - $EndSearchHoursAgo))
        $EndSearchHoursAgo = $EndSearchHoursAgo.ToUniversalTime()
    }

    $cmdletParams = (Get-Command $PSCmdlet.MyInvocation.InvocationName).Parameters.Keys

    $params = @{}
    $NotArray = 'StartSearchHoursAgo', 'EndSearchHoursAgo', 'Subject', 'Debug', 'Verbose', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
    foreach ($cmdletParam in $cmdletParams) {
        if ($cmdletParam -notin $NotArray) {
            if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $cmdletParam).Value) -ne $true) {
                $params.Add($cmdletParam, (Get-Variable -Name $cmdletParam).Value)
            }
        }
    }
    $params.Add('Start', $StartSearchHoursAgo)
    $params.Add('End', $EndSearchHoursAgo)
    $params.Add('MessageSubject', $Subject)

    $allMessageTrackResults = [System.Collections.Generic.List[PSObject]]::New()

    try {
        $messageTrack = Get-MessageTrackingLog @params
        if ($messageTrack) {
            $messageTrack | ForEach-Object {
                $messageTrackResults = [PSCustomObject]@{
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
                $allMessageTrackResults.Add($messageTrackResults)
            }
        }
        else {
            Write-Verbose "`tNo results found"
        }
    }
    catch {
        Write-Verbose "`tException gathering message trace data."
    }

    if ($allMessageTrackResults.count -gt 0) {
        Write-Verbose "`n$($allMessageTrackResults.count) results returned."

        $WantsDetailOnTheseMessages = $allMessageTrackResults | Out-GridView -PassThru -Title "Message Trace Results. Select one or more then click OK for detailed report."
        if ($WantsDetailOnTheseMessages) {
            Foreach ($Wants in $WantsDetailOnTheseMessages) {
                $Splat = @{
                    MessageTraceID   = $Wants.MessageTraceID
                    RecipientAddress = $Wants.RecipientAddress
                    MessageId        = $Wants.MessageId
                }
                $TraceDetail = Get-MessageTrackingReport @Splat
                $TraceDetail |
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