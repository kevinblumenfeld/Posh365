function MessageSearch {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER _ExchangeServer
    Parameter description

    .PARAMETER RequiredSearchName
    Parameter description

    .PARAMETER _From
    Parameter description

    .PARAMETER _Subject
    Parameter description

    .PARAMETER _DateStart

    A date (and optionally a time) in the past from when you wish to start the search

    Use the format: YYYY-MM-DDThh:mm:ss

    A few examples:

    2020-06-25
    2020-06-25T14:00
    2020-06-25T14:00:12

    .PARAMETER _DateEnd
    A date (and optionally a time) in the past from when you wish to end the search

    NOTE: Must be more recent that _DateStart

    Use the format: YYYY-MM-DDThh:mm:ss

    A few examples:

    2020-06-25
    2020-06-25T15:00
    2020-06-25T15:00:12

    .PARAMETER AttachmentName
    Parameter description

    .PARAMETER MailboxesToSearch
    Parameter description

    .PARAMETER ExceptionList
    Parameter description

    .PARAMETER ExceptionFile
    Parameter description

    .EXAMPLE
    An example

    .NOTES

    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        $_ExchangeServer,

        [Parameter()]
        [switch]
        $_ExchangeOnline,

        [Parameter(Mandatory)]
        $RequiredSearchName,

        [Parameter()]
        [switch]
        $__HardDelete,

        [Parameter()]
        $_From,

        [Parameter()]
        $_To,

        [Parameter()]
        $_Subject,

        [Parameter()]
        [switch]
        $_SubjectAllowWildcards,

        [Parameter()]
        [datetime]
        $_DateStart,

        [Parameter()]
        [datetime]
        $_DateEnd = ([datetime]::Now),

        [Parameter()]
        $AttachmentName,

        [Parameter()]
        $MailboxesToSearch = 'ALL',

        [Parameter()]
        $ExceptionList,

        [Parameter()]
        [ValidateScript( { Test-Path $_ })]
        $ExceptionFile
    )

    $Script:DeleteSplat = @{ }
    if ($__HardDelete -and $_ExchangeOnline) { $Script:HardOrSoft = 'HardDelete' }
    else { $Script:HardOrSoft = 'SoftDelete' }


    $Splat = @{ }
    $Splat['Name'] = $RequiredSearchName

    $Query = [System.Collections.Generic.List[string]]::New()

    if ($_From ) { $Query.Add('From:{0}' -f $_From) }
    if ($_To ) { $Query.Add('To:{0}' -f $_To) }
    if ($_Subject) {
        if ($_SubjectAllowWildcards) { $Query.Add('Subject:{0}' -f $_Subject) }
        else { $Query.Add('Subject:''{0}''' -f $_Subject) }
    }
    if ($_DateStart) { $Query.Add(('Received:{0}..{1}' -f $_DateStart.ToUniversalTime().ToString("O") , $_DateEnd.ToUniversalTime().ToString("O"))) }
    if ($AttachmentName) { $Query.Add('Attachment={0}' -f $AttachmentName) }

    if ($Query) {
        $KQL = '({0})' -f (@($Query) -join ') AND (')
        $Splat['ContentMatchQuery'] = $KQL
    }
    if ($MailboxesToSearch -eq 'ALL' -and ($ExceptionList -or $ExceptionFile)) {
        if ($ExceptionFile -or ($ExceptionList -and $ExceptionFile)) {
            $Exceptions = (Get-Content $ExceptionFile).split(',')
        }
        else { $Exceptions = $ExceptionList }
        $Splat['ExchangeLocationExclusion'] = $Exceptions
        $Splat['ExchangeLocation'] = 'ALL'
    }
    else { $Splat['ExchangeLocation'] = $MailboxesToSearch }
    $Sesh = Get-PSSession
    if ($_ExchangeServer -and ($Sesh.State -match 'Broken|Disconnected|Closed' -or (-not (Get-Command Get-ComplianceSearch)) -or
            $Sesh.Count -gt 1 -or $Sesh.ComputerName -match 'ps.compliance.protection.outlook.com' -and
            (Get-PSSession -Name $_ExchangeServer).State -ne 'Opened')) {
        Get-PSSession | Remove-PSSession
        Connect-OnPremExchange -Server $_ExchangeServer
    }
    elseif ($_ExchangeOnline -and ($Sesh.State -match 'Broken|Disconnected|Closed' -or (-not (Get-Command 'Get-ComplianceSearch' -ErrorAction SilentlyContinue) -or
                $Sesh.Count -gt 1 -or $Sesh.ComputerName -notmatch 'ps.compliance.protection.outlook.com'))) {
        Get-PSSession | Remove-PSSession
        Connect-ExchangeOnline -ConnectionUri 'https://ps.compliance.protection.outlook.com/powershell-liveid' -ShowBanner:$false
        Write-Host "You have successfully connected to Security & Compliance Center" -foregroundcolor "magenta" -backgroundcolor "white"
    }
    if (-not $_ExchangeServer -and -not $_ExchangeOnline) { return }
    $Splat
}