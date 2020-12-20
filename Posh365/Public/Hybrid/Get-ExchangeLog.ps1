function Get-ExchangeLog {
    [cmdletbinding(DefaultParameterSetName = 'Placeholder')]
    param (
        [Parameter()]
        $Server,

        [Parameter(ParameterSetName = 'EWS')]
        [switch]
        $EWS,

        [Parameter(ParameterSetName = 'AutoDProxy')]
        [switch]
        $AutodiscoverProxy,

        [Parameter(ParameterSetName = 'EWSProxy')]
        [switch]
        $EWSProxy,

        [Parameter()]
        [string]
        $UserNameContains,

        [Parameter()]
        [int]
        $LogNumber = 1

    )
    if ($Server) {
        $ExchangePath = Invoke-Command -ComputerName $Server -ScriptBlock { $env:ExchangeInstallPath }
        $ExchangePath = '\\{0}\{1}${2}' -f $Server, (Split-Path $ExchangePath -Qualifier)[0], (Split-Path $ExchangePath -NoQualifier)
    }
    else {
        $ExchangePath = $env:ExchangeInstallPath
    }
    if ($AutodiscoverProxy) {
        $LogPath = '{0}Logging\HttpProxy\Autodiscover' -f $ExchangePath
    }
    elseif ($EWSProxy) {
        $LogPath = '{0}Logging\HttpProxy\Ews' -f $ExchangePath
    }
    elseif ($EWS) {
        $LogPath = '{0}Logging\Ews' -f $ExchangePath
    }
    else { return }

    $LogFileName = (Get-ChildItem -Path $LogPath -File | Sort-Object LastWriteTime -Descending | Select-Object -skip ($LogNumber - 1) -First 1).fullname
    $Data = Import-Csv -Path $LogFileName
    if ($UserNameContains) {
        ($Data | Select-Object -Skip 5).where{ $_.AuthenticatedUser -like "*$UserNameContains*" }
    }
    else {
        $Data | Select-Object -Skip 5
    }
}
