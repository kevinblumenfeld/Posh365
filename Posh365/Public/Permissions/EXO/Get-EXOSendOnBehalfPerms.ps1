function Get-EXOSendOnBehalfPerms {
    <#
    .SYNOPSIS
    Outputs Send On Behalf permissions for each mailbox that has permissions assigned.
    This is for Office 365
    
    .EXAMPLE
    
    (Get-Mailbox -ResultSize unlimited | Select -expandproperty distinguishedname) | Get-EXOSendOnBehalfPerms | Export-csv .\SendOB.csv -NoTypeInformation
    
    #>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        $DistinguishedName,

        [parameter()]
        [hashtable] $RecipientMailHash,

        [parameter()]
        [hashtable] $RecipientHash

    )
    Begin {
        

    }
    Process {
        $SendOB = $_
        (Get-Mailbox $_ -erroraction silentlycontinue).GrantSendOnBehalfTo | where-object {$_ -ne $null} | ForEach-Object {
            $NameSendOB = $_
            if ($RecipientMailHash.ContainsKey($_)) {
                $NameSendOB = $RecipientMailHash[$_].Name
                $Type = $RecipientMailHash[$_].RecipientTypeDetails
            }
            $Email = $_
            if ($RecipientHash.ContainsKey($_)) {
                $Email = $RecipientHash[$_].PrimarySMTPAddress
                $Type = $RecipientHash[$_].RecipientTypeDetails
            }
            [pscustomobject]@{
                Mailbox              = $SendOB
                MailboxPrimarySMTP   = $RecipientHash[$SendOB].PrimarySMTPAddress
                Granted              = $NameSendOB
                GrantedPrimarySMTP   = $Email
                RecipientTypeDetails = $Type          
                Permission           = "SendOnBehalf"
            }  
        }
    }
    END {
        
    }
}
