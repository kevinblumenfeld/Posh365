function Invoke-EnterBTCustomer {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-BT_Customer -RetrieveAll:$true -IsArchived:$False -SortBy_Updated_Descending
    }
}
