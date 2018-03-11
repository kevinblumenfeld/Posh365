function Add-TransportRuleDetail {
    <#
    .SYNOPSIS
        Adds details to Transport Rule.  If the transport rule does not exist it creates it.

    .DESCRIPTION
        Adds details to Transport Rule.  If the transport rule does not exist it creates it.

    .PARAMETER TransportRule
        Name of the Transport Rule to use.  If Transport Rule does not exist it will be created.

    .PARAMETER RecipientAddressContainsWords
        This parameter specifies a condition or part of a condition for the rule. The name of the corresponding exception parameter starts with ExceptIf.

        In on-premises Exchange, this condition is only available on Mailbox servers.

        The RecipientAddressContainsWords parameter specifies a condition that looks for words in recipient email addresses.
        You can specify multiple words separated by commas. This parameter works when the recipient is an individual user.
        This parameter doesn't work with distribution groups.
    
    .PARAMETER ExceptIfRecipientAddressContainsWords
        This parameter specifies an exception or part of an exception for the rule. The name of the corresponding condition doesn't include the ExceptIf prefix.

        In on-premises Exchange, this exception is only available on Mailbox servers.

        The ExceptIfRecipientAddressContainsWords parameter specifies an exception that looks for words in recipient email addresses.
        You can specify multiple words separated by commas. This parameter works when the recipient is an individual user.
        This parameter doesn't work with distribution groups.

    .PARAMETER SubjectOrBodyContainsWords
        This parameter specifies a condition or part of a condition for the rule. The name of the corresponding exception parameter starts with ExceptIf.

        In on-premises Exchange, this condition is available on Mailbox servers and Edge Transport servers.

        The SubjectOrBodyContainsWords parameter specifies a condition that looks for words in the Subject field or body of messages.

    .PARAMETER ExceptIfSubjectOrBodyContainsWords
        This parameter specifies an exception or part of an exception for the rule. The name of the corresponding condition doesn't include the ExceptIf prefix.

        In on-premises Exchange, this exception is available on Mailbox servers and Edge Transport servers.

        The ExceptIfSubjectOrBodyContainsWords parameter specifies an exception that looks for words in the Subject field or body of messages.

    .PARAMETER SenderIPRanges
        This parameter specifies a condition or part of a condition for the rule. The name of the corresponding exception parameter starts with ExceptIf.

        In on-premises Exchange, this condition is only available on Mailbox servers.

        The SenderIpRanges parameter specifies a condition that looks for senders whose IP addresses matches the specified value, or fall within the specified ranges. Valid values are:

            Single IP address   For example, 192.168.1.1.
            IP address range   For example, 192.168.0.1-192.168.0.254.
            Classless InterDomain Routing (CIDR) IP address range   For example, 192.168.0.1/25.

        You can specify multiple IP addresses or ranges separated by commas.

    .PARAMETER AttachmentContainsWords
        This parameter specifies a condition or part of a condition for the rule. The name of the corresponding exception parameter starts with ExceptIf.

        In on-premises Exchange, this condition is only available on Mailbox servers.

        The AttachmentContainsWords parameter specifies a condition that looks for words in message attachments. Only supported attachment types are checked.

        To specify multiple words or phrases, this parameter uses the syntax: Word1,"Phrase with spaces",word2,.... Don't use leading or trailing spaces.
    
    .PARAMETER AttachmentMatchesPatterns
        This parameter specifies a condition or part of a condition for the rule. The name of the corresponding exception parameter starts with ExceptIf.

        In on-premises Exchange, this condition is only available on Mailbox servers.

        The AttachmentMatchesPatterns parameter specifies a condition that looks for text patterns in the content of message attachments by using regular expressions. Only supported attachment types are checked.

        You can specify multiple text patterns by using the following syntax: "<regular expression1>","<regular expression2>",....

    .PARAMETER OutputPath
        Where to write the report files to.
        By default it will write to the current path.

    .EXAMPLE
        Import-Csv .\RuleDetails.csv | Add-TransportRuleDetail -TransportRule "Block Macros Except when Certain Words are used" -Action01 DeleteMessage

        Example of RuleDetails.csv

        AddressWords, SubjectBodyWords, ExceptSubjectBodyWords, SenderIPs 
        fred@contoso.com, moon, wind, 142.23.221.21
        jane@fabrikam.com, sun fire, rain, 142.23.220.1-142.23.220.254
        potato.com, ocean, snow, 72.14.52.0/24
    .EXAMPLE
        Import-Csv .\RuleDetails.csv | Add-TransportRuleDetail -TransportRule "Bypass Spam Filtering for New York Partners" -Action01 BypassSpamFiltering

#>
    [CmdletBinding()]
    param (
		
        [Parameter(Mandatory = $true)]
        [String]
        $TransportRule,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('AddressWords')]
        [string]
        $RecipientAddressContainsWords,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('ExceptAddressWords')]
        [string[]]
        $ExceptIfRecipientAddressContainsWords,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('SubjectBodyWords')]
        [Alias('SBWords')]
        [string[]]
        $SubjectOrBodyContainsWords,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('ExceptSubjectBodyWords')]
        [Alias('ExceptSBWords')]
        [string[]]
        $ExceptIfSubjectOrBodyContainsWords,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('SenderIP')]
        [Alias('SenderIPs')]
        [string[]]
        $SenderIPRanges,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('AttachmentWords')]
        [string[]]
        $AttachmentContainsWords,
                
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('AttachmentPatterns')]
        [string[]]
        $AttachmentMatchesPatterns,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("DeleteMessage", "BypassSpamFiltering")]
        $Action01,

        [string]
        $OutputPath = "."
    )
    begin {
        $Params = @{}
        $listAddressWords = New-Object System.Collections.Generic.HashSet[String]
        $listExceptAddressWords = New-Object System.Collections.Generic.HashSet[String]
        $listSBWords = New-Object System.Collections.Generic.HashSet[String]
        $listExceptSBWords = New-Object System.Collections.Generic.HashSet[String]
        $listAttachmentWords = New-Object System.Collections.Generic.HashSet[String]
        $listAttachmentPattern = New-Object System.Collections.Generic.HashSet[String]
        $listSenderIPRanges = New-Object System.Collections.Generic.HashSet[String]

        $headerstring = ("TransportRule" + "," + "Details")
        $errheaderstring = ("TransportRule" + "," + "Details" + "," + "Error")
		
        $successPath = Join-Path $OutputPath "Success.csv"
        $failedPath = Join-Path $OutputPath "Failed.csv"
        Out-File -FilePath $successPath -InputObject $headerstring -Encoding UTF8 -append
        Out-File -FilePath $failedPath -InputObject $errheaderstring -Encoding UTF8 -append
		
    }
    process {
        if ($RecipientAddressContainsWords) {
            [void]$listAddressWords.add($RecipientAddressContainsWords)
        }
        if ($ExceptIfRecipientAddressContainsWords) {
            [void]$listExceptAddressWords.add($ExceptIfRecipientAddressContainsWords)
        }
        if ($SubjectOrBodyContainsWords) {
            [void]$listSBWords.add($SubjectOrBodyContainsWords)
        }
        if ($ExceptIfSubjectOrBodyContainsWords) {
            [void]$listExceptSBWords.add($ExceptIfSubjectOrBodyContainsWords)
        }
        if ($AttachmentContainsWords) {
            [void]$listAttachmentWords.add($AttachmentContainsWords)
        }
        if ($AttachmentMatchesPatterns) {
            [void]$listAttachmentPattern.add($AttachmentMatchesPatterns)
        }        
        if ($SenderIPRanges) {
            [void]$listSenderIPRanges.add($SenderIPRanges)
        }
    }
    end {
        if ($listAddressWords.count -gt "0") {
            if ((Get-TransportRule $TransportRule -ErrorAction SilentlyContinue).RecipientAddressContainsWords) {
                (Get-TransportRule $TransportRule).RecipientAddressContainsWords | ForEach-Object {[void]$listAddressWords.Add($_)}
            }
            $Params.Add("RecipientAddressContainsWords", $listAddressWords)
        }
        if ($listExceptAddressWords.count -gt "0") {
            if ((Get-TransportRule $TransportRule -ErrorAction SilentlyContinue).ExceptIfRecipientAddressContainsWords) {
                (Get-TransportRule $TransportRule).ExceptIfRecipientAddressContainsWords | ForEach-Object {[void]$listExceptAddressWords.Add($_)}
            }
            $Params.Add("ExceptIfRecipientAddressContainsWords", $listExceptAddressWords)
        }
        if ($listSBWords.count -gt "0") {
            if ((Get-TransportRule $TransportRule -ErrorAction SilentlyContinue).SubjectOrBodyContainsWords) {
                (Get-TransportRule $TransportRule).SubjectOrBodyContainsWords | ForEach-Object {[void]$listSBWords.Add($_)}
            }
            $Params.Add("SubjectOrBodyContainsWords", $listSBWords)
        }
        if ($listExceptSBWords.count -gt "0") {
            if ((Get-TransportRule $TransportRule -ErrorAction SilentlyContinue).ExceptIfSubjectOrBodyContainsWords) {
                (Get-TransportRule $TransportRule).ExceptIfSubjectOrBodyContainsWords | ForEach-Object {[void]$listExceptSBWords.Add($_)}
            }
            $Params.Add("ExceptIfSubjectOrBodyContainsWords", $listExceptSBWords)
        }
        if ($listAttachmentWords.count -gt "0") {
            if ((Get-TransportRule $TransportRule -ErrorAction SilentlyContinue).AttachmentContainsWords) {
                (Get-TransportRule $TransportRule).AttachmentContainsWords | ForEach-Object {[void]$listAttachmentWords.Add($_)}
            }
            $Params.Add("AttachmentContainsWords", $listAttachmentWords)
        }
        if ($listAttachmentPattern.count -gt "0") {
            if ((Get-TransportRule $TransportRule -ErrorAction SilentlyContinue).AttachmentMatchesPatterns) {
                (Get-TransportRule $TransportRule).AttachmentMatchesPatterns | ForEach-Object {[void]$listAttachmentPattern.Add($_)}
            }
            $Params.Add("AttachmentMatchesPatterns", $listAttachmentPattern)
        }
        if ($listSenderIPRanges.count -gt "0") {
            if ((Get-TransportRule $TransportRule -ErrorAction SilentlyContinue).senderipranges) {
                (Get-TransportRule $TransportRule).senderipranges | ForEach-Object {[void]$listSenderIPRanges.Add($_)}
            }
            $Params.Add("SenderIPRanges", $listSenderIPRanges)
        }
        if ($Action01 -eq "DeleteMessage") {
            $Params.Add("DeleteMessage", $true)
        }
        if ($Action01 -eq "BypassSpamFiltering") {
            $Params.Add("SetSCL", "-1")
        }
        if (!(Get-TransportRule -Identity $TransportRule -ErrorAction SilentlyContinue)) {
            Try {
                New-TransportRule -Name $TransportRule @Params -ErrorAction Stop
                Write-Verbose "Transport Rule `"$TransportRule`" has been created."
                Write-Verbose "Parameters: `t $($Params.values | % { $_ -join " "})"
            }
            Catch {
                $_
                Write-Verbose "Unable to Create Transport Rule"
                Throw
            }
        }
        else { 
            Write-Verbose "Transport Rule `"$TransportRule`" already exists."
            try {
                Set-TransportRule -Identity $TransportRule @Params -ErrorAction Stop
                Write-Verbose "Parameters: `t $($Params.values | % { $_ -join " "})" 
                $TransportRule + "," + ($Params.values | % { $_ -join " "}) | Out-file $successPath -Encoding UTF8 -append
            }
            catch {
                Write-Warning $_
                $TransportRule + "," + ($Params.values | % { $_ -join " "}) + "," + $_ | Out-file $failedPath -Encoding UTF8 -append
            }
        }
    }
}
# Import-Csv c:\scripts\words.csv | Add-TransportRuleDetail -TransportRule "MultipleColumns10" -Action01 BypassSpamFiltering -Verbose