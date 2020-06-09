function Get-EXODGSendOnBehalfPerms {
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline)]
        $Object,

        [parameter()]
        [hashtable] $RecipientMailHash,

        [parameter()]
        [hashtable] $RecipientNameHash,

        [parameter()]
        [hashtable] $RecipientHash,

        [parameter()]
        [hashtable] $RecipientDNHash
    )
    Begin {


    }
    Process {
        $SendOB = $_
        Write-Host "Inspecting: `t $_" -ForegroundColor Cyan
        (Get-DistributionGroup -Identity $_.PrimarySmtpAddress -Verbose:$false).GrantSendOnBehalfTo | where-object { $_ -ne $null } | ForEach-Object {
            $CurGranted = $_
            $Type = $null
            Write-Host "Has Send On Behalf: `t $CurGranted" -ForegroundColor White
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
                Object               = $SendOB.Identity
                PrimarySmtpAddress   = $RecipientNameHash[$SendOB.Identity]
                Granted              = $CurGranted
                GrantedSMTP          = $Email
                RecipientTypeDetails = $Type
                Permission           = "SendOnBehalf"
            }
        }
    }
    END {

    }
}
