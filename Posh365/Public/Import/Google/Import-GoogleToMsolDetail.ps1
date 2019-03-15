
function Import-GoogleToMsolDetail {
    <#
    .SYNOPSIS
    Import CSV of Google Data into MsolUser

    .DESCRIPTION
    Import CSV of Google Data into MsolUser

    .PARAMETER LogPath
    The full path and file name of the log ex. c:\scripts\AddMsolDetailsLog.csv (use .csv)

    .PARAMETER LogFileFromMailboxImport
    Required log file that was generated when adding cloud-only Mailboxes via Import-GoogleToSharedMailbox

    .PARAMETER DontImportProperties
    Choose which properties/headers of a CSV to not import.  All other properties will be imported.
    The default for this parameter is @('DisplayName', 'FirstName', 'LastName', 'PrimarySmtpAddress') and this is typically sufficient.

    .EXAMPLE
    Import-Csv .\GoogleMsolDetail.csv | Import-GoogleToMsolDetail -LogPath .\EXOSharedMbxResults.csv -LogFileFromMailboxImport .\AddSharedMbxLog.csv

    .EXAMPLE
    Import-Csv .\Shared-PhysicalAddress.csv | Import-GoogleToMsolDetail -LogFileFromMailboxImport .\SharedMailboxCreation.csv -LogPath .\AddDetail-PhysicalAddress-Log.csv

    .NOTES
    A hashtable is created during this script, it maps the PrimarySmtpAddress to the ObjectID.
    This is used to lookup the ObjectId when all we have is PrimarySmtpAddress.
    Get-MsolUser requires either ObjectId or UserprincipalName for exact matches.
    #>


    [CmdletBinding()]
    Param
    (

        [Parameter(Mandatory)]
        $LogPath,

        [Parameter(Mandatory)]
        $LogFileFromMailboxImport,

        [Parameter()]
        [string[]] $DontImportProperties = @('DisplayName', 'FirstName', 'LastName', 'PrimarySmtpAddress'),

        [Parameter(Mandatory, ValueFromPipeline)]
        $MsolDetail

    )
    Begin {
        $Hash = @{}
        Import-Csv $LogFileFromMailboxImport | ForEach-Object {
            if (-not $Hash.ContainsKey($_.PrimarySmtpAddress)) {
                $Hash.Add($_.PrimarySmtpAddress, $_.objectid)
            }
        }
    }

    Process {

        foreach ($Msol in $MsolDetail) {
            $PropHash = @{}
            $Msol.PsObject.Properties | Where-Object { $_.Name -notin $DontImportProperties } | ForEach-Object {
                if ($_.Value) { $PropHash[$_.Name] = $_.Value }
            }
            if ($PropHash) {
                try {
                    Set-MsolUser -ObjectId $hash.$($Msol.PrimarySmtpAddress) @PropHash -ErrorAction Stop

                    [PSCustomObject]@{
                        Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result             = 'SUCCESS'
                        Action             = 'SETTING'
                        Object             = 'MSOLUSER'
                        Name               = $Msol.DisplayName
                        Alias              = 'SUCCESS'
                        UserPrincipalName  = $Msol.PrimarySmtpAddress
                        PrimarySmtpAddress = $Msol.PrimarySmtpAddress
                        EmailAddresses     = 'SUCCESS'
                        ObjectId           = $Hash.$($Msol.PrimarySmtpAddress)
                        FullNameError      = 'SUCCESS'
                        Message            = 'SUCCESS'
                        ExtendedMessage    = 'SUCCESS'
                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                    Write-HostLog -Message "Setting MsolUser`t$($Msol.DisplayName)`t$($Msol.PrimarySmtpAddress)" -Status "Success"
                }
                catch {
                    [PSCustomObject]@{
                        Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                        Result             = 'FAILED'
                        Action             = 'SETTING'
                        Object             = 'MSOLUSER'
                        Name               = $Msol.DisplayName
                        Alias              = 'FAILED'
                        UserPrincipalName  = $Msol.PrimarySmtpAddress
                        PrimarySmtpAddress = $Msol.PrimarySmtpAddress
                        EmailAddresses     = 'FAILED'
                        ObjectId           = $Hash.$($Msol.PrimarySmtpAddress)
                        FullNameError      = $_.Exception.GetType().fullname
                        Message            = $_.CategoryInfo.Reason
                        ExtendedMessage    = $_.Exception.Message
                    } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                    Write-HostLog -Message "Setting MsolUser`t$($Msol.DisplayName)`t$($Msol.PrimarySmtpAddress)" -Status "Failed"
                }

            }
        }
    }
    End {

    }
}