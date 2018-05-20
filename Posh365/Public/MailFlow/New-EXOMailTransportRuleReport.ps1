Function New-EXOMailTransportRuleReport {
    <#
    .SYNOPSIS
    View the details of messages that matched the conditions defined by any transport rules

    .DESCRIPTION
    View the details of messages that matched the conditions defined by any transport rules
    
    .PARAMETER SenderAddress
    Senders Email Address
    
    .PARAMETER RecipientAddress
    Recipients Email Address
    
    .PARAMETER StartSearchMinutesAgo
    Number of minutes from today to start the search. Default is 400 Minutes.  The reports are delay by several hours.
    
    .PARAMETER EndSearchMinutesAgo
    Number of minutes from today to end the search. "Now" is the default, the number "0"
    
    .PARAMETER Subject
    Partial or full subject of message(s) of which are being searched
    
    .PARAMETER SpecifyActions
    Allows user to pick from a list of Action to include in the search
    
    .PARAMETER SpecifyTransportRules
    Allows user to pick from a list of Transport Rules to include in the search

    .PARAMETER SelectMessageForDetails
    Switch that allows for selection of one or more messages via Out-GridView.
    Resultingly, the MessageTraceDetails will be shown for each.
    The output is one Out-GridView per message selected.
    The title of the Out-Grid shows the original message details.
    
    .EXAMPLE
    New-EXOMailTransportRuleReport -StartSearchMinutesAgo 1500 -SpecifyActions -SpecifyTransportRules -SelectMessageForDetails -Subject "Letter from the CEO"

    .EXAMPLE
    New-EXOMailTransportRuleReport -StartSearchMinutesAgo 400 -SpecifyActions -SpecifyTransportRules -SelectMessageForDetails

    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string] $SenderAddress,

        [Parameter()]
        [string] $RecipientAddress,

        [Parameter()]
        [int] $StartSearchMinutesAgo = "400",

        [Parameter()]
        [int] $EndSearchMinutesAgo,

        [Parameter()]
        [string] $Subject,

        [Parameter()]
        [switch] $SpecifyActions,

        [Parameter()]
        [switch] $SpecifyTransportRules,

        [Parameter()]
        [switch] $SelectMessageForDetails
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
    $NotArray = 'SpecifyActions', 'SpecifyTransportRules', 'StartSearchMinutesAgo', 'EndSearchMinutesAgo', 'SelectMessageForDetails', 'Subject', 'FilePath', 'Debug', 'Verbose', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
    foreach ($cmdletParam in $cmdletParams) {
        if ($cmdletParam -notin $NotArray) {
            if ([string]::IsNullOrWhiteSpace((Get-Variable -Name $cmdletParam).Value) -ne $true) {
                $params.Add($cmdletParam, (Get-Variable -Name $cmdletParam).Value)
            }
        }
    }
    $params.Add('StartDate', $StartSearchMinutesAgo)
    $params.Add('EndDate', $EndSearchMinutesAgo)

    if ($SpecifyActions) {
        $Actions = (Get-MailFilterListReport -SelectionTarget Actions).Value | Out-GridView -PassThru -Title "Pick from the list of Actions by holding the Control Key and select one or more.  Then click OK."
        $params.Add('Action', $Actions)
    }

    if ($SpecifyTransportRules) {
        $TransportRules = (Get-MailFilterListReport -SelectionTarget TransportRule).Value | Out-GridView -PassThru  -Title "Pick from the list of Transport Rules by holding the Control Key and select one or more.  Then click OK."
        $params.Add('TransportRule', $TransportRules)
    }
    
    $counter = 1
    $continue = $true
    $allMessageTraceResults = [System.Collections.Generic.List[PSObject]]::New()

    do {
        Write-Verbose "Checking message trace results on page $counter."
        try {
            if (-not $Subject) {
                $messageTrace = Get-MailDetailTransportRuleReport @params -Page $counter
            }
            else {
                $messageTrace = Get-MailDetailTransportRuleReport @params -Page $counter | Where-Object {$_.Subject -match "$Subject"}
            }

            if ($messageTrace) {
                $messageTrace | ForEach-Object {
                    $messageTraceResults = [PSCustomObject]@{
                        Date             = $_.Date
                        TransportRule    = $_.TransportRule
                        SenderAddress    = $_.SenderAddress
                        RecipientAddress = $_.RecipientAddress
                        Subject          = $_.Subject
                        Direction        = $_.Direction
                        EventType        = $_.EventType
                        Action           = $_.Action
                        MessageSize      = $_.MessageSize
                        MessageTraceId   = $_.MessageTraceId
                        MessageId        = $_.MessageId
                        Domain           = $_.Domain
                    }
                    $allMessageTraceResults.Add($messageTraceResults)
                }
                $counter++
                Start-Sleep -Seconds 2
            }
            else {
                Write-Verbose "`tNo results found on page $counter."
                $continue = $false
            }
        }
        catch {
            Write-Verbose "`tException gathering message trace data on page $counter. Trying again in 30 seconds."
            Start-Sleep -Seconds 30
        }
    } while ($continue)

    if ($allMessageTraceResults.count -gt 0) {
        Write-Verbose "`n$($allMessageTraceResults.count) results returned."
        if (-not $SelectMessageForDetails) {
            $allMessageTraceResults | Out-GridView -Title "Mail Detail Transport Rule Report"
        }
        else {
            $WantsDetailOnTheseMessages = $allMessageTraceResults | Out-GridView -PassThru
            if ($WantsDetailOnTheseMessages) {
                Foreach ($Wants in $WantsDetailOnTheseMessages) {
                    $Splat = @{
                        MessageTraceID   = $Wants.MessageTraceID
                        SenderAddress    = $Wants.SenderAddress
                        RecipientAddress = $Wants.RecipientAddress
                        MessageId        = $Wants.MessageId
                    }
                    Get-MessageTraceDetail @Splat |
                        Select-Object Date, Event, Action, Detail, Data, MessageTraceID, MessageID | 
                        Out-GridView -Title "DATE: $($Wants.Date) TRANSPORT RULE: $($Wants.TransportRule) FROM: $($Wants.SenderAddress) TO: $($Wants.RecipientAddress) TRACEID: $($Wants.MessageTraceId)" 
                }
            }
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}