function Add-ContentFilterPolicyDetail {
    <#
    .SYNOPSIS
        Adds Detail to Content Filter Policy. Specifically, Allowed/Blocked Senders and Domains

    .DESCRIPTION
        Adds Detail to Content Filter Policy. Specifically, Allowed/Blocked Senders and Domains

    .PARAMETER ContentFilterPolicy
        Name of the Content Filter Policy to use.

    .PARAMETER AllowedSenderDomains
        The AllowedSenderDomains parameter specifies trusted domains that aren't processed by the spam filter. 
        Messages from senders in these domains are stamped with SFV:SKA in the X-Forefront-Antispam-Report header and receive a spam confidence level (SCL) of -1,
        so the messages are delivered to the recipient's inbox. Valid values are one or more SMTP domains.
    
    .PARAMETER AllowedSenders
        The AllowedSenders parameter specifies a list of trusted senders that aren't processed by the spam filter.
        Messages from these senders are stamped with SFV:SKA in the X-Forefront-Antispam-Report header and receive an SCL of -1,
        so the messages are delivered to the recipient's inbox. Valid values are one or more SMTP email addresses.

    .PARAMETER BlockedSenderDomains
        The BlockedSenderDomains parameter specifies domains that are always marked as spam sources.
        Messages from senders in these domains are stamped with SFV:SKB in the X-Forefront-Antispam-Report header and receive an SCL of 9 (high confidence spam).
        Valid values are one or more SMTP domains.

    .PARAMETER BlockedSenders
        The BlockedSenders parameter specifies senders that are always marked as spam sources.
        Messages from these senders are stamped with SFV:SKB in the X-Forefront-Antispam-Report header and receive an SCL of 9 (high confidence spam).
        Valid values are one or more SMTP email addresses.

    .PARAMETER OutputPath
        Where to write the report files to.
        By default it will write to the current path.

    .EXAMPLE
        Import-Csv .\PolicyDetail.csv | Add-ContentFilterPolicyDetail -ContentFilterPolicy "Spam Filter Policy for contoso.com recipients"

        Example of PolicyDetail.csv

        AllowedSenderDomains, AllowedSenders, BlockedSenders, BlockedSenderDomains 
        fabrikam.com, fred@contoso.com, harry@contoso.com, evil.com
        google.com, john@contoso.com, bad@contoso.com, bad.com
        wingtip.com, jane@contoso.com, pla@contosa.com, worse.com

    .EXAMPLE
        Import-Csv .\PolicyDetail.csv | Add-ContentFilterPolicyDetail -ContentFilterPolicy "Bypass Spam Filtering for New York Partners"

    .EXAMPLE
        Import-Csv .\PolicyDetail.csv | Add-ContentFilterPolicyDetail -ContentFilterPolicy "Default"

#>
    [CmdletBinding()]
    param (
		
        [Parameter(Mandatory = $true)]
        [String]
        $ContentFilterPolicy,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('AllowedDomains')]
        [Alias('AllowedDomain')]
        [string]
        $AllowedSenderDomains,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('AllowedSender')]
        [string[]]
        $AllowedSenders,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('BlockedSenderDomain')]
        [Alias('BlockedDomains')]
        [Alias('BlockedDomain')]
        [string[]]
        $BlockedSenderDomains,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('BlockedSender')]
        [string[]]
        $BlockedSenders,

        [string]
        $OutputPath = "."
    )
    begin {
        $Params = @{}
        $listAllowedSenderDomains = New-Object System.Collections.Generic.HashSet[String]
        $listAllowedSenders = New-Object System.Collections.Generic.HashSet[String]
        $listBlockedSenderDomains = New-Object System.Collections.Generic.HashSet[String]
        $listBlockedSenders = New-Object System.Collections.Generic.HashSet[String]

        $headerstring = ("ContentFilterPolicy" + "," + "Detail")
        $errheaderstring = ("ContentFilterPolicy" + "," + "Detail" + "," + "Error")
		
        $successPath = Join-Path $OutputPath "Success.csv"
        $failedPath = Join-Path $OutputPath "Failed.csv"
        Out-File -FilePath $successPath -InputObject $headerstring -Encoding UTF8 -append
        Out-File -FilePath $failedPath -InputObject $errheaderstring -Encoding UTF8 -append
		
    }
    process {
        if ($AllowedSenderDomains) {
            [void]$listAllowedSenderDomains.add($AllowedSenderDomains)
        }
        if ($AllowedSenders) {
            [void]$listAllowedSenders.add($AllowedSenders)
        }
        if ($BlockedSenderDomains) {
            [void]$listBlockedSenderDomains.add($BlockedSenderDomains)
        }
        if ($BlockedSenders) {
            [void]$listBlockedSenders.add($BlockedSenders)
        }
    }
    end {
        if ($listAllowedSenderDomains.count -gt "0") {
            if ((Get-HostedContentFilterPolicy $ContentFilterPolicy -ErrorAction SilentlyContinue).AllowedSenderDomains.Domain) {
                (Get-HostedContentFilterPolicy $ContentFilterPolicy).AllowedSenderDomains.Domain | ForEach-Object {[void]$listAllowedSenderDomains.Add($_)}
            }
            $Params.Add("AllowedSenderDomains", $listAllowedSenderDomains)
        }
        if ($listAllowedSenders.count -gt "0") {
            if ((Get-HostedContentFilterPolicy $ContentFilterPolicy -ErrorAction SilentlyContinue).AllowedSenders.Sender.Address) {
                (Get-HostedContentFilterPolicy $ContentFilterPolicy).AllowedSenders.Sender.Address | ForEach-Object {[void]$listAllowedSenders.Add($_)}
            }
            $Params.Add("AllowedSenders", $listAllowedSenders)
        }
        if ($listBlockedSenderDomains.count -gt "0") {
            if ((Get-HostedContentFilterPolicy $ContentFilterPolicy -ErrorAction SilentlyContinue).BlockedSenderDomains.Domain) {
                (Get-HostedContentFilterPolicy $ContentFilterPolicy).BlockedSenderDomains.Domain | ForEach-Object {[void]$listBlockedSenderDomains.Add($_)}
            }
            $Params.Add("BlockedSenderDomains", $listBlockedSenderDomains)
        }
        if ($listBlockedSenders.count -gt "0") {
            if ((Get-HostedContentFilterPolicy $ContentFilterPolicy -ErrorAction SilentlyContinue).BlockedSenders.Sender.Address) {
                (Get-HostedContentFilterPolicy $ContentFilterPolicy).BlockedSenders.Sender.Address | ForEach-Object {[void]$listBlockedSenders.Add($_)}
            }
            $Params.Add("BlockedSenders", $listBlockedSenders)
        }
        if (!(Get-HostedContentFilterPolicy -Identity $ContentFilterPolicy -ErrorAction SilentlyContinue)) {
            Write-Warning "Content Filter Policy `"$ContentFilterPolicy`" does not exist."
            Write-Warning "First create Content Filter Policy in GUI: `"$ContentFilterPolicy`" and then rerun this function."
            Throw
        }
        else { 
            Write-Verbose "Content Filter Policy `"$ContentFilterPolicy`" already exists."
            try {
                Set-HostedContentFilterPolicy -Identity $ContentFilterPolicy @Params -ErrorAction Stop
                Write-Verbose "Parameters: `t $($Params.values | % { $_ -join " "})" 
                $ContentFilterPolicy + "," + ($Params.values | % { $_ -join " "}) | Out-file $successPath -Encoding UTF8 -append
            }
            catch {
                Write-Warning $_
                $ContentFilterPolicy + "," + ($Params.values | % { $_ -join " "}) + "," + $_ | Out-file $failedPath -Encoding UTF8 -append
            }
        }
    }
}
