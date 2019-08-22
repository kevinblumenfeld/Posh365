function Get-MWTicket {
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        $CredFile
    )
    end {
        [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
        $Global:MWTicket = Get-MW_Ticket -Credentials $Credential -SetDefault
    }
}
