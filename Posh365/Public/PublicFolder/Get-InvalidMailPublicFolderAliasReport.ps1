function Get-InvalidMailPublicFolderAliasReport {
    <#
    .SYNOPSIS
    Export Report of Mail-Enabled Public Folders with Spaces

    .DESCRIPTION
    Export Report of Mail-Enabled Public Folders with Spaces

    .EXAMPLE
    Get-InvalidMailPublicFolderAliasReport | Export-Csv .\MailPFAliasReport.csv -notypeinformation -Encoding UTF8
    # Not needed didnt change primary even with EAP enabled: Get-MailPublicFolder -ResultSize unlimited | Set-MailPublicFolder -EmailAddressPolicyEnabled:$False

    $PFList = Import-Csv .\MailPFAliasReport3.csv
    foreach ($PF in $PFList) {write-host "PF `t $($PF.Displayname)" ;Set-MailPublicFolder -Identity $PF.guid -Alias $PF.NewAlias  }

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
            $_.alias -match '[\s,]+|^\.+|\.+$'
        }
        foreach ($Folder in $FolderList) {

            $NewAlias = ($Folder.WindowsEmailAddress -split '@')[0] -replace '\s|,|\.'

            if ($NewAlias.Length -gt 31) {
                $NewAlias = $NewAlias.Substring(0, 31)
            }
            Write-Host "Old Alias:`t$($Folder.Alias)" -ForegroundColor "Cyan"
            Write-Host "New Alias:`t$NewAlias" -ForegroundColor "Green"
            Write-Host ""
            Write-Host ""
            $CorrectedPF = New-Object -TypeName PSObject -Property @{
                Name                      = $Folder.Name
                OldAlias                  = $Folder.Alias
                NewAlias                  = $NewAlias
                DisplayName               = $Folder.DisplayName
                Identity                  = $Folder.Identity
                WindowsEmailAddress       = $Folder.WindowsEmailAddress
                Guid                      = $Folder.Guid
                PrimarySmtpAddress        = $Folder.PrimarySmtpAddress
                EmailAddressPolicyEnabled = $Folder.EmailAddressPolicyEnabled
                WhenCreated               = $Folder.WhenCreated
                WhenChanged               = $Folder.WhenChanged

            }
            $CorrectedPF | Select-Object Name, OldAlias, NewAlias, DisplayName, Identity, WindowsEmailAddress, Guid, PrimarySmtpAddress, EmailAddressPolicyEnabled, WhenCreated, WhenChanged
        }
    }

}
