function Get-MailboxMoveLicense {
    [CmdletBinding(DefaultParameterSetName = 'PlaceHolder')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(ParameterSetName = 'SharePoint')]
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $ExportToExcel,

        [Parameter(ParameterSetName = 'SharePoint')]
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $IncludeRecipientType,

        [Parameter(ParameterSetName = 'SharePoint')]
        [Parameter(ParameterSetName = 'All')]
        [switch]
        $OneSkuPerLine
    )
    if ($ExportToExcel) {
        $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath Posh365 )

        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
            Path        = $PoshPath
        }
        $null = New-Item @ItemSplat

        $ExcelSplat = @{
            Path                    = (Join-Path -Path $PoshPath -ChildPath ('Licenses_{0}.xlsx' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm')))
            TableStyle              = 'Medium2'
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $false
            ClearSheet              = $true
            ErrorAction             = 'SilentlyContinue'
        }
    }
    if ($PSCmdlet.ParameterSetName -eq 'SharePoint') {
        $SharePointSplat = @{
            SharePointURL = $SharePointURL
            ExcelFile     = $ExcelFile
        }
        $UserChoice = Import-SharePointExcelDecision @SharePointSplat
        $Splat = @{
            OnePerLine           = $OneSkuPerLine
            IncludeRecipientType = $IncludeRecipientType
            SharePoint           = $true
            UserChoice           = $UserChoice
        }
        if ($ExportToExcel) {
            Write-Host 'Creating Excel file . . . ' -ForegroundColor Cyan
            Invoke-GetMailboxMoveLicenseUserSku @Splat | Export-Excel @ExcelSplat
            Write-Host 'Excel file saved in the folder Posh365, on the Desktop' -ForegroundColor Green
        }
        else {
            Invoke-GetMailboxMoveLicenseUserSku @Splat | Out-GridView -Title 'Licensing for users chosen'
        }

    }
    else {
        $UserChoice = Get-AzureADUser -filter "UserType eq 'Member'" -All:$true
        $Splat = @{
            OnePerLine           = $OneSkuPerLine
            IncludeRecipientType = $IncludeRecipientType
            All                  = $true
            UserChoice           = $UserChoice
        }
        if ($ExportToExcel) {
            Write-Host 'Creating Excel file . . . ' -ForegroundColor Cyan
            Invoke-GetMailboxMoveLicenseUserSku @Splat | Export-Excel @ExcelSplat
            Write-Host 'Excel file saved in the folder Posh365, on the Desktop' -ForegroundColor Green
        }
        else {
            Invoke-GetMailboxMoveLicenseUserSku @Splat | Out-GridView -Title 'Licensing for all users'
        }
    }
}
