Function Get-ADHashDisplayNameToGuid {
    <#
    .SYNOPSIS

    .EXAMPLE
    
    #>
    param (
        [parameter(ValueFromPipeline = $true)]
        $row
    )
    Begin {
        $ADHashDisplayToGuid = @{}
    }
    Process {
        foreach ($curRow in $row) {
            $ADHashDisplayToGuid[$curRow.DisplayName] = $curRow.ObjectGuid
        }
    }
    End {
        $ADHashDisplayToGuid
    }     
}