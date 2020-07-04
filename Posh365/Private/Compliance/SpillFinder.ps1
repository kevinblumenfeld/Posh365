function SpillFinder {
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
        [Parameter(Mandatory)]
        $Tenant,

        [Parameter()]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'DeletedItems', 'drafts', 'Inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter()]
        [switch]
        $DeleteCreds,

        [Parameter()]
        [datetime]
        $MessagesOlderThan,

        [Parameter()]
        [datetime]
        $MessagesNewerThan,

        [Parameter()]
        [string]
        $Body,

        [Parameter()]
        [string]
        $Subject,

        [Parameter()]
        [string]
        $From,

        [Parameter()]
        [string]
        $CC,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [mailaddress[]]
        $UserPrincipalName
    )

    if ($DeleteCreds) {
        Connect-PoshGraph -Tenant $Tenant -DeleteCreds$DeleteCreds
        $null = $PSBoundParameters.Remove('DeleteCreds')
        SpillFinder $PSBoundParameters
    }
    $PSBoundParameters

}
