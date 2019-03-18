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

        $LogFileName = $(Get-Date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-Add_Fowarder-Log.csv")
        $ForwardSuffix = $ForwardSuffix.Trim('@')

    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "UPN" {
                foreach ($Object in $PrimarySmtpAddress) {
                    $Object.Login
                    Do {
                        $Filterstring = "PrimarySmtpAddress -eq '{0}'" -f $Object.Login
                        $Mailbox = Get-Mailbox -Filter $Filterstring
                        Write-Verbose ("Waiting 1 minute for mailbox provisioning for {0}" -f $Object.Login)
                        Start-Sleep -Seconds 60
                    } while (-not $Mailbox)

                    $Forward = '{0}@{1}' -f $Mailbox.PrimarySmtpAddress.Split('@')[0], $ForwardSuffix

                    try {
                        $Mailbox | Set-Mailbox -ForwardingSmtpAddress $Forward -erroraction stop
                        Write-Verbose ("SUCCESS: Mailbox forwarder set {0}" -f $Mailbox.DisplayName)
                        [PSCustomObject]@{
                            Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result             = 'SUCCESS'
                            Action             = 'SETFORWARD'
                            Object             = $Object.Login
                            PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                            DisplayName        = $Mailbox.DisplayName
                            ExchangeGuid       = $Mailbox.ExchangeGuid
                            FullNameError      = 'SUCCESS'
                            Message            = 'SUCCESS'
                            ExtendedMessage    = 'SUCCEES'

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                    catch {
                        Write-Verbose ("FAILED: Mailbox forwarder not set {0}" -f $Mailbox.DisplayName)
                        [PSCustomObject]@{
                            Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result             = 'FAILED'
                            Action             = 'SETFORWARD'
                            Object             = $Object.Login
                            PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                            DisplayName        = $Mailbox.DisplayName
                            ExchangeGuid       = $Mailbox.ExchangeGuid
                            FullNameError      = $_.Exception.GetType().fullname
                            Message            = $_.CategoryInfo.Reason
                            ExtendedMessage    = $_.Exception.Message

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                }
            }
            "Pipeline" {
                if ($MyInvocation.ExpectingInput) {
                    $User = , $User
                }

                foreach ($Object in $User) {
                    $Object.Login
                    Do {
                        $Filterstring = "PrimarySmtpAddress -eq '{0}'" -f $Object.Login
                        $Mailbox = Get-Mailbox -Filter $Filterstring
                        Write-Verbose ("Waiting 1 minute for mailbox provisioning for {0}" -f $Object.Login)
                        Start-Sleep -Seconds 60
                    } while (-not $Mailbox)

                    $Forward = '{0}@{1}' -f $Mailbox.PrimarySmtpAddress.Split('@')[0], $ForwardSuffix

                    try {
                        $Mailbox | Set-Mailbox -ForwardingSmtpAddress $Forward -erroraction stop
                        Write-Verbose ("SUCCESS: Mailbox forwarder set {0}" -f $Mailbox.DisplayName)
                        [PSCustomObject]@{
                            Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result             = 'SUCCESS'
                            Action             = 'SETFORWARD'
                            Object             = $Object.Login
                            PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                            DisplayName        = $Mailbox.DisplayName
                            ExchangeGuid       = $Mailbox.ExchangeGuid
                            FullNameError      = 'SUCCESS'
                            Message            = 'SUCCESS'
                            ExtendedMessage    = 'SUCCEES'

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                    catch {
                        Write-Verbose ("FAILED: Mailbox forwarder not set {0}" -f $Mailbox.DisplayName)
                        [PSCustomObject]@{
                            Time               = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
                            Result             = 'FAILED'
                            Action             = 'SETFORWARD'
                            Object             = $Object.Login
                            PrimarySmtpAddress = $Mailbox.PrimarySmtpAddress
                            DisplayName        = $Mailbox.DisplayName
                            ExchangeGuid       = $Mailbox.ExchangeGuid
                            FullNameError      = $_.Exception.GetType().fullname
                            Message            = $_.CategoryInfo.Reason
                            ExtendedMessage    = $_.Exception.Message

                        } | Export-Csv -Path $Log -NoTypeInformation -Append -Encoding UTF8
                    }
                }
            }
        }
    }
    end {

    }

}
