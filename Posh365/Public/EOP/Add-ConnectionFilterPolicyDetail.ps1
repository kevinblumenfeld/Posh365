function Add-ConnectionFilterPolicyDetail {
    <#
    .SYNOPSIS
        Adds Detail to Connection Filter Policy. Specifically, Allowed/Blocked IP Addresses. If the Connection Filter Policy does not exist, it creates it.

    .DESCRIPTION
        Adds Detail to Connection Filter Policy. Specifically, Allowed/Blocked IP Addresses. If the Connection Filter Policy does not exist, it creates it.

    .PARAMETER ConnectionFilterPolicy
        Name of the Connection Filter Policy to use.

    .PARAMETER IPAllowList
        The IPAllowList parameter specifies IP addresses from which messages are always allowed.
        Messages from the IP addresses you specify won't be identified as spam, despite any other spam characteristics of the messages.

        You enter the IP addresses using the following syntax:

        Single IP   For example, 192.168.1.1
        IP range   You can use an IP address range, for example, 192.168.0.1-192.168.0.254
        CIDR IP   You can use Classless InterDomain Routing (CIDR), for example, 192.168.0.1/25
    
    .PARAMETER IPBlockList
        The IPBlockList parameter specifies IP addresses from which messages are never allowed. Messages from the IP addresses you specify are blocked without any further spam scanning.

        You enter the IP addresses using the following syntax:

        Single IP   For example, 192.168.1.1
        IP range   You can use an IP address range, for example, 192.168.0.1-192.168.0.254
        CIDR IP   You can use Classless InterDomain Routing (CIDR), for example, 192.168.0.1/25

    .PARAMETER OutputPath
        Where to write the report files to.
        By default it will write to the current path.

    .EXAMPLE
        Import-Csv .\ConnectionFilterIPs.csv | Add-ConnectionFilterPolicyDetail -ConnectionFilterPolicy "Important Connection to allow and deny by IP"

        Example of ConnectionFilterIPs.csv

        IPAllowList, IPBlockList 
        43.56.231.221, 72.56.231.100
        43.56.231.222, 72.56.231.101
        43.56.231.223, 72.56.231.103

    .EXAMPLE
        Import-Csv .\ConnectionFilterIPs.csv | Add-ConnectionFilterPolicyDetail -ConnectionFilterPolicy "IPs of NewYork Partners"

    .EXAMPLE
        Import-Csv .\IPs.csv | Add-ConnectionFilterPolicyDetail -ConnectionFilterPolicy "Notable Connections"

#>
    [CmdletBinding()]
    param (
		
        [Parameter(Mandatory = $true)]
        [String]
        $ConnectionFilterPolicy,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('AllowedIPs')]
        [Alias('AllowedIP')]
        [string[]]
        $IPAllowList,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('BlockedIPs')]
        [Alias('BlockedIP')]
        [string[]]
        $IPBlockList,

        [string]
        $OutputPath = "."
    )
    begin {
        $Params = @{}
        $listIPAllowList = New-Object System.Collections.Generic.HashSet[String]
        $listIPBlockList = New-Object System.Collections.Generic.HashSet[String]
        
        $headerstring = ("ConnectionFilterPolicy" + "," + "Detail")
        $errheaderstring = ("ConnectionFilterPolicy" + "," + "Detail" + "," + "Error")
		
        $successPath = Join-Path $OutputPath "Success.csv"
        $failedPath = Join-Path $OutputPath "Failed.csv"
        Out-File -FilePath $successPath -InputObject $headerstring -Encoding UTF8 -append
        Out-File -FilePath $failedPath -InputObject $errheaderstring -Encoding UTF8 -append
		
    }
    process {
        if ($IPAllowList) {
            foreach ($CurIPAllow in $IPAllowList) {
                [void]$listIPAllowList.add($CurIPAllow)
            }
        }
        if ($IPBlockList) {
            foreach ($CurIPBlock in $IPBlockList) {
                [void]$listIPBlockList.add($CurIPBlock)
            }
        }
    }
    end {
        if ($listIPAllowList.count -gt "0") {
            if ((Get-HostedConnectionFilterPolicy $ConnectionFilterPolicy -ErrorAction SilentlyContinue).IPAllowList) {
                (Get-HostedConnectionFilterPolicy $ConnectionFilterPolicy).IPAllowList | ForEach-Object {[void]$listIPAllowList.Add($_)}
            }
            $Params.Add("IPAllowList", $listIPAllowList)
        }
        if ($listIPBlockList.count -gt "0") {
            if ((Get-HostedConnectionFilterPolicy $ConnectionFilterPolicy -ErrorAction SilentlyContinue).IPBlockList) {
                (Get-HostedConnectionFilterPolicy $ConnectionFilterPolicy).IPBlockList | ForEach-Object {[void]$listIPBlockList.Add($_)}
            }
            $Params.Add("IPBlockList", $listIPBlockList)
        }
        if (!(Get-HostedConnectionFilterPolicy -Identity $ConnectionFilterPolicy -ErrorAction SilentlyContinue)) {
            Write-Warning "Connection Filter Policy `"$ConnectionFilterPolicy`" does not exist.  Attempting to create..."
            try {
                New-HostedConnectionFilterPolicy -Name $ConnectionFilterPolicy @Params -ErrorAction Stop
                Write-Verbose "Connection Filter Policy `"$ConnectionFilterPolicy`" has been created."
                Write-Verbose "Parameters: `t $($Params.values | % { $_ -join " "})" 
                $ConnectionFilterPolicy + "," + ($Params.values | % { $_ -join " "}) | Out-file $successPath -Encoding UTF8 -append
            }
            catch {
                Write-Warning $_
                $ConnectionFilterPolicy + "," + ($Params.values | % { $_ -join " "}) + "," + $_ | Out-file $failedPath -Encoding UTF8 -append
            }
        }
        else { 
            Write-Verbose "Connection Filter Policy `"$ConnectionFilterPolicy`" already exists.  Adding any new IPs to existing IPs"
            try {
                Set-HostedConnectionFilterPolicy -Identity $ConnectionFilterPolicy @Params -ErrorAction Stop
                Write-Verbose "Parameters: `t $($Params.values | % { $_ -join " "})" 
                $ConnectionFilterPolicy + "," + ($Params.values | % { $_ -join " "}) | Out-file $successPath -Encoding UTF8 -append
            }
            catch {
                Write-Warning $_
                $ConnectionFilterPolicy + "," + ($Params.values | % { $_ -join " "}) + "," + $_ | Out-file $failedPath -Encoding UTF8 -append
            }
        }
    }
}
