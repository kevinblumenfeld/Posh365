function Add-ExMailboxPermission {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Mailbox
    Parameter description

    .PARAMETER Granted
    Parameter description

    .PARAMETER FullAccess
    Parameter description

    .PARAMETER SendAs
    Parameter description

    .PARAMETER SendOnBehalf
    Parameter description

    .PARAMETER AutoMap
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    param(
        [Parameter(Mandatory)]
        [string]
        $Mailbox,

        [Parameter(Mandatory)]
        [string]
        $Granted,

        [Parameter()]
        [switch]
        $FullAccess,

        [Parameter()]
        [switch]
        $SendAs,

        [Parameter()]
        [switch]
        $SendOnBehalf,

        [Parameter()]
        [switch]
        $AutoMap
    )
    $Mailbox = (Get-Mailbox -Filter "PrimarySmtpAddress -eq '$Mailbox'").DistinguishedName
    $Granted = (Get-Mailbox -Filter "PrimarySmtpAddress -eq '$Granted'").DistinguishedName
    switch ($true) {
        $FullAccess { Add-MailboxPermission -Identity $Mailbox -User $Granted -AccessRights 'FullAccess' -Automapping:$AutoMap }
        $SendAs { Add-ADPermission -Identity $Mailbox -User $Granted -AccessRights 'ExtendedRight' -ExtendedRights 'Send As' }
        $SendOnBehalf { Set-Mailbox -Identity $Mailbox -GrantSendOnBehalfTo $Granted }
        Default { }
    }
}
