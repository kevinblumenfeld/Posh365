function Get-ActiveCasConnection {
    <#
    .SYNOPSIS
    Collect counters that show point-in-time use of various protocols (IMAP, POP, EWS, IIS, OWA, RPC)

    .DESCRIPTION
    Collect counters that show point-in-time use of various protocols (IMAP, POP, EWS, IIS, OWA, RPC)
    If you have mixed environment run from highest version
    For example, if you have Exchange 2010, 2013 and 2016 - Run from Exchange 2016 server

    NOTE: This is designed to run against servers where the services are running.
    You must verify POP and IMAP service is running on all the CAS servers prior to adding it to the list of servers

    For example, if the POP service is not running, add '#' to the POP object below, just like this:
    `# POP    = [math]::Truncate((Get-Counter "\MSExchangePOP3(_total)\Connections Current" -ComputerName $CurServer).CounterSamples[0].Cookedvalue)`

    To verify POP3 and/or IMAP4 service is running run these commands (once):
    ```
    $CAS = Get-ClientAccessServer | Select -ExpandProperty name
    $CAS |  % {write-host "`n`nServer: $($_)`nPOP3" -foregroundcolor "Green";Get-service -ComputerName $_ -ServiceName MSExchangePOP3 | Select -expandproperty status }
    $CAS |  % {write-host "`n`nServer: $($_)`nIMAP4" -foregroundcolor "Cyan";Get-service -ComputerName $_ -ServiceName MSExchangeIMAP4 | Select -expandproperty status }
    ```
    .PARAMETER LogPath
    Where the log file will be automatically generated. Example c:\scripts

    .PARAMETER SleepBetweenChecks
    After each server is checked, the script waits this amount of time (seconds) before proceeding to the next server

    .PARAMETER Server
    Feed a list of servers to the function
    This should be passed via the pipeline as demonstrated in the examples below

    .EXAMPLE
    $CAS = Get-ClientAccessServer | Select -ExpandProperty name
    for ($i=0 ; $i -lt 10 ; $i++) {$CAS | Get-ActiveCASConnection -LogPath C:\scripts -SleepBetweenChecks 10}

    This example runs the check 10 times against each server

    .EXAMPLE
    $CAS = "Server01", "Server02"
    for ($i=0 ; $i -lt 100 ; $i++) {$CAS | Get-ActiveCASConnection -LogPath C:\scripts -SleepBetweenChecks 10}

    This example runs the check 100 times against each server for only Server01 and Server 02

    .NOTES
    Counters retrieved are:
        RPC  = RPC Client Access Connections
        OWA  = Current Unique OWA users
        EAS  = EAS Requests/Sec
        IMAP = IMAP Total Connections
        POP  = POP Connections Current
        WSR  = Exchange Web Services Requests/Sec
        WST  = Web Service (IIS) Total Current Connections

        This can be a precursor to enabling protocol logging

        For example:
        Set-ImapSettings -ProtocolLogEnabled:$True -LogPerFileSizeQuota 0 -LogFileRollOverSettings Hourly

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(Mandatory = $true)]
        $LogPath,

        [Parameter(Mandatory = $true)]
        [int] $SleepBetweenChecks,

        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Mandatory = $true)]
        $Server

    )

    begin {
        $Log = Join-Path $LogPath "CasConnections.csv"

        if (-not (Test-Path $Log)) {
            # $headerstring = ('Server' + "," + 'RPC' + "," + 'OWA' + "," + 'EAS' + "," + 'IMAP' + "," + 'POP' + "," + 'WSR' + "," + 'WST' + "," + 'Time')

            # Use when POP3 is not present on the servers
            $headerstring = ('Server' + "," + 'RPC' + "," + 'OWA' + "," + 'EAS' + "," + 'IMAP' + "," + 'WSR' + "," + 'WST' + "," + 'Time')

            # Use when IMAP4 is not present on the servers
            # $headerstring = ('Server' + "," + 'RPC' + "," + 'OWA' + "," + 'EAS' + "," + 'POP' + "," + 'WSR' + "," + 'WST' + "," + 'Time')

            # Use when neither POP nor IMAP is present on the servers
            # $headerstring = ('Server' + "," + 'RPC' + "," + 'OWA' + "," + 'EAS' + "," + "," + 'WSR' + "," + 'WST' + "," + 'Time')

            Out-File -FilePath $Log -InputObject $headerstring -Encoding UTF8 -Append
        }
    }

    process {

        ForEach ($CurServer In $Server) {
            write-host "Checking Connections on SERVER:`t $CurServer"
            $Object = New-Object -TypeName PSObject -Property @{
                Server = $CurServer
                RPC    = (Get-Counter "\MSExchange RpcClientAccess\User Count" -ComputerName $CurServer).CounterSamples[0].Cookedvalue
                OWA    = (Get-Counter "\MSExchange OWA\Current Unique Users" -ComputerName $CurServer).CounterSamples[0].Cookedvalue
                EAS    = [math]::Truncate((Get-Counter "\MSExchange ActiveSync\Requests/sec" -ComputerName $CurServer).CounterSamples[0].Cookedvalue)
                IMAP   = [math]::Truncate((Get-Counter "\MSExchangeImap4(_total)\Current Connections" -ComputerName $CurServer).CounterSamples[0].Cookedvalue)
                # POP    = [math]::Truncate((Get-Counter "\MSExchangePOP3(_total)\Connections Current" -ComputerName $CurServer).CounterSamples[0].Cookedvalue)
                WSR    = [math]::Truncate((Get-Counter "\MSExchangeWS\Requests/sec" -ComputerName $CurServer).CounterSamples[0].Cookedvalue)
                WST    = (Get-Counter "\Web Service(_Total)\Current Connections" -ComputerName $CurServer).CounterSamples[0].Cookedvalue
                Time   = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
            }
        }

        # Use when POP and IMAP are both present on the servers
        # $Object.Server + "," + $Object.RPC + "," + $Object.OWA + "," + $Object.EAS + "," + $Object.IMAP + "," + $Object.POP + "," + $Object.WSR + "," + $Object.WST + "," + $Object.Time | Out-File -FilePath $Log -Encoding UTF8 -Append

        # Use when POP3 is not present on the servers
        $Object.Server + "," + $Object.RPC + "," + $Object.OWA + "," + $Object.EAS + "," + $Object.IMAP + "," + $Object.WSR + "," + $Object.WST + "," + $Object.Time | Out-File -FilePath $Log -Encoding UTF8 -Append

        # Use with IMAP4 is not present on the servers
        # $Object.Server + "," + $Object.RPC + "," + $Object.OWA + "," + $Object.EAS + "," + $Object.POP + "," + $Object.WSR + "," + $Object.WST + "," + $Object.Time | Out-File -FilePath $Log -Encoding UTF8 -Append

        # Use when neither POP nor IMAP is present on the servers
        # $Object.Server + "," + $Object.RPC + "," + $Object.OWA + "," + $Object.EAS + "," + $Object.WSR + "," + $Object.WST + "," + $Object.Time | Out-File -FilePath $Log -Encoding UTF8 -Append

        Start-Sleep -Seconds $SleepBetweenChecks
    }

    end {

    }
}
