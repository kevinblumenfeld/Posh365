function Import-MsolProperty { 
    <#
    .SYNOPSIS
    Import MsolUser properties to Office 365 cloud-only accounts

    .DESCRIPTION
    Import MsolUser properties to Office 365 cloud-only accounts

    .PARAMETER User
    Used to take input via pipeline or as a runtime parameter

    .EXAMPLE
    Import-Csv ".\Users.csv" | Import-MsolProperty -LogPath "C:\Scripts\" -Verbose

    .NOTES

    #>
    [CmdletBinding()]
    param (
        
        [Parameter(ValueFromPipeline, Mandatory)]
        [psobject] $User,

        [Parameter(Mandatory)]
        [string] $LogPath

    )
    begin {
        Import-Csv ".\Users.csv" | Import-MsolProperty -LogPath "C:\Scripts\"  -Verbose
        $Stamp = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $LogPath ('Error_Log' + $Stamp + ".csv")

    }
    process {
        ForEach ($CurUser in $User) {

            $Upn = $CurUser.UserPrincipalName

            $Splat = @{
                UserPrincipalName = $CurUser.UserPrincipalName
                Title             = $CurUser.Title
                MobilePhone       = $CurUser.MobilePhone
                PhoneNumber       = $CurUser.PhoneNumber
                StreetAddress     = $CurUser.StreetAddress
                City              = $CurUser.City
                State             = $CurUser.State
                PostalCode        = $CurUser.PostalCode

            }
            Try {

                Set-MsolUser @Splat -ErrorAction Stop
                Write-Verbose "Successfully Set:`t$Upn"

            }
            Catch {

                $ErrorMessage = $_.exception.message
                Add-Content -Path $Log -Value ($Upn + "," + $ErrorMessage)
                Write-Verbose "Error Logged for:`t$Upn"
                Write-Error $ErrorMessage

            }

        }     
    }   
    end {

    }
}