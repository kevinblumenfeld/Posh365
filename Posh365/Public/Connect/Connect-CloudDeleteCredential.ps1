function Connect-CloudDeleteCredential {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]
        $CredFile
    )
    end {
        try {
            Remove-Item $CredFile -force -ErrorAction Stop
        }
        catch {
            $_.Exception.Message
        }
    }
}
