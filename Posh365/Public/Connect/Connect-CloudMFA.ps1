function Connect-CloudMFA {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $ExchangeOnline,

        [Parameter()]
        [switch]
        $MSOnline,

        [Parameter()]
        [switch]
        $AzureAD,

        [Parameter()]
        [switch]
        $DeleteCredential
    )
    end {
        if ($Tenant -match 'onmicrosoft') { $Tenant = $Tenant.Split(".")[0] }

        $host.ui.RawUI.WindowTitle = "Tenant: $($Tenant.ToUpper())"
        $PoshPath = Join-Path $Env:USERPROFILE '.Posh365'
        $TenantPath = Join-Path $PoshPath $Tenant
        $CredPath = Join-Path $TenantPath 'Credentials'
        $CredFile = Join-Path $CredPath CC.xml
        $LogPath = Join-Path $TenantPath 'Logs'

        if (-not ($null = Test-Path $CredFile)) {
            $ItemSplat = @{
                Type        = 'Directory'
                Force       = $true
                ErrorAction = 'SilentlyContinue'
            }
            $null = New-Item $PoshPath @ItemSplat
            $null = New-Item $CredPath @ItemSplat
            $null = New-Item $LogPath @ItemSplat
        }

        switch ($true) {
            $DeleteCredential {
                Write-Host "Deleting credential and halting script" Write-Host -ForegroundColor White
                Connect-CloudDeleteCredential -CredFile $CredFile
                break
            }
            { $ExchangeOnline -or $MSOnline -or $AzureAD } {
                if ($null = Test-Path $CredFile) {
                    # Perhaps remove if not needed for any modules
                    [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
                }
                else {
                    [System.Management.Automation.PSCredential]$Credential = Get-Credential -Message 'Enter Office 365 username and password'
                    [System.Management.Automation.PSCredential]$Credential | Export-CliXml -Path $CredFile
                    [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
                }
                $Username = $Credential.Username
                $Password = $Credential.GetNetworkCredential().Password

            }
            $ExchangeOnline {
                Write-Host "Connecting to`tExchange Online" Write-Host -ForegroundColor Green
                Connect-CloudModuleImport -ExchangeOnline
                Import-Module (Connect-EXOPSSession) -Global -WarningAction SilentlyContinue
            }
            $MSOnline {
                Write-Host "Connecting to`tMicrosoft Online" Write-Host -ForegroundColor Green
                Connect-CloudModuleImport -MSOnline
                Connect-MsolService
            }
            $AzureAD {
                Write-Host "Connecting to`Azure AD" Write-Host -ForegroundColor Green
                Connect-CloudModuleImport -AzureAD
                Connect-AzureAD
            }

            default {

            }
        }
        Get-RSJob -State Completed | Remove-RSJob -ErrorAction SilentlyContinue
    }
}
