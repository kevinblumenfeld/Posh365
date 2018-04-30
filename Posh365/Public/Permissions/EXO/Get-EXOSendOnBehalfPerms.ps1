function Get-EXOSendOnBehalfPerms {
    <#
    .SYNOPSIS
    Outputs Send On Behalf permissions for each object that has permissions assigned.
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
        [hashtable] $RecipientHash,

        [parameter()]
        [hashtable] $RecipientDNHash
    )
    Begin {
        

    }
    Process {
        $SendOB = $_
        Write-Verbose "Inspecting: `t $_"
        (Get-Mailbox $_ -erroraction silentlycontinue).GrantSendOnBehalfTo | where-object {$_ -ne $null} | ForEach-Object {
            $CurGranted = $_
            $Type = $null
            Write-Verbose "Has Send On Behalf: `t $CurGranted"
            if ($RecipientMailHash.ContainsKey($_)) {
                $CurGranted = $RecipientMailHash[$_].Name
                $Type = $RecipientMailHash[$_].RecipientTypeDetails
            }
            $Email = $_
            if ($RecipientHash.ContainsKey($_)) {
                $Email = $RecipientHash[$_].PrimarySMTPAddress
                $Type = $RecipientHash[$_].RecipientTypeDetails
            }
            [pscustomobject]@{
                Object               = $RecipientDNHash[$SendOB].Name
                ObjectPrimarySMTP    = $RecipientDNHash[$SendOB].PrimarySMTPAddress
                Granted              = $CurGranted
                GrantedPrimarySMTP   = $Email
                RecipientTypeDetails = $Type          
                Permission           = "SendOnBehalf"
            }  
        }
    }
    END {
        
    }
}
