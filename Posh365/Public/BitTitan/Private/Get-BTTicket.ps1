function Get-BTTicket {
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        $CredFile,

        [Parameter()]
        $OrganizationId
    )
    end {
        switch ($true) {
            { $OrganizationId } {
                $Global:BTTicket = Get-BT_Ticket -Ticket $BTTicket -OrganizationId $OrganizationId -SetDefault
            }
            Default {
                [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
                $Global:BTTicket = Get-BT_Ticket -Credentials $Credential -ServiceType BitTitan -SetDefault
            }
        }
    }
}
