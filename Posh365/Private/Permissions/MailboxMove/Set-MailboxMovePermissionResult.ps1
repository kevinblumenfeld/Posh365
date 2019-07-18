function Set-MailboxMovePermissionResult {
    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(Mandatory, ParameterSetName = 'CSV')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCSV,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL  = $SharePointURL
                    ExcelFile      = $ExcelFile
                    Tenant         = $Tenant
                    NoBatch        = $true
                    NoConfirmation = $true
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat
            }
            'CSV' {
                $UserChoice = Import-MailboxCsvDecision -MailboxCSV $MailboxCSV
            }
        }
        $UserChoiceRegex = ($UserChoice.UserPrincipalName | ForEach-Object { [Regex]::Escape($_) }) -join '|'
        $PermissionChoice = Get-PermissionDecision
        $DirectionChoice = Get-PermissionDirectionDecision

        $PermissionResult = @{
            SharePointURL    = $SharePointURL
            ExcelFile        = $ExcelFile
            Tenant           = $Tenant
            UserChoiceRegex  = $UserChoiceRegex
            PermissionChoice = $PermissionChoice
            DirectionChoice  = $DirectionChoice
        }
        Get-MailboxMovePermissionResult @PermissionResult | Out-GridView -Title "Permission Results" -OutputMode Multiple
    }
}
