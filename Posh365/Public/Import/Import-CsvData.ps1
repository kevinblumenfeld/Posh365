function Import-CsvData { 
    <#
    
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Group")]
        [String]$UserOrGroup,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Mail", "UserPrincipalName", "DisplayName")]
        [String]$FindADUserOrGroupBy,

        [Parameter(Mandatory = $true)]
        [ValidateSet("EmailAddress", "PrimarySmtpAddress", "ProxyAddresses", "EmailAddresses", "x500")]
        [String]$FindAddressInColumn,

        [Parameter()]
        [Switch]$FirstClearAllProxyAddresses,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row
    )
    Begin {
        Import-Module ActiveDirectory -Verbose:$False
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-Error_Log.csv")
        if ($UserOrGroup -eq "Group" -and $FindADUserOrGroupBy -eq "UserPrincipalName") {
            Write-Warning "AD Groups do not have UserPrincipalNames"
            Write-Warning "Please choose another option like Mail or DisplayName for parameter, FindADUserOrGroupBy"
        }
    }
    Process {
        ForEach ($CurRow in $Row) {
            $Address = $CurRow."$FindAddressInColumn"
            $Display = $CurRow.DisplayName
            $Mail = $CurRow.PrimarySmtpAddress
            $UPN = $CurRow.PrimarySmtpAddress
            if (-not $LogOnly) {
                try {
                    $errorActionPreference = 'Stop'
                    if ($UserOrGroup -eq "User" -and (-not [String]::IsNullOrWhiteSpace($Address))) {
                        switch ($FindADUserOrGroupBy) {
                            DisplayName {
                                $user = Get-ADUser -Filter { displayName -eq $Display } -Properties proxyAddresses, mail, objectGUID
                            }
                            Mail {
                                $user = Get-ADUser -Filter { mail -eq $Mail } -Properties proxyAddresses, mail, objectGUID
                            }
                            UserPrincipalName {
                                $user = Get-ADUser -Filter { UserPrincipalName -eq $UPN } -Properties proxyAddresses, mail, objectGUID
                            }
                        }
                        $ObjectGUID = $user.objectGUID

                        if ($FirstClearAllProxyAddresses) {
                            $user | Set-ADUser -clear ProxyAddresses
                            Write-Verbose "$Display `t Cleared ProxyAddresses"
                        }
    
                        $params = @{}

                        if ($params.Count -gt 0) {

                        }
    
                        $Address | ForEach-Object {
                            Set-ADUser -Identity $ObjectGUID -Add @{ProxyAddresses = "$_"}
                            Write-Verbose "$Display `t Set ProxyAddress $($_)"
                        }
                    }
                    elseif (-not [String]::IsNullOrWhiteSpace($Address)) {
                        switch ($FindADUserOrGroupBy) {
                            DisplayName {
                                $group = Get-ADGroup -Filter { displayName -eq $Display } -Properties proxyAddresses, mail, objectGUID
                            }
                            Mail {
                                $group = Get-ADGroup -Filter { mail -eq $Mail } -Properties proxyAddresses, mail, objectGUID
                            }
                        }
                        $ObjectGUID = $group.objectGUID

                        if ($FirstClearAllProxyAddresses) {
                            $group | Set-ADgroup -clear ProxyAddresses
                            Write-Verbose "$Display `t Cleared ProxyAddresses"
                        }
    
                        $params = @{}
    
                        if ($params.Count -gt 0) {
                            $group | Set-ADgroup @params
                        }
    
                        $Address | ForEach-Object {
                            Set-ADgroup -Identity $ObjectGUID -Add @{ProxyAddresses = "$_"}
                            Write-Verbose "$Display `t Set ProxyAddress $($_)"
                        }
                    } 

                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        Error       = $_
                        Address     = $Address
                        Mail        = $Mail
                        UPN         = $PrimarySmtpAddress
                    } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                if ($Address) {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        Address     = $Address
                        Mail        = $Mail
                        UPN         = $PrimarySmtpAddress
                    } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
                }
            }
        }
    }
    End {

    }
}
