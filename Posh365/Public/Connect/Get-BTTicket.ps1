function Get-BTTicket {
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
            [ManagementProxy.ManagementService.Ticket]$BTTicket = Import-Clixml -Path $BTTicketFile
            $null = Get-BT_Ticket -Ticket $BTTicket
        }
        else {
            [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
            $BTTicket = Get-BT_Ticket -Credentials $Credential -ServiceType BitTitan -SetDefault -ErrorAction Stop
            [ManagementProxy.ManagementService.Ticket]$BTTicket | Export-Clixml -Path $Path
        }
    }
}
