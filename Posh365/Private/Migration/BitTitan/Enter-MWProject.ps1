function Enter-MWProject {
    [CmdletBinding()]
    Param
    (

    )
    end {
        $Select = @(
            'Name', 'ProjectType', 'ExportType', 'ImportType', 'AdvancedOptions', 'FolderFilter', 'Id', 'OrganizationId'
        )
        $Script:MWProject = Get-MWMailboxConnector | Select-Object $Select | Sort-Object -Property Name | Out-GridView -Title "Choose the MigrationWiz project you wish to work with" -OutputMode Single
        if ($MWProject) {
            Write-Host "MigrationWiz Project: $($MWProject.Name)" -ForegroundColor Magenta
            $host.ui.RawUI.WindowTitle = "MigrationWiz Project: *** $($MWProject.Name) ***"
        }
        else {
            Write-Host "Please run the command again and choose a customer" -ForegroundColor Red
        }
    }
}
