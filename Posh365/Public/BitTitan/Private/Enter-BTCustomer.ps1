function Enter-BTCustomer {
    [CmdletBinding()]
    Param
    (

    )
    end {
        $Select = @(
            'CompanyName', 'PrimaryDomain', 'Updated', 'OrganizationId'
        )
        $CustomerChoice = Invoke-EnterBTCustomer | Select-Object $Select | Out-GridView -Title "Choose the BitTitan customer you wish to work with" -OutputMode Single
        if ($CustomerChoice) {
            Write-Host "CompanyName: $($CustomerChoice.CompanyName)"
            $Script:Connector = Get-MW_MailboxConnector -Ticket $MigWizTicket -Name $CustomerChoice.CompanyName
        }
        else {
            Write-Host "Please run the command again and choose a customer" -ForegroundColor Red
        }
    }
}
