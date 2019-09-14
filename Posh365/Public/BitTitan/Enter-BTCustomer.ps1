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
            $Script:BitTitanTicket = Get-BT_Ticket -Ticket $BitTitanTicket -OrganizationId $CustomerChoice.OrganizationId -Environment BT
            $host.ui.RawUI.WindowTitle = "BitTitan Project: *** $($CustomerChoice.CompanyName) ***"
        }
        else {
            Write-Host "Please run the command again and choose a customer" -ForegroundColor Red
        }
    }
}
