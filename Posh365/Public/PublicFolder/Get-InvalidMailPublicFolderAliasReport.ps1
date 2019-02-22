function Get-InvalidMailPublicFolderAliasReport {
    <#
    .SYNOPSIS
    Export Report of Mail-Enabled Public Folders with Spaces

    .DESCRIPTION
    Export Report of Mail-Enabled Public Folders with Spaces

    .EXAMPLE
    Get-InvalidMailPublicFolderAliasReport | Export-Csv .\MailPFAliasReport.csv -notypeinformation -Encoding UTF8

    .NOTES
    General notes
    #>


    [CmdletBinding()]
    param (

    )

    $PFDBList = Get-PublicFolderDatabase
    ForEach ($PFDB in $PFDBList)	{
        Write-Host "INFO: Checking against... $($PFDB.Server)"
        $FolderList = Get-MailPublicFolder -ResultSize Unlimited -Server $PFDB.Server | Where-Object {
            $_.alias -match '\s'
        }
        foreach ($Folder in $FolderList) {

            $NewAlias = ($Folder.WindowsEmailAddress -split '@')[0] -replace '\s|,|\.|\-'

            if ($NewAlias.Length -gt 31) {
                $NewAlias = $NewAlias.Substring(0, 31)
            }
            Write-Host "Old Alias:`t$($Folder.Alias)" -ForegroundColor "Cyan"
            Write-Host "New Alias:`t$NewAlias" -ForegroundColor "Green"
            Write-Host ""
            Write-Host ""
            $CorrectedPF = New-Object -TypeName PSObject -Property @{
                Name                = $Folder.Name
                OldAlias            = $Folder.Alias
                NewAlias            = $NewAlias
                DisplayName         = $Folder.DisplayName
                Identity            = $Folder.Identity
                WindowsEmailAddress = $Folder.WindowsEmailAddress
                Guid                = $Folder.Guid
                WhenCreated         = $Folder.WhenCreated
                WhenChanged         = $Folder.WhenChanged
            }
            $CorrectedPF | Select Name, OldAlias, NewAlias, DisplayName, Identity, WindowsEmailAddress, Guid, WhenCreated, WhenChanged
        }
    }

}




