function Import-CsvData { 
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER LogOnly
    Parameter description
    
    .PARAMETER UserOrGroup
    Parameter description
    
    .PARAMETER FindADUserOrGroupBy
    Parameter description
    
    .PARAMETER FindAddressInColumn
    Parameter description
    
    .PARAMETER FirstClearAllProxyAddresses
    Parameter description
    
    .PARAMETER Row
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
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
                                    throw 'Invalid DisplayName'
                                }
                                else {
                                    { displayName -eq $Display }
                                }
                                break
                            }
                            Mail {
                                if ([String]::IsNullOrWhiteSpace($Mail)) {
                                    throw 'Invalid Mail'
                                }
                                else {
                                    { mail -eq $Mail }
                                }
                                break
                            }
                            UserPrincipalName {
                                if ([String]::IsNullOrWhiteSpace($UPN)) {
                                    throw 'Invalid UserPrincipalName'
                                }
                                else {
                                    { userprincipalname -eq $UPN }
                                }
                                break
                            }
                        }
                        $adObject = & "Get-AD$UserOrGroup" -Filter $filter -Properties proxyAddresses, mail, objectGUID
                        # Clear proxy addresses
                        if ($FirstClearAllProxyAddresses) {
                            Write-Verbose "$Display `t Cleared ProxyAddresses"
                            $adObject | & "Set-AD$UserOrGroup" -Clear ProxyAddresses
                        }
                        
                        $params = @{}
        
                        if ($params.Count -gt 0) {
                            $adObject | & "Set-AD$UserOrGroup" @params
                        }
    
                        $Address | ForEach-Object {
                            $adObject | & "Set-AD$UserOrGroup" -Add @{ProxyAddresses = "$_"}
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
