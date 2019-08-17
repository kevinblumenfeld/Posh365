function Connect-BitTitan {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [Parameter()]
        [ValidateNotNull()]
        [mailaddress]
        $EmailAddress,

        [Parameter()]
        [switch]
        $BitTitan,

        [Parameter()]
        [switch]
        $MigrationWiz,

        [Parameter()]
        [switch]
        $DeleteCredential
    )
    end {
        if (-not (Get-Module -Name BitTitanManagement -ListAvailable).version.build -eq 85) {
            Install-Module -Name BitTitanManagement -RequiredVersion 0.0.85 -Force -Scope CurrentUser
            Import-Module -Name BitTitanManagement -Version 0.0.85 -Force
        }
        else {
            Import-Module -Name BitTitanManagement -Version 0.0.85 -Force
        }
        $host.ui.RawUI.WindowTitle = "BitTitan Tenant: $($EmailAddress)"
        $PoshPath = Join-Path $Env:USERPROFILE '.Posh365'
        $TenantPath = Join-Path $PoshPath $EmailAddress
        $CredPath = Join-Path $TenantPath 'Credentials'
        $CredFile = Join-Path $CredPath BitTitan.xml
        $BTTicketFile = Join-Path $CredPath BTTicket.xml
        $MWTicketFile = Join-Path $CredPath MWTicket.xml
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
            [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
        }
        else {
            [System.Management.Automation.PSCredential]$Credential = Get-Credential -Message 'Enter your BitTitan email address and password' -UserName $EmailAddress
            [System.Management.Automation.PSCredential]$Credential | Export-Clixml -Path $CredFile
            [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
        }

        switch ($true) {
            { $DeleteCredential } {
                Write-Host "Credential is being deleted now" -ForegroundColor White
                Connect-CloudDeleteCredential -CredFile $CredFile
                return
            }
            { $BitTitan } {
                Write-Host "Obtaining BitTitan Ticket" -ForegroundColor White
                try {
                    if ($null = Test-Path $BTTicketFile) {
                        [ManagementProxy.ManagementService.Ticket]$BTTicket = Import-Clixml -Path $BTTicketFile
                        if ($BTTicket.ExpirationDate -lt (Get-Date)) {
                            Get-BTTicket -Path $BTTicketFile -CredFile $CredFile -ErrorAction Stop
                            Write-Host "Successfully Obtained BitTitan Ticket" -ForegroundColor Green
                        }
                        else {
                            Get-BTTicket -Path $BTTicketFile -UseExistingTicket -ErrorAction Stop
                            Write-Host "Successfully Obtained BitTitan Ticket" -ForegroundColor Green
                        }
                    }
                    else {
                        Get-BTTicket -Path $BTTicketFile -CredFile $CredFile -ErrorAction Stop
                        Write-Host "Successfully Obtained BitTitan Ticket" -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "Could not Obtain BitTitan Ticket" -ForegroundColor Red
                }
            }
            { $MigrationWiz } {
                Write-Host "Obtaining MigrationWiz Ticket" -ForegroundColor White
                try {
                    $MWTicket = Get-MW_Ticket -Credentials $Credential -SetDefault -ErrorAction Stop
                    $MWTicket
                    Write-Host "Successfully Obtained Migration Wiz Ticket" -ForegroundColor Green
                }
                catch {
                    Write-Host "Could not Obtain Migration Wiz Ticket" -ForegroundColor Red
                }
            }
            default { }
        }
    }
}
