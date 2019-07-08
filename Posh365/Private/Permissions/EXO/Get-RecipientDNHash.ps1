Function Get-RecipientDNHash {
    <#
    .SYNOPSIS

    .EXAMPLE

    #>
    param (

    )
    Begin {
        $RecipientDNHash = @{ }
    }

    Process {
        $RecipientDNHash[$_.DistinguishedName] = @{
            Name               = $_.Name
            PrimarySMTPAddress = $_.PrimarySMTPAddress
        }
    }
    End {
        $RecipientDNHash
    }
}
