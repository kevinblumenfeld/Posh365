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
        [ValidateSet("Add", "Remove")]
        [String]$AddOrRemoveAddress,

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
                    if ([String]::IsNullOrWhiteSpace($Address)) {
                        [PSCustomObject]@{
                            DisplayName = $Display
                            Error       = 'Address is not set'
                            Address     = $Address
                            Mail        = $Mail
                            UPN         = $PrimarySmtpAddress
                        } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                    }
                    else {
                        $errorActionPreference = 'Stop'
    
                        $filter = switch ($FindADUserOrGroupBy) {
                            DisplayName {
                                if ([String]::IsNullOrWhiteSpace($Display)) {
                                    throw 'Invalid display name'
                                }
                                else {
                                    { displayName -eq $Display }
                                }
                                break
                            }
                            Mail {
                                if ([String]::IsNullOrWhiteSpace($Mail)) {
                                    throw 'Invalid mail'
                                }
                                else {
                                    { mail -eq $Mail }
                                }
                                break
                            }
                            UserPrincipalName {
                                if ([String]::IsNullOrWhiteSpace($UPN)) {
                                    throw 'Invalid user principal name'
                                }
                                else {
                                    { userprincipalname -eq $UPN }
                                }
                                break
                            }
                        }
                        $adObject = & "Get-AD$UserOrGroup" -Filter $filter -Properties proxyAddresses, mail, objectGUID
                        if (-not $adObject) {
                            throw "Failed to find the $UserOrGroup"
                            
                        }
                        # Clear proxy addresses
                        if ($FirstClearAllProxyAddresses) {
                            Write-Verbose "$Display `t Cleared ProxyAddresses"
                            $adObject | & "Set-AD$UserOrGroup" -Clear ProxyAddresses
                        }
                        
                        $params = @{}
        
                        if ($params.Count -gt 0) {
                            $adObject | & "Set-AD$UserOrGroup" @params
                        }
                        $splat = @{$AddOrRemoveAddress = @{ProxyAddresses = "$_"}}
                        $Address | ForEach-Object {
                            $adObject | & "Set-AD$UserOrGroup" @Splat
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
