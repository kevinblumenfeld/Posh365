function Invoke-GetMailboxMoveLicenseUserSku {
    [CmdletBinding()]
    param (
        [Parameter()]
        $UserChoice,

        [Parameter()]
        [switch]
        $SharePoint,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $All,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $AllLicensedOnly,

        [Parameter()]
        [switch]
        $SearchString,

        [switch]
        $OnePerLine
    )
    end {
        $PlanList = Get-AzureADSubscribedSku
        $SkuHash = @{ }
        $PlanList | ForEach-Object {
            $SkuHash[($_.ObjectId).substring($_.ObjectId.length - 36, 36)] = $_.SkuPartNumber }
        switch ($true) {
            $SharePoint {
                if ($UserChoice -ne 'Quit' ) {
                    if (-not $OnePerLine) {
                        foreach ($User in $UserChoice) {
                            $SkuList = (Get-AzureADUser -Filter "mail eq '$($User.PrimarySmtpAddress)' or UserPrincipalName eq '$($User.UserPrincipalName)'").AssignedLicenses.SkuID
                            [PSCustomObject]@{
                                DisplayName        = $User.DisplayName
                                PrimarySmtpAddress = $User.PrimarySmtpAddress
                                UserPrincipalName  = $User.UserPrincipalName
                                Sku                = @(($SkuList) -ne '' | ForEach-Object { $SkuHash[$_] }) -ne '' -join '|'
                            }
                        }
                    }
                    else {
                        foreach ($User in $UserChoice) {
                            $SkuList = (Get-AzureADUser -Filter "mail eq '$($User.PrimarySmtpAddress)' or UserPrincipalName eq '$($User.UserPrincipalName)'").AssignedLicenses.SkuID
                            foreach ($Sku in $SkuList) {
                                [PSCustomObject]@{
                                    DisplayName        = $User.DisplayName
                                    PrimarySmtpAddress = $User.PrimarySmtpAddress
                                    UserPrincipalName  = $User.UserPrincipalName
                                    Sku                = $SkuHash[$Sku]
                                }
                            }
                        }
                    }
                }
            }
            $All {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        foreach ($Sku in $User.AssignedLicenses.SkuID) {
                            [PSCustomObject]@{
                                DisplayName        = $User.DisplayName
                                PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                                UserPrincipalName  = $User.UserPrincipalName
                                Sku                = $SkuHash[$Sku]
                            }
                        }
                    }
                }
                else {
                    foreach ($User in $UserChoice) {
                        [PSCustomObject]@{
                            DisplayName        = $User.DisplayName
                            PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                            UserPrincipalName  = $User.UserPrincipalName
                            Sku                = @(@($User.AssignedLicenses.SkuID -ne '') | ForEach-Object { $SkuHash[$_] }) -ne '' -join '|'
                        }
                    }
                }
            }
            $AllLicensedOnly {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        foreach ($Sku in $User.AssignedLicenses.SkuID) {
                            [PSCustomObject]@{
                                DisplayName        = $User.DisplayName
                                PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                                UserPrincipalName  = $User.UserPrincipalName
                                Sku                = $SkuHash[$Sku]
                            }
                        }
                    }
                }
                else {
                    foreach ($User in $UserChoice) {
                        [PSCustomObject]@{
                            DisplayName        = $User.DisplayName
                            PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                            UserPrincipalName  = $User.UserPrincipalName
                            Sku                = @($User.AssignedLicenses.SkuID | ForEach-Object { $SkuHash[$_] }) -ne '' -join '|'
                        }
                    }
                }
            }
            $SearchString {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        foreach ($Sku in $User.AssignedLicenses.SkuID) {
                            [PSCustomObject]@{
                                DisplayName        = $User.DisplayName
                                PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                                UserPrincipalName  = $User.UserPrincipalName
                                Sku                = $SkuHash[$Sku]
                            }
                        }
                    }
                }
                else {
                    foreach ($User in $UserChoice) {
                        [PSCustomObject]@{
                            DisplayName        = $User.DisplayName
                            PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                            UserPrincipalName  = $User.UserPrincipalName
                            Sku                = @($User.AssignedLicenses.SkuID | ForEach-Object { $SkuHash[$_] }) -ne '' -join '|'
                        }
                    }
                }
            }
        }
    }
}
