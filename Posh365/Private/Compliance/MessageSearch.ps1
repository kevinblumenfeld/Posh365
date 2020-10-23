function MessageSearch {
    <#
        .SYNOPSIS
        Search for content with Microsoft's compliance search and optionally delete found content. A maximum of 10 mail messages per mailbox (per search)

        .DESCRIPTION
        Search for content with Microsoft's compliance search and optionally delete said content
        Currently supports the Exchange workflow

        .PARAMETER _ExchangeServer
        Add the FQDN to the on-premises Exchange Server. Skip this step if using Exchange Online

        .PARAMETER _ExchangeServerBasicAuth
        Check this checkbox if connecting to Exchange when Basic Authentication required. Skip this step if using Exchange Online

        .PARAMETER _ExchangeOnline
        Check this checkbox to connect to the Office 365 Security and Compliance Center (SCC).
        You will be prompted to connect if you are not already
        If You have connected to Exchange on-premises or have more than one Session, each session will be removed, and a new connection will be initiated
        You will have to type your credentials each new session.

        .PARAMETER RequiredSearchName
        A unique search name for your organization and specific for your search.

        Example:
        Search and Delete all messages with the words pear and apple in the subject

        .PARAMETER __HardDelete
        Allows for Hard Deletion of messages.  In other words, they will be unrecoverable
        Otherwise deletions will be soft deleted.  That is, unless Single Item Recovery is not enabled
        Use with caution.
        NOTE: Microsoft’s compliance searches will delete a maximum of 10 messages (per mailbox) per search
                Use additional searches to remove more than 10 messages.


        .PARAMETER _From
        Accepts a single email address

        .PARAMETER _To

        Accepts one or more email addresses separated by commas

        Examples:

        1. jane@contoso.com
        - The search will find email with just Jane

        2. jane@contoso.com, joe@contoso.com
        - The search will not find email with just Jane
        - The search will find email with Jane and Joe


        .PARAMETER _SubjectContains
        The search will only find email with this subject

        Use the checkbox "SubjectContainsIsCommaSeparated" to specify a list of words (comma separated), all of which must be found in the email's subject

        Example:
        1. Apple
        2. Apple, Pear, Kiwi

        If not using SubjectContainsIsCommaSeparated checkbox, the search will look for the entire string

        If using SubjectContainsIsCommaSeparated checkbox, the search will look for each word in the comma-separated list of words. Not together as a phrase.


        .PARAMETER _SubjectContainsIsCommaSeparated
        Check this checkbox to look for more than one word in the subject

        Example:
        1. You check this checkbox.
        2. In the "Subject" field you type:
            Apple, Pear, Orange

        -	The search will find this subject:
            The Apple, Pear and Orange

        -	The search will not find:
            The Apple, Pear and Banana

        .PARAMETER _SubjectDoesNotContain
        This removes from search results, any emails with the word or phrase specified

        Commas are literal, not treated as CSVs
        In this example, you would not find results with the entire phrase, “Apple, Pear” with the space shown.
        Note: you would NOT find results as this is SubjectDoesNotContain.

        Example:
        1.	Apple
        2.	Apple, Pear

        .PARAMETER _DateStart
        A date (and optionally a time) in the past from when you wish to start the search

        Use the format: YYYY-MM-DDThh:mm:ss

        A few examples:

        2020-06-25
        2020-06-25T14:00
        2020-06-25T14:00:12

        .PARAMETER _DateEnd
        A date (and optionally a time) in the past from when you wish to end the search

        NOTE: Must be more recent that DateStart

        Use the format: YYYY-MM-DDThh:mm:ss

        A few examples:

        2020-06-25
        2020-06-25T15:00
        2020-06-25T15:00:12

        .PARAMETER AttachmentName
        Find any emails with the AttachmentName specified
        Note: Only one attachment name can be specified per search

        Examples:
        1. Attachment Test.txt
        2. AttachmentTest.txt


        .PARAMETER MailboxesToSearch
        The MailboxesToSearch parameter specifies the mailboxes to include

        Valid values are:
        A regular user mailbox. Including other types of mailboxes (for example, inactive mailboxes or Microsoft 365 guest users) is controlled by the AllowNotFoundExchangeLocationsEnabled parameter.
        A distribution group or mail-enabled security group (all mailboxes that are currently members of the group).

        NOTE:
        To specify a mailbox or distribution group, use the email address
        You can specify multiple values separated by commas.

        Leave blank for the default value. The default value is All, for all mailboxes.

        .PARAMETER ExceptionList
        A list of exceptions to ALL, the default value of MailboxesToSearch (when MailboxesToSearch is left blank, ALL is used)

        This parameter specifies the mailboxes to exclude when you use the value All for the MailboxesToSearch parameter. Valid values are:
        -	A mailbox(es)
        -	A distribution group(s) or mail-enabled security group (all mailboxes that are currently members of the group)
        You can specify multiple values separated by commas.


        .PARAMETER ExceptionFilePath

        Specify a file path to a text file.
	    Example: c:\scripts\mailboxes.txt

        1. The file should be a text file
        2. The file should contain a list of emailaddresses separated by commas


        .EXAMPLE

        Use PowerShell 5.1
        Simply type the command in an elevated PowerShell prompt:

        New-MessageSearch

        .NOTES
        Regarding Purging

        SoftDelete: Purged items are recoverable by users until the deleted item retention period expires

        HardDelete (cloud only): Purged items are marked for permanent removal from the mailbox and will be permanently removed the next time the mailbox is processed by the Managed Folder Assistant
        If single item recovery is enabled on the mailbox, purged items will be permanently removed after the deleted item retention period expires.

        Special characters

        Some special characters are not included in the search index and therefore are not searchable
        This also includes the special characters that represent search operators in the search query.
        Here's a list of special characters that are either replaced by a blank space in the actual search query or cause a search error.

        + - = : ! @ # % ^ & ; _ / ? ( ) [ ] { }

        .LINK
        Compliance searches can be found here:
        https://protection.office.com/contentsearch

        the new beta version can be found here:
        https://protection.office.com/contentsearchbeta?ContentOnly=1

        This site allows for you to:
        1.	Previewing Results
        2.	Exporting Results
        3.	Creating report on results

        IMPORTANT: PRIOR TO DELETING, have a look here to determine what you are about to delete
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
        $_From,

        [Parameter()]
        [string[]]
        $_Content,

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
        [string]
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
        [string]
        $CaseName,

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
    $ORQuery = [System.Collections.Generic.List[string]]::New()


    if ( $_From ) { $Query.Add('From:{0}' -f $_From) }
    if ( $_Content ) { (@($_Content) -ne '').split(',').trim() | ForEach-Object { $ORQuery.Add('"{0}"' -f $_) } }
    if ( $_CC ) { (@($_CC) -ne '') | ForEach-Object { $Query.Add('CC:{0}' -f $_) } }
    if ( $_To ) { (@($_To) -ne '') | ForEach-Object { $Query.Add('To:{0}' -f $_) } }
    if ( $_SubjectContains ) {
        if ( $_SubjectContainsIsCommaSeparated ) { (@($_SubjectContains) -ne '').split(',').trim() | ForEach-Object { $Query.Add('Subject:"{0}"' -f $_) } }
        else { $Query.Add(('Subject:"{0}"' -f $_SubjectContains)) }
    }
    if ( $_SubjectDoesNotContain ) { (@($_SubjectDoesNotContain) -ne '') | ForEach-Object { $Query.Add('-Subject:"{0}"' -f $_) } }
    if ( $_DateStart ) { $Query.Add(('Received:{0}..{1}' -f $_DateStart.ToUniversalTime().ToString("O") , $_DateEnd.ToUniversalTime().ToString("O"))) }
    if ( $AttachmentName ) { $Query.Add('Attachment:"{0}"' -f $AttachmentName) }
    if ( $Query ) {
        $KQL = '({0})' -f (@($Query) -join ') AND (')
    }
    if ($ORQuery) {
        if ($KQL) {
            $KQL = '{0} AND ({1})' -f $KQL, ('({0})' -f (@($ORQuery) -join ') OR ('))
        }
        else {
            $KQL = '({0})' -f (@($ORQuery) -join ') OR (')
        }

    }
    $Splat['ContentMatchQuery'] = $KQL
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
            (Get-PSSession -Name $_ExchangeServer -ErrorAction SilentlyContinue).State -ne 'Opened')) {
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

    if ($CaseName) {
        if (-not ($null = Get-ComplianceCase -Identity $CaseName -ErrorAction SilentlyContinue )) {
            $NewCase = New-ComplianceCase -Name $CaseName
            Write-Host "New e-discovery case created: $($NewCase.Name)" -ForegroundColor Cyan
        }
        $Splat['Case'] = $CaseName
    }

    $Splat
}
