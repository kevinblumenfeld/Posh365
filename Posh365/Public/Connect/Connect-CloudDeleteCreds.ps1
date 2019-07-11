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
        Try {
            Remove-Item $CredFile -ErrorAction Stop
        }
        Catch {
            Write-Warning "While the attempt to delete credentials failed, this may be normal. Please try to connect again."
        }
        Try {
            Remove-Item $CredFile -ErrorAction Stop
        }
        Catch {
            $_.Exception.Message
        }
    }
}
