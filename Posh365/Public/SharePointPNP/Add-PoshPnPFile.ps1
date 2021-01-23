function Add-PoshPnPFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ })]
        [string]
        $FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $SubURL
    )
    end {
        Connect-SharePointPNP -Url $SharePointURL
        $SPFolder = "Shared Documents/{0}" -f $SubURL
        try {
            Add-PnPFile -Path $FilePath -Folder $SPFolder -ErrorAction Stop
        }
        catch {
            Write-Host "Error getting file from SharePoint"
            $_
        }
    }
}
