Function Get-ADHashMailToGuid {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $row
    )
    Begin {
        $ADHashMailToGuid = @{}
    }
    Process {
        foreach ($curRow in $row) {
            $ADHashMailToGuid[$curRow.mail] = $curRow.ObjectGuid
        }
    }
    End {
        $ADHashMailToGuid
    }     
}