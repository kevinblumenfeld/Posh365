function Get-PermissionChain {
    
    <#
    .SYNOPSIS
    With the exception of Full Access permissions, mailbox permissions do not currently allow access cross-premises (between Office 365, Exchange OnPrem & vice-versa).
    Therefore this script will analyze a list your provide to determine which other mailboxes need to be migrated along with your list.
    
    Provide a list of UPNs to be migrated to Office 365 and this script will output all mailboxes that need to be migrated with them - Based on mailbox permissions.
    The output will be a single column of UPNs that will include the original list provided by you.  
    This can be used as the migration batch file - just add a header of EmailAddress and you are ready to migrate!
    
    .EXAMPLE 
    Get-Content .\UPNs.txt  | Get-PermissionChain | Export-Csv .\MigrationBatch.csv -notypeinformation 
    
    .EXAMPLE
    "mailbox01@contoso.com" | Get-PermissionChain | Export-Csv .\MigrationBatch.csv -notypeinformation
    
    .EXAMPLE
    
    Get-Content .\UPNs.txt  | Get-PermissionChain -IgnoreFullAccess | Export-Csv .\MigrationBatch.csv -notypeinformation 
    .EXAMPLE
    
    Get-Content .\UPNs.txt  | Get-PermissionChain -IgnoreFullAccess -IgnoreSendOnBehalf | Export-Csv .\MigrationBatch.csv -notypeinformation 
    
    .EXAMPLE
    "mailbox01@contoso.com","mailbox02@contoso.com" | Get-PermissionChain | Export-Csv .\MigrationBatch.csv -notypeinformation
    
    .EXAMPLE
    Get-Content .\UPNs.txt | Get-PermissionChain -ReportPath C:\Scripts\perms  | % {$upn = $_ ; try {Get-Mailbox -Identity $upn -ErrorAction stop > $null} catch {$upn}}

    Make sure you are connect to Exchange Online for this example.
    This will verify that the mailbox has not been migrated to Exchange Online and only output the UPNs of mailboxes yet to be migrated
    
    #>
    
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $Names,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $ReportPath,

        [Parameter(Mandatory = $false)]
        [switch] $IgnoreFullAccess,

        [Parameter(Mandatory = $false)]
        [switch] $IgnoreSendAs,

        [Parameter(Mandatory = $false)]
        [switch] $IgnoreSendOnBehalf,

        [Parameter(Mandatory = $false)]
        [switch] $CombineResultsWithOriginalList,

        [Parameter(Mandatory = $false, ParameterSetName = "Cache")]
        [switch] $GeneratePermissionCacheOnly
    )
    Begin {
        $swvar = @()
        if ($IgnoreFullAccess) {
            $swvar += "FullAccess"
        }
        if ($IgnoreSendAs) {
            $swvar += "SendAs"            
        }
        if ($IgnoreSendOnBehalf) {
            $swvar += "SendOnBehalf"            
        }
        $swvar = $swvar -join ("|")

        New-Item -ItemType Directory c:\pScripts -ErrorAction SilentlyContinue
        
        if (![System.IO.File]::Exists((Join-Path $ReportPath "allPermissions.csv"))) {
            Get-MailboxPerms -ReportPath "C:\PermsReports"
        }
        If ($GeneratePermissionCacheOnly) {
            Break
        }
                
        $Data = Import-Csv (Join-Path $ReportPath "allPermissions.csv")
        $Output = [System.Collections.Generic.HashSet[string]]::new()
        $AllNames = [System.Collections.Generic.HashSet[string]]::new()
    }
    Process {
        $AllNames.add($_) > $null
        $Names | Get-MigrationChain -DataSet $Data -swvar $swvar | % { $Output.add($_) > $null } 

    }
    End {
        if (-not $CombineResultsWithOriginalList) {
            Foreach ($name in $AllNames) {
                $Output.Remove($name) > $null
            }
        }
        $Output | Sort
    }
}
