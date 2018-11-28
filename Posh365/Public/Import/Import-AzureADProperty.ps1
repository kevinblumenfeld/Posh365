function Import-AzureADProperty { 
    <#
    .SYNOPSIS
    Import AzureADUser properties to Office 365 cloud-only accounts

    .DESCRIPTION
    Import AzureADUser properties to Office 365 cloud-only accounts

    .PARAMETER User
    Used to take input via pipeline or as a runtime parameter

    .EXAMPLE
    Import-Csv ".\Users.csv" | Import-AzureADProperty -LogPath "C:\Scripts\" -Verbose

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

        $Stamp = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $LogPath ('Error_Log' + $Stamp + ".csv")

    }
    process {
        ForEach ($CurUser in $User) {

            $Upn = $CurUser.UserPrincipalName

            $Splat = @{
                ObjectID        = $CurUser.UserPrincipalName
                JobTitle        = $CurUser.Title
                Mobile          = $CurUser.MobilePhone
                TelephoneNumber = $CurUser.PhoneNumber
                StreetAddress   = $CurUser.StreetAddress
                City            = $CurUser.City
                State           = $CurUser.State
                PostalCode      = $CurUser.PostalCode

            }
            Try {

                Set-AzureAdUser @Splat -ErrorAction Stop
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