function Invoke-SetMailboxMoveAddressBookPolicy {
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
        $MailboxCSV
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat | Where-Object { $_.AddressBookPolicy }
            }
            'CSV' {
                $CSVSplat = @{
                    MailboxCSV = $MailboxCSV
                }
                $UserChoice = Import-MailboxCsvDecision @CSVSplat | Where-Object { $_.AddressBookPolicy }
            }
        }
        if ($UserChoice -ne 'Quit' ) {
            foreach ($User in $UserChoice) {
                $SetSplat = @{
                    warningaction     = 'silentlycontinue'
                    ErrorAction       = 'Stop'
                    Identity          = $User.UserPrincipalName
                    AddressBookPolicy = $User.AddressBookPolicy
                }
                try {
                    Set-Mailbox @SetSplat
                    [PSCustomObject]@{
                        DisplayName       = $User.DisplayName
                        Result            = 'SUCCESS'
                        Identity          = $User.UserPrincipalName
                        AddressBookPolicy = $User.AddressBookPolicy
                        Log               = 'SUCCESS'
                        Action            = 'SET'
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName       = $User.DisplayName
                        Result            = 'FAILED'
                        Identity          = $User.UserPrincipalName
                        AddressBookPolicy = $User.AddressBookPolicy
                        Log               = $_.Exception.Message
                        Action            = 'SET'
                    }
                }
            }
        }
    }
}
