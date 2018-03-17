Function Get-RecipientNameHash {
    <#
    .SYNOPSIS
    
    .EXAMPLE
    
    #>
    param (        

    )
    Begin {
        $RecipientNameHash = @{}
    }

    Process {
        $RecipientNameHash[$_.Name] = $_.PrimarySMTPAddress
    }
    End {
        $RecipientNameHash
    }
}