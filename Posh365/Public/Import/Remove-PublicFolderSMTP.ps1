function Remove-PublicFolderSMTP {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(Mandatory = $true)]
        [string] $ReportPath,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        $PF

    )
    Begin {

        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $ErrorLog = Join-Path $ReportPath ($LogFileName + "-PublicFolderSMTP-Error_Log.csv")

    }
    Process {
        ForEach ($CurPF in $PF) {
            try {

                $SetPFSplat = @{
                    Identity       = $CurPF.DisplayName
                    EmailAddresses = @{Remove = $CurPF.AddressOrMember}
                    ErrorAction    = 'Stop'
                }

                Set-MailPublicFolder @SetPFSplat
                Write-Host "Success: $($CurPF.Identity)`t$($CurPF.AddressOrMember)"
            }
            catch {
                Write-Host "Failed: $($CurPF.Identity)`t$($CurPF.AddressOrMember)"

                $Failure = $_.CategoryInfo.Reason

                [PSCustomObject]@{
                    Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                    Result             = 'FAILURE'
                    Action             = 'REMOVING'
                    Object             = 'PFSMTP'
                    DisplayName        = $CurPF.DisplayName
                    PrimarySMTPAddress = $CurPF.PrimarySMTPAddress
                    Address            = $CurPF.AddressOrMember
                    FullNameError      = $_.Exception.GetType().fullname
                    Message            = $Failure
                    ExtendedMessage    = $_.Exception.Message

                } | Export-Csv -Path $ErrorLog -NoTypeInformation -Append
            }

            Start-Sleep -Seconds 2
        }
    }
    End {

    }
}

<#


$Pf = 'foo@apple.com'

$Domain = @(
    'pear.com', 'banana.com', 'parsley.com', 'beer.com', 'strawberry.com', 'luke.com'
    'orange.com', 'star.com', 'contoso.mail.onmicrosoft.com'
)

$DomainNoMS = @(
    'pear.com', 'banana.com', 'parsley.com', 'beer.com', 'strawberry.com', 'luke.com'
    'orange.com', 'star.com'
)

$Smtp = (Get-MailPublicFolder -Identity $Pf | Select -ExpandProperty EmailAddresses |
        Where-Object {
        ($_ -split "@")[1] -in $Domain
    })

$Primary = $Smtp | Where-Object {
    ($_ -clike "SMTP:*") -and
    ($_ -split "@")[1] -in $DomainNoMS
}

$OnMicrosoft = ($Smtp | Where-Object {
        -not ($_ -clike "SMTP:*") -and
        ($_ -split "@")[1] -match 'contoso.mail.onmicrosoft.com'
    }) -replace 'SMTP:', ''

$Remove = $Smtp.tolower() | Where-Object {
    -not ($_ -match 'contoso.mail.onmicrosoft.com')
}

if ($Primary -and $OnMicrosoft) {
    Set-MailPublicFolder -Identity $Pf -PrimarySmtpAddress $OnMicrosoft
}

if ($Remove) {
    Set-MailPublicFolder -Identity $Pf -EmailAddresses @{ Remove = $Remove }
}



#>