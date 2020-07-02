function MessageSearch {
    <#
        .SYNOPSIS
        Search for content with Micrsoft's compliance search and optionally delete said content

        .DESCRIPTION
        Search for content with Micrsoft's compliance search and optionally delete said content

        Currently supports the Exchange workflow. Workflows like SharePoint, OneDrive

        .PARAMETER _ExchangeServer
        Add the fqdn to the on-premises Exchange Server

        .PARAMETER _ExchangeServerBasicAuth
        Check this checkbox if connecting from a domain that is different from where the Exchange Server lives.

        .PARAMETER _ExchangeOnline
        Check this checkbox to connect to the Office 365 Security and Compliance Center (SCC)

        .PARAMETER RequiredSearchName
        A unique name for your organization.

        Feel free to use spaces, and dates for uniqueness.

        Commas cannot be used in the name

        .PARAMETER __HardDelete
        Parameter description

        .PARAMETER _From
        Accepts a single email address

        .PARAMETER _To

        Accepts one more more email addresses separated by commas

        Examples:

        1. jane@contoso.com

        - The search will find email with just Jane
        - The search will find email with Jane and Joe
        - The search will find email with Jane, Joe, and Pat

        2. jane@contoso.com, joe@contoso.com

        - The search will not find email with just Jane
        - The search will find email with Jane and Joe
        - The search will find email with Jane, Joe, and Pat

        .PARAMETER _SubjectContains
        The search will only find email with this subject

        Use the checkbox "SubjectContainsIsCommaSeparated" to specify a
            list of words (comma separated), all of which must be found in the emails subject

        Always use quotes around your search with commas

        Example:

        1. Apple
        2. "Apple, Pear, Kiwi"

        If not using SubjectContainsIsCommaSeparated checkbox, the search
            will look for the entire string

        If using SubjectContainsIsCommaSeparated checkgbox, the search
            will look for each word in the comma separated list of words. Not necessarily together as a phrase.

        .PARAMETER _SubjectContainsIsCommaSeparated
        Check this checkbox to look for more than one word in the subject

        Example:

        1. You check this checkbox.
        2. In the "Subject" field you type:

            Apple, Pear, Orange

        - The search will find this subject:

            The Apple, Pear and Orange

        - The search will not find:

            The Apple, Pear and Banana

        .PARAMETER _SubjectDoesNotContain
        This removes from search any emails with

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
        Find any emails with the AttachmentName specified

        Only one attachment name can be specified per search

        Examples:

        1. Attachment Test.txt
        2. AttachmentTest.txt

        .PARAMETER MailboxesToSearch
        The MailboxesToSearch parameter specifies the mailboxes to include. Valid values are:

        A regular user mailbox. Including other types of mailboxes (for example, inactive mailboxes or Microsoft 365 guest users) is controlled by the AllowNotFoundExchangeLocationsEnabled parameter.

        A distribution group or mail-enabled security group (all mailboxes that are currently members of the group).

        To specify a mailbox or distribution group, use the email address. You can specify multiple values separated by commas.

        The default value is All, for all mailboxes.

        .PARAMETER ExceptionList
        A list of exceptions to ALL,. the default value of MailboxesToSearch (when MailboxesToSearch is left blank, ALL is used)

        This parameter specifies the mailboxes to exclude when you use the value All for the MailboxesToSearch parameter.

        Valid values are:

        A mailbox(es)

        A distribution group(s) or mail-enabled security group (all mailboxes that are currently members of the group).

        You can specify multiple values separated by commas.

        .PARAMETER ExceptionFilePath

        Specify a file path to a text file.

        1. The file should be a text file
        2. The file should contain a list of emailaddresses separated by commas

        .EXAMPLE

        Simply type the command

        New-MessageSearch

        .NOTES
        General notes
        #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $_ExchangeServer,

        [Parameter()]
        [switch]
        $_ExchangeServerBasicAuth,

        [Parameter()]
        [switch]
        $_ExchangeOnline,

        [Parameter(Mandatory)]
        [string]
        $RequiredSearchName,

        [Parameter()]
        [switch]
        $__HardDelete,

        [Parameter()]
        [mailaddress]
        $_From,

        [Parameter()]
        [mailaddress[]]
        $_To,

        [Parameter()]
        [mailaddress[]]
        $_CC,

        [Parameter()]
        [switch]
        $_SubjectContainsIsCommaSeparated,

        [Parameter()]
        [string]
        $_SubjectContains,

        [Parameter()]
        [string[]]
        $_SubjectDoesNotContain,

        [Parameter()]
        [datetime]
        $_DateStart,

        [Parameter()]
        [datetime]
        $_DateEnd = ([datetime]::Now),

        [Parameter()]
        [string]
        $AttachmentName,

        [Parameter()]
        [mailaddress[]]
        $MailboxesToSearch,

        [Parameter()]
        [mailaddress[]]
        $ExceptionList,

        [Parameter()]
        [string]
        [ValidateScript( { Test-Path $_ })]
        $ExceptionFilePath
    )
    $Script:HardOrSoft = $null
    if ($__HardDelete -and $_ExchangeOnline) { $Script:HardOrSoft = 'HardDelete' }
    else { $Script:HardOrSoft = 'SoftDelete' }

    $Splat = @{ }
    $Splat['Name'] = $RequiredSearchName

    $Query = [System.Collections.Generic.List[string]]::New()

    if ($_From ) { $Query.Add('From:"{0}"' -f $_From) }
    if ($_CC ) { (@($_CC) -ne '') | ForEach-Object { $Query.Add('CC:"{0}"' -f $_) } }
    if ($_To ) { (@($_To) -ne '') | ForEach-Object { $Query.Add('To:"{0}"' -f $_) } }
    if ($_SubjectContains) {
        if ($_SubjectContainsIsCommaSeparated) { (@($_SubjectContains) -ne '').split(',') | foreach-object { $Query.Add('Subject:"{0}"' -f $_) } }
        else { $Query.Add('Subject:"{0}"' -f $_SubjectContains) }
    }
    if ($_SubjectDoesNotContain) { (@($_SubjectDoesNotContain) -ne '') | ForEach-Object { $Query.Add('-Subject:"{0}"' -f $_) } }
    if ($_DateStart) { $Query.Add(('Received:{0}..{1}' -f $_DateStart.ToUniversalTime().ToString("O") , $_DateEnd.ToUniversalTime().ToString("O"))) }
    if ($AttachmentName) { $Query.Add('Attachment:"{0}"' -f $AttachmentName) }

    if ($Query) {
        $KQL = '({0})' -f (@($Query) -join ') AND (')
        $Splat['ContentMatchQuery'] = $KQL
    }
    if (-not $MailboxesToSearch) { $Splat['ExchangeLocation'] = 'ALL' }
    if (-not $MailboxesToSearch -and ($ExceptionList -or $ExceptionFilePath)) {
        if ($ExceptionFilePath -or ($ExceptionList -and $ExceptionFilePath)) {
            $Exceptions = (Get-Content $ExceptionFilePath).split(',')
        }
        else { $Exceptions = $ExceptionList }
        $Splat['ExchangeLocationExclusion'] = $Exceptions
    }
    elseif ($MailboxesToSearch) { $Splat['ExchangeLocation'] = $MailboxesToSearch }

    $Session = Get-PSSession
    if ($_ExchangeServer -and ($Session.State -match 'Broken|Disconnected|Closed' -or (-not (Get-Command Get-ComplianceSearch -ErrorAction SilentlyContinue)) -or
            $Session.Count -gt 1 -or $Session.ComputerName -match 'ps.compliance.protection.outlook.com' -and
            (Get-PSSession -Name $_ExchangeServer).State -ne 'Opened')) {
        Get-PSSession | Remove-PSSession
        Connect-OnPremExchange -Server $_ExchangeServer -Basic:$_ExchangeServerBasicAuth
    }
    elseif ($_ExchangeOnline -and ($Session.State -match 'Broken|Disconnected|Closed' -or (-not (Get-Command 'Get-ComplianceSearch' -ErrorAction SilentlyContinue) -or
                $Session.Count -gt 1 -or $Session.ComputerName -notmatch 'ps.compliance.protection.outlook.com'))) {
        Get-PSSession | Remove-PSSession
        Connect-ExchangeOnline -ConnectionUri 'https://ps.compliance.protection.outlook.com/powershell-liveid' -ShowBanner:$false
        Write-Host "You have successfully connected to Security & Compliance Center" -foregroundcolor "magenta" -backgroundcolor "white"
    }
    if (-not $_ExchangeServer -and -not $_ExchangeOnline) { return }

    $Splat
}
