function Get-MfaStats {

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]] $UserPrincipalName,

        [Parameter(Mandatory = $false)]
        [switch] $Archive,

        [Parameter(Mandatory = $false)]
        [switch] $StartMFA
    )
    Begin {
        $resultarray = @()


    }
    Process {
        foreach ($UPN in $UserPrincipalName) {
            if ($StartMFA) {
                Write-Output "Starting Managed Folder Assistant on: $($UPN)"
                Start-ManagedFolderAssistant $UPN
            }
            else {
                if ($Archive) {
                    $logProps = Export-MailboxDiagnosticLogs $UPN -ExtendedProperties -Archive
                }
                else {
                    $logProps = Export-MailboxDiagnosticLogs $UPN -ExtendedProperties
                }
                $xmlprops = [xml]($logProps.MailboxLog)
                $stats = $xmlprops.Properties.MailboxTable.Property | ? { $_.Name -like "ELC*" }
                $statHash = [ordered]@{ }
                for ($i = 0; $i -lt $stats.count; $i++) {
                    $statHash['UPN'] = $UPN
                    $statHash[$stats[$i].name] = $stats[$i].value
                }
                $resultarray += [PSCustomObject]$statHash
            }
        }
    }
    End {
        $resultarray
    }
}
