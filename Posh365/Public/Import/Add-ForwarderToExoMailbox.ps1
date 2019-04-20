function Add-ForwarderToExoMailbox {
    <#
    .SYNOPSIS
    Waits for an Exchange Online Mailbox to be provisioned then adds a forwarder.
    Prefix of forwarder is the mailbox's PrimarySmtpAddress and the Suffix is specified at runtime.

    .DESCRIPTION
    Waits for an Exchange Online Mailbox to be provisioned then adds a forwarder.
    Prefix of forwarder is the mailbox's PrimarySmtpAddress and the Suffix is specified at runtime.

    .PARAMETER ForwardSuffix
    Example -ForwardSuffix 'forward.contoso.com'

    .PARAMETER PrimarySmtpAddress
    To specify PrimarySmtpAddress of the mailbox in which to add a forward.
    This is instead of using the pipeline

    .PARAMETER OutputPath
    Output path for log files. Example -OutputPath c:\scripts

    .PARAMETER User
    This parameter is fed via the pipeline like the following example:
    Import-Csv .\users.csv | Add-ForwarderToExoMailbox 'forward.contoso.com' -OutputPath c:\scripts -Verbose

    .EXAMPLE
    Import-Csv .\users.csv | Add-ForwarderToExoMailbox 'forward.contoso.com' -OutputPath c:\scripts -Verbose

    .EXAMPLE
    Add-ForwarderToExoMailbox -ForwardSuffix 'forward.contoso.com' -PrimarySmtpAddress 'jane@contoso.com' -OutputPath c:\scripts -Verbose

    .EXAMPLE
    Add-ForwarderToExoMailbox -ForwardSuffix 'forward.contoso.com' -PrimarySmtpAddress 'jane@contoso.com','joe@contoso.com' -OutputPath c:\scripts -Verbose

    .NOTES
    CSV must have at least one column with header named login

    for example...

    DisplayName, Login, Email
    Jane Smith, Jane@contoso.com, Jane@contoso.com
    Joe Smith, Joe@contoso.com, Joe@contoso.com

    OR perhaps just one column

    Login
    Jane@contoso.com
    Joe@contoso.com
    Fred@contoso.com
    Sally@contoso.com

    #>

    [CmdletBinding(DefaultParameterSetName = 'UPN')]
    param(

        [Parameter(Position = 0, Mandatory)]
        [string]
        $ForwardSuffix,

        [Parameter(Position = 1, ParameterSetName = "UPN")]
        [Alias("UPN")]
        [string[]]
        $PrimarySmtpAddress,

        [Parameter(Mandatory = $true)]
        [String] $OutputPath,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = "Pipeline")]
        [Alias("InputObject")]
        [object[]]
        $User

    )
    begin {

        $LogFileName = $(Get-Date -Format yyyy-MM-dd)
        $Log = Join-Path $OutputPath ($LogFileName + "-Add_Fowarder-Log.csv")
        $ForwardSuffix = $ForwardSuffix.Trim('@')

    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "UPN" {
                foreach ($Object in $PrimarySmtpAddress) {
                    Write-Host "Object: $Object"
                    $Filterstring = "PrimarySmtpAddress -eq '{0}'" -f $Object
                    if ($Mailbox = Get-Mailbox -Filter $Filterstring) {
                        $Forward = '{0}@{1}' -f $Mailbox.PrimarySmtpAddress.Split('@')[0], $ForwardSuffix
                        try {
                            [string]$Guid = $Mailbox.Guid
                            Set-Mailbox -Identity $Guid -ForwardingSmtpAddress $Forward -erroraction stop
                            Write-Verbose ("SUCCESS: Mailbox forwarder set {0}" -f $Mailbox.DisplayName)
                            $AfterSet = Get-Mailbox -Filter $Filterstring
                            Write-Host "$($AfterSet.DisplayName) New Forwarding Address: $($AfterSet.ForwardingSmtpAddress)" -ForegroundColor Green
                            [PSCustomObject]@{
                                Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result             = 'SUCCESS'
                                Action             = 'SETFORWARD'
                                Object             = $Object
                                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                                DisplayName        = $Mailbox.DisplayName
                                ExchangeGuid       = $Mailbox.ExchangeGuid
                                ForwardingBefore   = $Mailbox.ForwardingSmtpAddress
                                FowardingAfter     = $AfterSet.ForwardingSmtpAddress
                                FullNameError      = 'SUCCESS'
                                Message            = 'SUCCESS'
                                ExtendedMessage    = 'SUCCEES'
                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                        }
                        catch {
                            Write-Host ("FAILED: Mailbox forwarder not set {0}" -f $Mailbox.DisplayName) -ForegroundColor Red
                            [PSCustomObject]@{
                                Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result             = 'FAILED'
                                Action             = 'SETFORWARD'
                                Object             = $Object
                                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                                DisplayName        = $Mailbox.DisplayName
                                ExchangeGuid       = $Mailbox.ExchangeGuid
                                ForwardingBefore   = $Mailbox.ForwardingSmtpAddress
                                FowardingAfter     = 'FAILED'
                                FullNameError      = $_.Exception.GetType().fullname
                                Message            = $_.CategoryInfo.Reason
                                ExtendedMessage    = $_.Exception.Message
                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                        }
                    }
                    else {
                        Write-Host ("FAILED: Mailbox not found {0}" -f $Object) -ForegroundColor Red
                        [PSCustomObject]@{
                            Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result             = 'FAILED'
                            Action             = 'MAILBOXNOTFOUND'
                            Object             = $Object
                            PrimarySmtpAddress = 'MAILBOXNOTFOUND'
                            DisplayName        = 'MAILBOXNOTFOUND'
                            ExchangeGuid       = 'MAILBOXNOTFOUND'
                            ForwardingBefore   = 'MAILBOXNOTFOUND'
                            FowardingAfter     = 'MAILBOXNOTFOUND'
                            FullNameError      = 'MAILBOXNOTFOUND'
                            Message            = 'MAILBOXNOTFOUND'
                            ExtendedMessage    = 'MAILBOXNOTFOUND'

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                }
            }
            "Pipeline" {
                if ($MyInvocation.ExpectingInput) {
                    $User = , $User
                }

                foreach ($Object in $User) {
                    Write-Host "Object: $($Object.Login)"
                    $Filterstring = "PrimarySmtpAddress -eq '{0}'" -f $Object.Login
                    if ($Mailbox = Get-Mailbox -Filter $Filterstring) {
                        $Forward = '{0}@{1}' -f $Mailbox.PrimarySmtpAddress.Split('@')[0], $ForwardSuffix
                        try {
                            [string]$Guid = $Mailbox.Guid
                            Set-Mailbox -Identity $Guid -ForwardingSmtpAddress $Forward -erroraction stop
                            Write-Verbose ("SUCCESS: Mailbox forwarder set {0}" -f $Mailbox.DisplayName)
                            $AfterSet = Get-Mailbox -Filter $Filterstring
                            Write-Host "$($AfterSet.DisplayName) New Forwarding Address: $($AfterSet.ForwardingSmtpAddress)" -ForegroundColor Green
                            [PSCustomObject]@{
                                Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result             = 'SUCCESS'
                                Action             = 'SETFORWARD'
                                Object             = $Object.Login
                                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                                DisplayName        = $Mailbox.DisplayName
                                ExchangeGuid       = $Mailbox.ExchangeGuid
                                ForwardingBefore   = $Mailbox.ForwardingSmtpAddress
                                FowardingAfter     = $AfterSet.ForwardingSmtpAddress
                                FullNameError      = 'SUCCESS'
                                Message            = 'SUCCESS'
                                ExtendedMessage    = 'SUCCEES'
                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                        }
                        catch {
                            Write-Host ("FAILED: Mailbox forwarder not set {0}" -f $Mailbox.DisplayName) -ForegroundColor Red
                            [PSCustomObject]@{
                                Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                                Result             = 'FAILED'
                                Action             = 'SETFORWARD'
                                Object             = $Object.Login
                                PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                                DisplayName        = $Mailbox.DisplayName
                                ExchangeGuid       = $Mailbox.ExchangeGuid
                                ForwardingBefore   = $Mailbox.ForwardingSmtpAddress
                                FowardingAfter     = 'FAILED'
                                FullNameError      = $_.Exception.GetType().fullname
                                Message            = $_.CategoryInfo.Reason
                                ExtendedMessage    = $_.Exception.Message
                            } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                        }
                    }
                    else {
                        Write-Host ("FAILED: Mailbox not found {0}" -f $Object.Login) -ForegroundColor Red
                        [PSCustomObject]@{
                            Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result             = 'FAILED'
                            Action             = 'MAILBOXNOTFOUND'
                            Object             = $Object.Login
                            PrimarySmtpAddress = 'MAILBOXNOTFOUND'
                            DisplayName        = 'MAILBOXNOTFOUND'
                            ExchangeGuid       = 'MAILBOXNOTFOUND'
                            ForwardingBefore   = 'MAILBOXNOTFOUND'
                            FowardingAfter     = 'MAILBOXNOTFOUND'
                            FullNameError      = 'MAILBOXNOTFOUND'
                            Message            = 'MAILBOXNOTFOUND'
                            ExtendedMessage    = 'MAILBOXNOTFOUND'

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                }
            }
        }
    }
    end {

    }

}
