Function Get-RecipientLiveIDHash {
    <#
    .SYNOPSIS

    .EXAMPLE

    #>
    param (

    )
    Begin {
        $RecipientLiveIDHash = @{ }
    }

    Process {
        $RecipientLiveIDHash[$_.WindowsLiveID] = @{
            PrimarySMTPAddress   = $_.PrimarySMTPAddress
            Name                 = $_.Name
            RecipientTypeDetails = $_.RecipientTypeDetails
        }
    }
    End {
        $RecipientLiveIDHash
    }
}
