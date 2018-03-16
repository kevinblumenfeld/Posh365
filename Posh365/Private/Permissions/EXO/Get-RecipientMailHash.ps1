Function Get-RecipientMailHash {
    <#
    .SYNOPSIS
    
    .EXAMPLE
    
    #>
    param (        

    )
    Begin {
        $RecipientMailHash = @{}
    }

    Process {
        $RecipientMailHash[$_.PrimarySMTPAddress] = @{
            Name   = $_.Name
            RecipientTypeDetails = $_.RecipientTypeDetails
        }
    }
    End {
        $RecipientMailHash
    }
}