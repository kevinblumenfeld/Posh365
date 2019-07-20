function Get-Demo {
    param ()

    # CONNECT
    Connect-CloudMFA -Tenant "MKevin" -ExchangeOnline

    # MIGRATE
    New-MailboxMove
    Get-MailboxMove
    Suspend-MailboxMove
    Resume-MailboxMove
    Set-MailboxMove
    Complete-MailboxMove
    Remove-MailboxMove

    # MIGRATION REPORTING
    Get-MailboxMoveReport
    Get-MailboxMoveStatistics

    # PERMISSIONS
    Add-MailboxMovePermission
    Get-MailboxMovePermission
    Remove-MailboxMovePermission

    # LICENSE
    Get-MailboxMoveLicense
    Set-MailboxMoveLicense
    Get-MailboxMoveLicenseCount

    # CREDENTIAL
    Remove-MailboxMoveCredential

    # ON PREMISES
    Get-MailboxMoveOnPremisesMailboxReport
    Get-MailboxMoveOnPremisesPermissionReport

    # TRASH?
    Connect-MailboxMove
    Start-MailboxMoveTask

}
