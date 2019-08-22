function Invoke-EnterBTCustomer {
    [CmdletBinding()]
    Param
    (

    )
    end {
        Get-BT_Customer -RetrieveAll -IsArchived:$False -SortBy_Updated_Descending
    }
}
