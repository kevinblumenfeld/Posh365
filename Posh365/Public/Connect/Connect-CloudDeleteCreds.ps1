function Connect-CloudDeleteCreds {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [parameter(Mandatory)]
        [string]
        $Tenant,

        [parameter(Mandatory)]
        [string]
        $CredFile
    )
    end {
        try {
            Remove-Item $CredFile -ErrorAction Stop
        }
        catch {
            Write-Warning "While the attempt to delete credentials failed, this may be normal. Please try to connect again."
        }
        try {
            Remove-Item $CredFile -ErrorAction Stop
        }
        catch {
            $_.Exception.Message
        }
    }
}
