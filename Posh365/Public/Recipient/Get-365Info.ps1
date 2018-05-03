function Get-365Info { 
    <#
    .SYNOPSIS
    Controller function for gathering information from an Office 365 tenant

    .DESCRIPTION
    Controller function for gathering information from an Office 365 tenant

    All multivalued attributes are expanded for proper output
    
    What information is gathered:
    1. Recipients
    2. MsolUsers
    3. MsolGroups
    4. Distribution Groups (includes mail-enabled Security Groups)
    5. Mailboxes
    6. Archive Mailboxes
    7. Resource Mailboxes with Calendar Processing
    8. Licenses assigned to each user broken out by Options
    9. Retention Policies and linked Retention Tags in a single report
    
    If using the -Filtered switch, it will be necessary to replace domain placeholders in script (e.g. contoso.com etc.)
    The filters can be adjusted to anything supported by the -Filter parameter (OPath filters)

    .EXAMPLE
    Get-365Info -Tenant CONTOSO -Verbose

    .EXAMPLE
    Get-365Info -Tenant CONTOSO -Filtered -Verbose
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Tenant,

        [Parameter(Mandatory = $false)]
        [switch] $Filtered
    )
    Begin {
        $servicesSplat = @{}
        try {
            $null = Get-AcceptedDomain -ErrorAction Stop
        }
        catch {
            $servicesSplat.ExchangeOnline = $True
        } 

        try {
            $null = Get-MsolDomain -ErrorAction Stop
        }
        catch {
            $servicesSplat.MSOnline = $True
        } 
        if ($servicesSplat.count -gt 0) {
            Connect-Cloud -Tenant $Tenant @servicesSplat -Verbose:$false
        }
    }
    Process {
        
        $RecipientFileName = ($Tenant + "-Recipients.csv")
        $RecipientFileNameDetailed = ($Tenant + "-Recipients_Detailed.csv")
        $MsolUserFileName = ($Tenant + "-MsolUser.csv")
        $MsolUserFileNameDetailed = ($Tenant + "-MsolUser_Detailed.csv")
        $MsolGroupFileName = ($Tenant + "-MsolGroup.csv")
        $EXOGroupFileName = ($Tenant + "-EXOGroup.csv")
        $EXOGroupFileNameDetailed = ($Tenant + "-EXOGroup_Detailed.csv")
        $EXOMailboxFileName = ($Tenant + "-EXOMailbox.csv")
        $EXOMailboxFileNameDetailed = ($Tenant + "-EXOMailbox_Detailed.csv")
        $EXOArchiveMailboxFileName = ($Tenant + "-EXOArchiveMailbox.csv")
        $EXOArchiveMailboxFileNameDetailed = ($Tenant + "-EXOArchiveMailbox_Detailed.csv")
        $EXOResourceMailboxFileName = ($Tenant + "-EXOResourceMailbox.csv")
        $RetentionLinksFileName = ($Tenant + "-RetentionLinks.csv")
        $UnifiedGroupsFileName = ($Tenant + "-UnifiedGroups.csv")

        if (! $Filtered) {

            Write-Verbose "Gathering 365 Recipients"
            Get-365Recipient | Export-Csv .\$RecipientFileName -notypeinformation -encoding UTF8
            Get-365Recipient -DetailedReport | Export-Csv .\$RecipientFileNameDetailed -notypeinformation -encoding UTF8
        
            Write-Verbose "Gathering MsolUsers"
            Get-365MsolUser | Export-Csv .\$MsolUserFileName -notypeinformation -encoding UTF8
            Get-365MsolUser -DetailedReport | Export-Csv .\$MsolUserFileNameDetailed -notypeinformation -encoding UTF8
        
            Write-Verbose "Gathering MsolGroups"
            Get-365MsolGroup | Export-Csv .\$MsolGroupFileName -notypeinformation -encoding UTF8
        
            Write-Verbose "Gathering Distribution & Mail-Enabled Security Groups"
            Get-EXOGroup | Export-Csv .\$EXOGroupFileName -notypeinformation -encoding UTF8
            Get-EXOGroup -DetailedReport | Export-Csv .\$EXOGroupFileNameDetailed -notypeinformation -encoding UTF8
        
            Write-Verbose "Gathering Exchange Online Mailboxes"
            Get-EXOMailbox | Export-Csv .\$EXOMailboxFileName -notypeinformation -encoding UTF8
            Get-EXOMailbox -DetailedReport | Export-Csv .\$EXOMailboxFileNameDetailed -notypeinformation -encoding UTF8
            
            Write-Verbose "Gathering Exchange Online Archive Mailboxes"
            Get-EXOMailbox -ArchivesOnly | Export-Csv .\$EXOArchiveMailboxFileName -notypeinformation -encoding UTF8
            Get-EXOMailbox -ArchivesOnly -DetailedReport | Export-Csv .\$EXOArchiveMailboxFileNameDetailed -notypeinformation -encoding UTF8
            
            Write-Verbose "Gathering Exchange Online Resource Mailboxes and Calendar Processing"
            Get-EXOResourceMailbox | Export-Csv .\$EXOResourceMailboxFileName -notypeinformation -encoding UTF8
            
            Write-Verbose "Gathering Office 365 Licenses"
            Get-CloudLicense
            
            Write-Verbose "Gathering Mailbox Delegate Permissions"
            Get-EXOMailboxPerms -Tenant $Tenant -ReportPath .\
    
            Write-Verbose "Gathering Distribution Group Delegate Permissions"
            Get-EXODGPerms -Tenant $Tenant -ReportPath .\
    
        }
        
        else {

            Write-Verbose "Gathering 365 Recipients - filtered"
            '{UserPrincipalName -like "*contoso.com" -or 
            emailaddresses -like "*contoso.com" -or 
            ExternalEmailAddress -like "*contoso.com" -or 
            PrimarySmtpAddress -like "*contoso.com"}' | Get-365Recipient | Export-Csv .\$RecipientFileName -notypeinformation -encoding UTF8
            
            '{UserPrincipalName -like "*contoso.com" -or 
            emailaddresses -like "*contoso.com" -or 
            ExternalEmailAddress -like "*contoso.com" -or 
            PrimarySmtpAddress -like "*contoso.com"}' | Get-365Recipient -DetailedReport | Export-Csv .\$RecipientFileNameDetailed -notypeinformation -encoding UTF8
            
            Write-Verbose "Gathering MsolUsers - filtered"
            'contoso.com' | Get-365MsolUser | Export-Csv .\$MsolUserFileName -notypeinformation -encoding UTF8
            'contoso.com' | Get-365MsolUser -DetailedReport | Export-Csv .\$MsolUserFileNameDetailed -notypeinformation -encoding UTF8
    
            Write-Verbose "Gathering MsolGroups - filtered"
            Get-MsolGroup -All | Where-Object {$_.proxyaddresses -like "*contoso.com"} | Select -ExpandProperty ObjectId | Get-365MsolGroup | Export-Csv .\$MsolGroupFileName -notypeinformation -encoding UTF8
    
            Write-Verbose "Gathering Distribution & Mail-Enabled Security Groups - filtered"
            Get-DistributionGroup -Filter "emailaddresses -like '*contoso.com*'" -ResultSize Unlimited | Select -ExpandProperty Name | Get-EXOGroup | Export-Csv .\$EXOGroupFileName -notypeinformation -encoding UTF8
            Get-DistributionGroup -Filter "emailaddresses -like '*contoso.com*'" -ResultSize Unlimited | Select -ExpandProperty Name | Get-EXOGroup -DetailedReport | Export-Csv .\$EXOGroupFileNameDetailed -notypeinformation -encoding UTF8
    
            Write-Verbose "Gathering Exchange Online Mailboxes - filtered"
            '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox | Export-Csv .\$EXOMailboxFileName -notypeinformation -encoding UTF8
            '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox -DetailedReport | Export-Csv .\$EXOMailboxFileNameDetailed -notypeinformation -encoding UTF8
            
            Write-Verbose "Gathering Exchange Online Archive Mailboxes - filtered"
            '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox -ArchivesOnly | Export-Csv .\$EXOArchiveMailboxFileName -notypeinformation -encoding UTF8
            '{emailaddresses -like "*contoso.com"}' | Get-EXOMailbox -ArchivesOnly -DetailedReport | Export-Csv .\$EXOArchiveMailboxFileNameDetailed -notypeinformation -encoding UTF8

            Write-Verbose "Gathering Exchange Online Resource Mailboxes and Calendar Processing"
            '{emailaddresses -like "*contoso.com"}' | Get-EXOResourceMailbox | Export-Csv .\$EXOResourceMailboxFileName -notypeinformation -encoding UTF8

            Write-Verbose "Gathering Office 365 Licenses - filtered"
            'contoso.com' | Get-CloudLicense
            
            Write-Verbose "Gathering Mailbox Delegate Permissions - filtered" 
            Get-Recipient -Filter {EmailAddresses -like "*contoso.com"} -ResultSize Unlimited | Select -ExpandProperty name | Get-EXOMailboxPerms -Tenant $Tenant -ReportPath .\
                
            Write-Verbose "Gathering Distribution Group Delegate Permissions - filtered"
            Get-Recipient -Filter {EmailAddresses -like "*contoso.com"} -ResultSize Unlimited | Select -ExpandProperty name | Get-EXODGPerms -Tenant $Tenant -ReportPath .\
    
        }

        Write-Verbose "Gathering Retention Polices and linked Retention Policy Tags"
        Get-RetentionLinks | Export-Csv .\$RetentionLinksFileName -notypeinformation -encoding UTF8

        Write-Verbose "Gathering Office 365 Unified Groups"
        Export-AndImportUnifiedGroups -Mode Export -File .\$UnifiedGroupsFileName
    }
    End {
        
    }
}