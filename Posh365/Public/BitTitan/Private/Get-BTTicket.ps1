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
                $Script:BitTitanTicket = Get-BT_Ticket -Ticket $BitTitanTicket -OrganizationId $OrganizationId -SetDefault
            }
            Default {
                [System.Management.Automation.PSCredential]$Credential = Import-Clixml -Path $CredFile
                $Script:BitTitanTicket = Get-BT_Ticket -Credentials $Credential -ServiceType BitTitan -SetDefault
            }
        }
    }
}
