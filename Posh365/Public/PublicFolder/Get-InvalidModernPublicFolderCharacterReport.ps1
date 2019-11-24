function Get-InvalidModernPublicFolderCharacterReport {
    <#
    .SYNOPSIS
    Export Report of Public Folders with Invalid Characters

    .DESCRIPTION
    Export Report of Public Folders with Invalid Characters

    .EXAMPLE
    Import-Csv .\PublicFolders.csv | Get-InvalidModernPublicFolderCharacterReport | Export-PoshExcel .\PFBadCharReport.xlsx

    .EXAMPLE
    Import-Excel .\PublicFolders.xlsx | Get-InvalidModernPublicFolderCharacterReport | Export-Csv .\PFBadCharReport.csv -notypeinformation

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $PublicFolderList
    )
    begin {
        $BadNamePFList = [System.Collections.Generic.List[PSObject]]::New()
    }
    process {
        foreach ($Folder in $PublicFolderList) {
            if ($Folder.FolderName.ToString() -like '*\*' -or
                $Folder.FolderName.ToString() -like "*/*" -or
                $Folder.FolderName.ToString() -like '*<*' -or
                $Folder.FolderName.ToString() -like '*>*' -or
                $Folder.FolderName.ToString() -match '\u2013' -or
                $Folder.FolderName.ToString() -like '*_-*' -or
                $Folder.FolderName.ToString() -like ' *' -or
                $Folder.FolderName.ToString() -like '* ') {
                Write-Warning "FOUND INVALID CHARACTER(S)... $($Folder.FolderName)"
                $BadNamePFList.Add($Folder)
            }
        }
    }
    end {
        Write-Host "Number of PFs with Offending Characters: " -NoNewline -ForegroundColor Cyan
        Write-Host "$($BadNamePFList.count)" -ForegroundColor Red
        foreach ($BadNamePF in $BadNamePFList) {
            $OffendingChar = [System.Collections.Generic.List[string]]::New()
            if ($BadNamePF.FolderName -like "*\*") {
                $OffendingChar.Add('\')
            }
            if ($BadNamePF.FolderName -like "*/*") {
                $OffendingChar.Add('/')
            }
            if ($BadNamePF.FolderName -like "*<*") {
                $OffendingChar.Add('<')
            }
            if ($BadNamePF.FolderName -like "*>*") {
                $OffendingChar.Add('>')
            }
            if ($BadNamePF.FolderName -like "*_-*") {
                $OffendingChar.Add('_-')
            }
            if ($BadNamePF.FolderName -match '\u2013') {
                $OffendingChar.Add('EnDash')
            }
            if ($BadNamePF.FolderName -like " *") {
                $OffendingChar.Add('Lead-Whitespace')
            }
            if ($BadNamePF.FolderName -like "* ") {
                $OffendingChar.Add('Trail-Whitespace')
            }
            $NewFolder = $BadNamePF.FolderName.Replace('\', '-')
            $NewFolder = $NewFolder.Replace('/', '-')
            $NewFolder = $NewFolder.Replace('<', '')
            $NewFolder = $NewFolder.Replace('>', '')
            $NewFolder = $NewFolder.Replace('_-', '-')
            $NewFolder = $NewFolder -replace '\u2013|\u2014', '-'

            Write-Host "Old Folder Name:`t$($BadNamePF.FolderName)" -ForegroundColor "Cyan"
            Write-Host "New Folder Name:`t$NewFolder" -ForegroundColor "Green"
            Write-Host ""
            [PSCustomObject]@{
                CurrentPFName     = $BadNamePF.FolderName
                RecommendedPFName = $NewFolder
                OffendingChar     = @($OffendingChar) -ne '' -join '|'
                MailEnabled       = $BadNamePF.MailEnabled
                Identity          = $BadNamePF.Identity
            }
        }
    }
}
