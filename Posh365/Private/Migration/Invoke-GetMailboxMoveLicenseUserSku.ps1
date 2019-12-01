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
        $OnePerLine,

        [switch]
        $IncludeRecipientType
    )
    end {
        if ($IncludeRecipientType) {
            Invoke-GetMailboxMoveLicenseUserSkuWithType @PSBoundParameters
            return
        }
        $PlanList = Get-AzureADSubscribedSku
        $SkuHash = @{ }
        $PlanList | ForEach-Object {
            $SkuHash[($_.ObjectId).substring($_.ObjectId.length - 36, 36)] = $_.SkuPartNumber }
        $U2FSku = Get-UglyToFriendlySkuHash
        switch ($true) {
            $SharePoint {
                if ($UserChoice -ne 'Quit' ) {
                    if (-not $OnePerLine) {
                        foreach ($User in $UserChoice) {
                            if ($SkuList = (Get-AzureADUser -Filter "UserPrincipalName eq '$($User.UserPrincipalName)'").AssignedLicenses.SkuID) {
                                [PSCustomObject]@{
                                    DisplayName        = $User.DisplayName
                                    PrimarySmtpAddress = $User.PrimarySmtpAddress
                                    UserPrincipalName  = $User.UserPrincipalName
                                    Sku                = @(@($SkuList) -ne '' | ForEach-Object { $SkuGuid = ($_).ToString()
                                            if ($USku = $U2FSku[$SkuHash[$SkuGuid]]) { $USku } else { $SkuHash[$SkuGuid] } }) -ne '' -join '|'
                                }
                            }
                            else {
                                [PSCustomObject]@{
                                    DisplayName        = $User.DisplayName
                                    PrimarySmtpAddress = $User.PrimarySmtpAddress
                                    UserPrincipalName  = $User.UserPrincipalName
                                    Sku                = 'UNLICENSED'
                                }
                            }
                        }
                    }
                    else {
                        foreach ($User in $UserChoice) {
                            if ($SkuList = (Get-AzureADUser -Filter "UserPrincipalName eq '$($User.UserPrincipalName)'").AssignedLicenses.SkuID) {
                                foreach ($Sku in $SkuList) {
                                    [PSCustomObject]@{
                                        DisplayName        = $User.DisplayName
                                        PrimarySmtpAddress = $User.PrimarySmtpAddress
                                        UserPrincipalName  = $User.UserPrincipalName
                                        Sku                = if ($USku = $U2FSku[$SkuHash[$Sku]]) { $USku } else { $SkuHash[$Sku] }
                                    }
                                }
                            }
                            else {
                                [PSCustomObject]@{
                                    DisplayName        = $User.DisplayName
                                    PrimarySmtpAddress = $User.PrimarySmtpAddress
                                    UserPrincipalName  = $User.UserPrincipalName
                                    Sku                = 'UNLICENSED'
                                }
                            }
                        }
                    }
                }
            }
            $All {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        if ($User.AssignedLicenses.SkuID) {
                            foreach ($Sku in $User.AssignedLicenses.SkuID) {
                                [PSCustomObject]@{
                                    DisplayName        = $User.DisplayName
                                    PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                                    UserPrincipalName  = $User.UserPrincipalName
                                    Sku                = if ($USku = $U2FSku[$SkuHash[$Sku]]) { $USku } else { $SkuHash[$Sku] }
                                }
                            }
                        }
                        else {
                            [PSCustomObject]@{
                                DisplayName        = $User.DisplayName
                                PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                                UserPrincipalName  = $User.UserPrincipalName
                                Sku                = 'UNLICENSED'
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
                            Sku                = @(@($User.AssignedLicenses -ne '') | ForEach-Object {
                                    if ($USku = $U2FSku[$SkuHash[$_.SkuID]]) { $USku } else { $SkuHash[$_.SkuID] } }) -ne '' -join '|'
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
                                Sku                = if ($USku = $U2FSku[$SkuHash[$Sku]]) { $USku } else { $SkuHash[$Sku] }
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
                            Sku                = @(@($User.AssignedLicenses -ne '') | ForEach-Object {
                                    if ($USku = $U2FSku[$SkuHash[$_.SkuID]]) { $USku } else { $SkuHash[$_.SkuID] } }) -ne '' -join '|'
                        }
                    }
                }
            }
            $SearchString {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        if ($User.AssignedLicenses.SkuID) {
                            foreach ($Sku in $User.AssignedLicenses.SkuID) {
                                [PSCustomObject]@{
                                    DisplayName        = $User.DisplayName
                                    PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                                    UserPrincipalName  = $User.UserPrincipalName
                                    Sku                = if ($USku = $U2FSku[$SkuHash[$Sku]]) { $USku } else { $SkuHash[$Sku] }
                                }
                            }
                        }
                        else {
                            [PSCustomObject]@{
                                DisplayName        = $User.DisplayName
                                PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value
                                UserPrincipalName  = $User.UserPrincipalName
                                Sku                = 'UNLICENSED'
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
                            Sku                = @(@($User.AssignedLicenses -ne '') | ForEach-Object {
                                    if ($USku = $U2FSku[$SkuHash[$_.SkuID]]) { $USku } else { $SkuHash[$_.SkuID] } }) -ne '' -join '|'
                        }
                    }
                }
            }
        }
    }
}
