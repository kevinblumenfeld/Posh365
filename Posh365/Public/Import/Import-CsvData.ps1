function Import-CsvData { 
    <#
    
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (

        [Parameter()]
        [Switch]$LogOnly,

        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Group", "Object")]
        [String]$UserGroupOrObject,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Add", "Remove", "Replace")]
        [String]$AddRemoveOrReplace,

        [Parameter(Mandatory = $true)]
        [ValidateSet("ProxyAddresses", "UserPrincipalName", "Mail")]
        [String]$Attribute,

        [Parameter(Mandatory = $true)]
        [ValidateSet("objectGUID", "Mail", "UserPrincipalName", "DisplayName")]
        [String]$FindADUserGroupOrObjectBy,

        [Parameter(Mandatory = $true)]
        [ValidateSet("EmailAddress", "AddressOrMember", "PrimarySmtpAddress", "ProxyAddresses", "EmailAddresses", "x500", "Joined")]
        [String]$FindInColumn,

        [Parameter()]
        [Switch]$FirstClearAllProxyAddresses,

        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $Row,
        
        [Parameter()]
        [string]$Domain,

        [Parameter()]
        [string]$NewDomain

    )
    Begin {
        if ($Domain -and (! $NewDomain)) {
            Write-Warning "Must use NewDomain parameter when specifying Domain parameter"
            break
        }
        if ($NewDomain -and (! $Domain)) {
            Write-Warning "Must use Domain parameter when specifying NewDomain parameter"
            break
        }
        if (-not $LogOnly) {
            Import-Module ActiveDirectory -Verbose:$False
        }
        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-WhatIf_Import.csv")
        $ErrorLog = Join-Path $OutputPath ($LogFileName + "-ImportCsvData-Error_Log.csv")
        if ($UserGroupOrObject -eq "Group" -and $FindADUserGroupOrObjectBy -eq "UserPrincipalName") {
            Write-Warning "AD Groups do not have UserPrincipalNames"
            Write-Warning "Please choose another option like ObjectGuid, Mail or DisplayName for parameter, FindADUserGroupOrObjectBy"
        }
    }
    Process {
        ForEach ($CurRow in $Row) {
            $Address = $CurRow."$FindInColumn"
            $Display = $CurRow.DisplayName
            $Mail = $CurRow.PrimarySmtpAddress
            $UPN = $CurRow.PrimarySmtpAddress
            $ObjectGUID = $CurRow.ObjectGUID
            if (-not $LogOnly) {
                try {
                    if ([String]::IsNullOrWhiteSpace($Address)) {
                        [PSCustomObject]@{
                            DisplayName = $Display
                            Error       = 'Address is not set'
                            Address     = $Address
                            Mail        = $Mail
                            UPN         = $PrimarySmtpAddress
                            ObjectGUID  = $ObjectGUID
                        } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                    }
                    else {
                        $errorActionPreference = 'Stop'
    
                        $filter = switch ($FindADUserGroupOrObjectBy) {
                            objectGUID {
                                if ([String]::IsNullOrWhiteSpace($ObjectGUID)) {
                                    throw 'Invalid ObjectGUID'
                                }
                                else {
                                    { ObjectGUID -eq $ObjectGUID }
                                }
                                break
                            }
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
                        $adObject = & "Get-AD$UserGroupOrObject" -Filter $filter -Properties proxyAddresses, mail, objectGUID
                        if (-not $adObject) {
                            throw "Failed to find the $UserGroupOrObject"
                            
                        }
                        # Clear proxy addresses
                        if ($FirstClearAllProxyAddresses) {
                            Write-Verbose "$Display `t Cleared ProxyAddresses"
                            $adObject | & "Set-AD$UserGroupOrObject" -Clear ProxyAddresses
                        }

                        if ($Domain) {
                            $Address = $Address | ForEach-Object {
                                $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                            }
                        }
                        foreach ($CurAddressItem in $address) {
                            $splat = @{ $AddRemoveOrReplace = @{ $Attribute = $CurAddressItem } }
                            Write-Verbose "$Display $AddRemoveOrReplace $Attribute $CurAddressItem"
                            $adObject | & "Set-AD$UserGroupOrObject" @splat
                        }
                    }
                }
                catch {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        Attribute   = $Attribute
                        Error       = $_
                        Address     = $Address
                        Mail        = $Mail
                        UPN         = $PrimarySmtpAddress
                        ObjectGUID  = $ObjectGUID
                    } | Export-Csv $ErrorLog -Append -NoTypeInformation -Encoding UTF8
                }
            }
            else {
                if ($Address) {
                    [PSCustomObject]@{
                        DisplayName = $Display
                        Attribute   = $Attribute
                        Address     = $Address
                        Mail        = $Mail
                        UPN         = $PrimarySmtpAddress
                        ObjectGUID  = $ObjectGUID
                    } | Export-Csv $Log -Append -NoTypeInformation -Encoding UTF8
                }
            }
        }
    }
    End {

    }
}
