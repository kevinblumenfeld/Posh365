function Get-MfaStats {
    
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory = $true,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true)]
            [string[]] $userprincipalname,
            
            [Parameter(Mandatory = $false)]
            [switch] $Archive,
      
            [Parameter(Mandatory = $false)]
            [switch] $StartMFA
        )
        Begin {
            $resultarray = @()

    
        }
        Process {
            foreach ($CurUPN in $userprincipalname) {
                if ($StartMFA) {
                    Write-Output "Starting Managed Folder Assistant on: $($CurUPN)"
                    Start-ManagedFolderAssistant $CurUPN
                }
                else {
                    if ($Archive) {
                        $logProps = Export-MailboxDiagnosticLogs $CurUPN -ExtendedProperties -Archive
                    }
                    else {
                        $logProps = Export-MailboxDiagnosticLogs $CurUPN -ExtendedProperties
                    }
                    $xmlprops = [xml]($logProps.MailboxLog)
                    $stats = $xmlprops.Properties.MailboxTable.Property | ? {$_.Name -like "ELC*"} 
                    $statHash = [ordered]@{}
                    for ($i = 0; $i -lt $stats.count; $i++) {
                        $statHash['UPN'] = $CurUPN
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