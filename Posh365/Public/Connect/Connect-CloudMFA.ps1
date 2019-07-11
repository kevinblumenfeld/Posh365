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
        $DeleteCredentials
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
        if ($null = Test-Path $CredFile) {
            [System.Management.Automation.PSCredential]$Cred = Import-CliXml -Path $CredFile
        }
        else {
            [System.Management.Automation.PSCredential]$Cred = Get-Credential -Message "Enter Office 365 username and password"
            [System.Management.Automation.PSCredential]$Cred | Export-CliXml -Path $CredFile
        }
        $Cred.UserName | Set-Clipboard
        switch ($true) {
            $ExchangeOnline {
                Start-Job {
                    Microsoft.PowerShell.Utility\Add-Type -As System.Windows.Forms
                    [System.Windows.Forms.MessageBox]::Show("Click OK to copy password to clipboard")
                    $args[0] | Clip
                } -ArgumentList $Cred.GetNetworkCredential().Password
                Connect-CloudMFADLL
                Import-Module (Connect-EXOPSSession) -Global
            }
            $MSOnline { }
            $AzureAD { }
            $DeleteCredentials { Connect-CloudDeleteCredentials -CredFile $CredFile }
            default {

            }
        }
    }
}
