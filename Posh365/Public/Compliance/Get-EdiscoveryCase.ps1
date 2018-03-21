function Get-EdiscoveryCase {
    <#
    .SYNOPSIS
    The script in this article lets eDiscovery administrators and eDiscovery managers generate a report that contains
    information about all holds that are associated with eDiscovery cases in the Office 365 Security & Compliance Center. 
    
    .DESCRIPTION
    The script in this article lets eDiscovery administrators and eDiscovery managers generate a report that contains
    information about all holds that are associated with eDiscovery cases in the Office 365 Security & Compliance Center. 
    
    To generate a report on all eDiscovery cases in your organization, you have to be an eDiscovery Administrator in your organization.
    
    .PARAMETER Path
    The path where the report will be generated
    
    .EXAMPLE
    Connect-Cloud Contoso -compliance
    Get-EdiscoveryCase -Path C:\scripts\ -Verbose
    
    .NOTES
    Modified from original script located here: https://support.office.com/en-us/article/Create-a-report-on-holds-in-eDiscovery-cases-in-Office-365-cca08d26-6fbf-4b2c-b102-b226e4cd7381
    #>

    Param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $Path
    )
    $time = Get-Date
    $Path = $Path.fullname.trim('\').ToString()
    $outputpath = $Path.ToString() + '\' + 'CaseHoldsReport' + ' ' + $time.day + '-' + $time.month + '-' + $time.year + ' ' + $time.hour + '.' + $time.minute + '.csv'

    Write-Verbose "Gathering a list of cases and holds..."
    $edc = Get-ComplianceCase -ErrorAction SilentlyContinue
    foreach ($cc in $edc) {
        Write-Verbose "Working on case : $($cc.name)"
        if ($cc.status -eq 'Closed') {
            $cmembers = ((Get-ComplianceCaseMember -Case $cc.name).windowsLiveID) -join ';'
            Add-ToCaseReport -casename $cc.name -casestatus $cc.Status -caseclosedby $cc.closedby -caseClosedDateTime $cc.ClosedDateTime -casemembers $cmembers -OutputPath $outputpath
        }
        else {
            $cmembers = ((Get-ComplianceCaseMember -Case $cc.name).windowsLiveID) -join ';'
            $policies = Get-CaseHoldPolicy -Case $cc.Name | % { Get-CaseHoldPolicy $_.Name -Case $_.CaseId -DistributionDetail}
            foreach ($policy in $policies) {
                $rule = Get-CaseHoldRule -Policy $policy.name
                Add-ToCaseReport -casename $cc.name -casemembers $cmembers -casestatus $cc.Status -casecreatedtime $cc.CreatedDateTime -holdname $policy.name -holdenabled $policy.enabled -holdcreatedby $policy.CreatedBy -holdlastmodifiedby $policy.LastModifiedBy -ExchangeLocation (($policy.exchangelocation.name) -join ';') -SharePointLocation (($policy.sharePointlocation.name) -join ';') -ContentMatchQuery $rule.ContentMatchQuery -holdcreatedtime $policy.WhenCreatedUTC -holdchangedtime $policy.WhenChangedUTC -OutputPath $outputpath
            }
        }
    }
}