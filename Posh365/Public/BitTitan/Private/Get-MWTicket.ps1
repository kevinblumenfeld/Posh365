function Get-MWTicket {
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        $CredFile
    )
    end {
        [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
        $Script:MigWizTicket = Get-MW_Ticket -Credentials $Credential -SetDefault
    }
}
