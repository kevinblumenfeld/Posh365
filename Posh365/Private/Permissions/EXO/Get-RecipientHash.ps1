Function Get-RecipientHash {
    <#
    .SYNOPSIS

    .EXAMPLE

    #>
    param (

    )
    Begin {
        $RecipientHash = @{ }
    }

    Process {
        $RecipientHash[$_.Name] = @{
            PrimarySMTPAddress   = $_.PrimarySMTPAddress
            RecipientTypeDetails = $_.RecipientTypeDetails
        }
    }
    End {
        $RecipientHash
    }
}
