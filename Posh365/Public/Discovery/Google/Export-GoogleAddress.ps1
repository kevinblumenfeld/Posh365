function Export-GoogleAddress {
    <#
    .SYNOPSIS
    Google's GAM shared mailbox dump is exported with relevant data to import into 365

    .DESCRIPTION
    Long description

    .PARAMETER SharedCsv
    Parameter description

    .EXAMPLE
    Export-GoogleAddress -SharedCsv C:\Scripts\Q\archive\QShared.csv

    .EXAMPLE
    Export-GoogleAddress -SharedCsv C:\Scripts\Q\archive\QShared.csv | Export-csv .\for365.csv -notypeinformation

    .NOTES
    EXAMPLE OF OUTPUT....

    primaryEmail,name.familyName,name.fullName,name.givenName
    joe@contoso.com,smith,joe smith,joe
    jane@contoso.com,jones,jane jones,jane

    #>


    param (

        [Parameter(Mandatory)]
        [string] $SharedCsv

    )

    $CsvList = Import-Csv $SharedCsv
    $PropList = ($CsvList | Select-Object -first 1).psobject.properties.name.where{
        $_ -match 'name.' -or $_ -match 'primaryEmail'
    }
    foreach ($Csv in $CsvList) {
        $PropArray = [System.Collections.Generic.List[string]]::new()
        foreach ($Prop in $PropList) {
            $PropArray.Add($Prop)
        }
        $Csv | Select $PropArray
    }
}
