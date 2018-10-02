
Function New-MessageTrack {
    <#
    .SYNOPSIS
    On-Premises Exchange Message Tracking Log made easy!

    .DESCRIPTION
    Searches all Hub Transport and Mailbox Servers for messages. Once found, you can select one or more messages via Out-GridView to search by those MessageID's.  

    .PARAMETER Sender
    Parameter description

    .PARAMETER Recipients
    Parameter description

    .PARAMETER StartSearchHoursAgo
    Parameter description

    .PARAMETER EndSearchHoursAgo
    Parameter description

    .PARAMETER Subject
    Parameter description

    .PARAMETER MessageID
    Parameter description

    .PARAMETER ResultSize
    Parameter description

    .PARAMETER Status
    Parameter description

    .EXAMPLE
    New-MessageTrack -StartSearchHoursAgo 48 -EndSearchHoursAgo 24 -Recipients "joe@contoso.com" -Subject "Forklift incident"

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string] $Sender,

        [Parameter()]
        [string] $Recipients,

        [Parameter()]
        [Double] $StartSearchHoursAgo = ".25",

        [Parameter()]
        [Double] $EndSearchHoursAgo = "0",

        [Parameter()]
        [string] $Subject,

        [Parameter()]
        [string] $MessageID,

        [Parameter()]
        [string] $ResultSize = "Unlimited",

        [Parameter()]
        [string] $Status
    )
    $Servers = Get-TransportServer -WarningAction SilentlyContinue 
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
    $NotArray = 'StartSearchHoursAgo', 'EndSearchHoursAgo', 'Subject', 'ResultSize', 'Debug', 'Verbose', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
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
        $messageTrack = $Servers | Get-MessageTrackingLog @params -ResultSize $ResultSize
        if ($messageTrack) {
            $messageTrack | ForEach-Object {
                $messageTrackResults = [PSCustomObject]@{
                    Time             = $_.TimeStamp
                    Directionality   = $_.Directionality
                    EventID          = $_.EventID
                    Sender           = $_.Sender
                    Recipients       = $_.Recipients
                    Subject          = $_.MessageSubject
                    Connector        = $_.ConnectorID
                    SourceContext    = $_.SourceContext
                    EventData        = $_.EventData
                    ServerHostName   = $_.ServerHostName
                    ServerIP         = $_.ServerIP
                    ClientIP         = $_.ClientIP
                    OriginalClientIP = $_.OriginalClientIP
                    ClientHostName   = $_.ClientHostName
                    TotalBytes       = $_.TotalBytes                                      
                    MessageId        = $_.MessageId
                }
                $allMessageTrackResults.Add($messageTrackResults)
            }        
            else {
                Write-Verbose "`tNo results found"
            }
        }
    }
    catch {
        Write-Verbose "`tException gathering message trace data."
    }

    if ($allMessageTrackResults.count -gt 0) {
        Write-Verbose "`n$($allMessageTrackResults.count) results returned."

        $WantsToTrackMoreSpecifically = $allMessageTrackResults | Out-GridView -PassThru -Title "Message Tracking Log. Select one or more then click OK to track by only those Message IDs."
        if ($WantsToTrackMoreSpecifically) {
            Foreach ($Wants in $WantsToTrackMoreSpecifically) {
                $allMessageTrackResults = [System.Collections.Generic.List[PSObject]]::New()
                try {
                    $messageTrack = $Servers | Get-MessageTrackingLog -MessageID $wants.MessageId -ResultSize $ResultSize
                    if ($messageTrack) {
                        $messageTrack | ForEach-Object {
                            $messageTrackResults = [PSCustomObject]@{
                                Time             = $_.TimeStamp
                                Directionality   = $_.Directionality
                                EventID          = $_.EventID
                                Sender           = $_.Sender
                                Recipients       = $_.Recipients
                                Subject          = $_.MessageSubject
                                Connector        = $_.ConnectorID
                                SourceContext    = $_.SourceContext
                                EventData        = $_.EventData
                                ServerHostName   = $_.ServerHostName
                                ServerIP         = $_.ServerIP
                                ClientIP         = $_.ClientIP
                                OriginalClientIP = $_.OriginalClientIP
                                ClientHostName   = $_.ClientHostName
                                TotalBytes       = $_.TotalBytes                                      
                                MessageId        = $_.MessageId
                            }
                            $allMessageTrackResults.Add($messageTrackResults)
                        }        
                        else {
                            Write-Verbose "`tNo results found"
                        }
                    }
                }
                catch {
                    Write-Verbose "`tException gathering message trace data."
                }
                $allMessageTrackResults | Out-GridView -Title "MessageID: $($Wants.MessageID)"
            }
        }
    }
    else {
        Write-Verbose "`nNo Results found."
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}