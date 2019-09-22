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
        $SkipModuleCheck,

        [Parameter()]
        [switch]
        $DeleteCredential
    )
    end {
        if ( $Email ) {
            $EmailAddress = $Email
        }
        if (-not $SkipModuleCheck ) {
            if (-not (Get-Module -Name BitTitanManagement -ListAvailable).version.build -eq 85) {
                Install-Module -Name BitTitanManagement -RequiredVersion 0.0.85 -Force -Scope CurrentUser
                Import-Module -Name BitTitanManagement -Version 0.0.85 -Force
            }
            else {
                Import-Module -Name BitTitanManagement -Version 0.0.85 -Force
            }
        }

        $host.ui.RawUI.WindowTitle = "BitTitan Tenant: $($EmailAddress)"
        $PoshPath = Join-Path $Env:USERPROFILE '.Posh365'
        $TenantPath = Join-Path $PoshPath $EmailAddress
        $CredPath = Join-Path $TenantPath 'Credentials'
        $CredFile = Join-Path $CredPath BitTitan.xml

        if (-not ($null = Test-Path $CredFile)) {
            $ItemSplat = @{
                Type        = 'Directory'
                Force       = $true
                ErrorAction = 'SilentlyContinue'
            }
            $null = New-Item $PoshPath @ItemSplat
            $null = New-Item $CredPath @ItemSplat
        }

        if (-not ($null = Test-Path $CredFile)) {
            [System.Management.Automation.PSCredential]$Credential = Get-Credential -Message 'Enter your BitTitan email address and password' -UserName $EmailAddress
            [System.Management.Automation.PSCredential]$Credential | Export-Clixml -Path $CredFile
        }
        switch ($true) {
            { $EmailAddress } {
                $Script:Email = $EmailAddress.Address
            }
            { $DeleteCredential } {
                Write-Host "Credential is being deleted now" -ForegroundColor White
                Connect-CloudDeleteCredential -CredFile $CredFile
                return
            }

            default { }
        }
        Write-Host "Obtaining BitTitan Ticket" -ForegroundColor White
        try {
            # Gets ticket without org
            Get-BTTicket -CredFile $CredFile -ErrorAction Stop
            Write-Host "Successfully obtained BitTitan Ticket" -ForegroundColor Green
        }
        catch {
            Write-Host "Could not obtain BitTitan Ticket" -ForegroundColor Red
            $_.Exception.Message
        }
        # Enters Customer
        Enter-BTCustomer
        Write-Host "To switch projects type:" -NoNewline -ForegroundColor Yellow
        Write-Host " Enter-BTCustomer " -ForegroundColor Green -NoNewline
        Write-Host "Then hit enter and select the Customer from the menu that appears." -ForegroundColor Yellow
    }
}
