Function Get-ADHashMailToGuid {
    param (
        [parameter(ValueFromPipeline = $true)]
        $row
    )
    begin {
        $ADHashMailToGuid = @{ }
    }
    process {
        foreach ($curRow in $row) {
            $ADHashMailToGuid[$curRow.mail] = $curRow.ObjectGuid
        }
    }
    end {
        $ADHashMailToGuid
    }
}
