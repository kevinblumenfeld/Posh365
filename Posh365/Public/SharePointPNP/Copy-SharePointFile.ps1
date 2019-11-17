function Copy-SharePointFile {
    [CmdletBinding(DefaultParameterSetName = 'None')]
    <#
   .SYNOPSIS
   Copies a file from SharePoint to specified location

   .DESCRIPTION
   Copies a file from SharePoint to specified location

   .PARAMETER SharePointURL
   SharePoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

   .PARAMETER SPFile
   File name to copy that is found on SharePoint

   .PARAMETER Path
   Local path to save the file. Defaults to user temp location ($Env:TEMP)

   .PARAMETER AsGuid
   Copies the file with the file name of a random GUID

   .PARAMETER NewName
   Copies the file with the new name you choose

   .EXAMPLE
   An example

   .NOTES
   General notes
   #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SPFile,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = $Env:TEMP,

        [Parameter(ParameterSetName = 'AsGuid')]
        [switch]
        $AsGuid,

        [Parameter(ParameterSetName = 'NewName')]
        [string]
        $NewName
    )
    end {
        Connect-SharePointPNP -Url $SharePointURL
        $TrimmedSPFile = ($SPFile).TrimStart('/')
        $FileURL = "Shared Documents/{0}" -f $TrimmedSPFile
        switch ($PSCmdlet.ParameterSetName) {
            'AsGuid' {
                $NewFileName = '{0}.xlsx' -f [guid]::NewGuid().GUID
            }
            'NewName' {
                $NewFileName = $NewName
            }
            'None' {
                $NewFileName = $TrimmedSPFile
            }
        }
        $TempExcelPath = Join-Path -Path $Path $NewFileName
        try {
            Get-PnPFile -Url $FileURL -Path $Path -Filename $NewFileName -AsFile -Force -ErrorAction Stop
            $TempExcelPath
        }
        catch {
            Write-Host "Error getting file from SharePoint"
            $_
        }
    }
}

