function Get-MWTicket {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [Parameter(Mandatory)]
        $Path,

        [Parameter()]
        $CredFile,

        [Parameter()]
        [switch]
        $UseExistingTicket
    )
    end {
        if ($UseExistingTicket) {
            [MigrationProxy.WebApi.Ticket]$MWTicket = Import-Clixml -Path $Path
            $null = Get-MW_Ticket -Ticket $MWTicket
        }
        else {
            [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
            $MWTicket = Get-MW_Ticket -Credentials $Credential -SetDefault -ErrorAction Stop
            [MigrationProxy.WebApi.Ticket]$MWTicket | Export-Clixml -Path $Path
        }
    }
}
