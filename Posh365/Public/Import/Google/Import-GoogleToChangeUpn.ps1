
function Import-GoogleToChangeUpn {
    <#
    .SYNOPSIS
    Modifies existing UPNs from a CSV containing the header PrimarySmtpAddress

    .DESCRIPTION
    Modifies existing UPNs from a CSV containing the header PrimarySmtpAddress
    Note this will not succeed when changing cloud only Upn's with federated domain names

    .PARAMETER LogPath
    Log of success/failed UPN changes

    .PARAMETER LogFileFromMailboxImport
    The log file generated from creating mailboxes with Import-GoogleToSharedMailbox
    The .EXAMPLE in Import-GoogleToSharedMailbox uses the file name: SharedMailboxCreation.csv

    .PARAMETER SourceList
    This is the list used to create the mailboxes initially
    This is list is fed by the pipeline

    .EXAMPLE
    Import-Csv .\SharedMailbox-Intial_and_Phone.csv | Import-GoogleToChangeUpn -LogFileFromMailboxImport .\SharedMailboxCreation.csv -LogPath .\ChangeUpnLog.csv

    .NOTES
    General notes
    #>


    [CmdletBinding()]
    Param
    (

        [Parameter(Mandatory)]
        $LogPath,

        [Parameter(Mandatory)]
        $LogFileFromMailboxImport,

        [Parameter(Mandatory, ValueFromPipeline)]
        $SourceList

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

        foreach ($Source in $SourceList) {
            $UpnSplat = @{
                ObjectId             = $Hash.$($Source.PrimarySmtpAddress)
                NewUserPrincipalName = $Source.PrimarySmtpAddress
                ErrorAction          = 'Stop'
            }
            try {

                Set-MsolUserPrincipalName @UpnSplat

                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'SUCCESS'
                    Action             = 'CHANGEUPN'
                    Object             = 'MSOLUSER'
                    Name               = $Source.DisplayName
                    Alias              = 'SUCCESS'
                    UserPrincipalName  = $Source.PrimarySmtpAddress
                    PrimarySmtpAddress = $Source.PrimarySmtpAddress
                    EmailAddresses     = 'SUCCESS'
                    ObjectId           = $Hash.$($Source.PrimarySmtpAddress)
                    FullNameError      = 'SUCCESS'
                    Message            = 'SUCCESS'
                    ExtendedMessage    = 'SUCCESS'
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Setting UPN`t$($Source.DisplayName)`t$($Source.PrimarySmtpAddress)" -Status "Success"

            }
            catch {

                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'FAILED'
                    Action             = 'CHANGEUPN'
                    Object             = 'MSOLUSER'
                    Name               = $Source.DisplayName
                    Alias              = 'FAILED'
                    UserPrincipalName  = $Source.PrimarySmtpAddress
                    PrimarySmtpAddress = $Source.PrimarySmtpAddress
                    EmailAddresses     = 'FAILED'
                    ObjectId           = $Hash.$($Source.PrimarySmtpAddress)
                    FullNameError      = $_.Exception.GetType().fullname
                    Message            = $_.CategoryInfo.Reason
                    ExtendedMessage    = $_.Exception.Message
                } | Export-Csv -Path $LogPath -NoTypeInformation -Append

                Write-HostLog -Message "Setting UPN`t$($Source.DisplayName)`t$($Source.PrimarySmtpAddress)" -Status "Failed"
            }
        }
    }
    End {

    }
}