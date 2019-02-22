function Get-InvalidPublicFolderCharacterReport {
    <#
    .SYNOPSIS
    Export Report of Public Folders with Invalid Characters

    .DESCRIPTION
    Export Report of Public Folders with Invalid Characters

    .PARAMETER ExcludedWord
    Don't look for this word in search for invalid characters

    .EXAMPLE
    Get-InvalidPublicFolderCharacterReport | Export-Csv .\PFcharReport.csv -notypeinformation -Encoding UTF8

    .NOTES
    General notes
    #>


    [CmdletBinding()]
    param (

    )

    $PFDBList = Get-PublicFolderDatabase
    $BadNamePFList = New-Object System.Collections.Generic.List[PSObject]
    ForEach ($PFDB in $PFDBList)	{
        Write-Host "INFO: Checking against... $($PFDB.Server)"
        $FolderList = Get-PublicFolderStatistics -ResultSize Unlimited -Server $PFDB.Server
        foreach ($Folder in $FolderList) {
            if ($Folder.Name -like '*\*' -or
                $Folder.Name -like "*/*" -or
                $Folder.Name -like '*<*' -or
                $Folder.Name -like '*>*' -or
                $Folder.Name -like '*–*' -or
                $Folder.Name -like '*_-*' -or
                $Folder.Name -like ' *' -or
                $Folder.Name -like '* ') {
                Write-Host "FOUND... $($Folder.Name)"
                $BadNamePFList.Add($Folder)
            }
        }
    }
    Write-Host "Number of PFs with Offending Characters: $($BadNamePFList.count)"
    foreach ($BadNamePF in $BadNamePFList) {
        $OffendingChar = New-Object System.Collections.Generic.List[string]
        if ($BadNamePF.Name -like "*\*") {
            $OffendingChar.Add('\')
        }
        if ($BadNamePF.Name -like "*/*") {
            $OffendingChar.Add('/')
        }
        if ($BadNamePF.Name -like "*<*") {
            $OffendingChar.Add('<')
        }
        if ($BadNamePF.Name -like "*>*") {
            $OffendingChar.Add('>')
        }
        if ($BadNamePF.Name -like "*_-*") {
            $OffendingChar.Add('_-')
        }
        if ($BadNamePF.Name -match '\u2013') {
            $OffendingChar.Add('EnDash')
        }
        if ($BadNamePF.Name -like " *") {
            $OffendingChar.Add('Lead-Whitespace')
        }
        if ($BadNamePF.Name -like "* ") {
            $OffendingChar.Add('Trail-Whitespace')
        }

        $NewFolder = $BadNamePF.Name.Replace('\', '-')
        $NewFolder = $NewFolder.Replace('/', '-')
        $NewFolder = $NewFolder.Replace('<', '')
        $NewFolder = $NewFolder.Replace('>', '')
        $NewFolder = $NewFolder.Replace('_-', '-')
        $NewFolder = $NewFolder -replace '\u2013|\u2014', '-'

        Write-Host "Old Folder Name:`t $($BadNamePF.Name)" -ForegroundColor "Cyan"
        Write-Host "New Folder Name:`t$NewFolder" -ForegroundColor "Green"
        Write-Host ""
        Write-Host ""


        $CorrectedPF = New-Object -TypeName PSObject -Property @{
            FolderPath    = $BadNamePF.FolderPath
            OldFolder     = $BadNamePF.Name
            NewFolder     = $NewFolder
            OffendingChar = $OffendingChar
            Database      = $BadNamePF.DatabaseName
            Identity      = $BadNamePF.Identity
            CreationTime  = $BadNamePF.CreationTime
        }
        $CorrectedPF | Select FolderPath, OldFolder, NewFolder, OffendingChar, Database, Identity, CreationTime
    }
}