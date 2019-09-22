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
                $Script:BitTic = Get-BT_Ticket -Ticket $BitTic -OrganizationId $OrganizationId -SetDefault
            }
            Default {
                [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
                $Script:BitTic = Get-BT_Ticket -Credentials $Credential -ServiceType BitTitan -SetDefault
            }
        }
    }
}
