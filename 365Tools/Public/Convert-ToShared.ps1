Function Convert-ToShared {
    <#
    .SYNOPSIS

    .EXAMPLE

    .EXAMPLE
   
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]] $UserPrincipalName
    )
    
    Begin {
        [string[]]$skusToRemove = Get-CloudSku
    }
    Process {
        $user = Get-AzureADUser -ObjectId $_
        $userLicense = Get-AzureADUserLicenseDetail -ObjectId $_
        if ($skusToRemove) {
            Foreach ($removeSku in $skusToRemove) {
                if ($f2uSku.$removeSku) {
                    if ($f2uSku.$removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $removeSkuGroup += $f2uSku.$removeSku 
                    } 
                }
                else {
                    if ($removeSku -in (Get-AzureADUserLicenseDetail -ObjectId $_).skupartnumber) {
                        $removeSkuGroup += $removeSku 
                    } 
                }
            }
            if ($removeSkuGroup) {
                Write-Output "$($_) has the following Skus, removing these Sku now: $removeSkuGroup "
                $licensesToAssign = Set-SkuChange -remove -skus $removeSkuGroup
                Set-AzureADUserLicense -ObjectId $user.ObjectId -AssignedLicenses $licensesToAssign
            }
            Else {
                Write-Output "$($_) does not have any of the Skus requested for removal"
            }
        }

    }

    End {
    
    }
}    
