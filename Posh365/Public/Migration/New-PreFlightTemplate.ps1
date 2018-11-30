function New-PreFlightTemplate {
    param (
        
        [Parameter(Mandatory)]
        [string] $CsvFileName
    )
    
    if (-not (Test-Path $CsvFileName)) {

        $Header = "Check,MailboxType,RecipientType,BatchName,RemoteHostName,UserPrincipalName,RetentionPolicy,ForwardingAddress,ForwardingSmtpAddress,DeliverToMailboxAndForward,samAccountName,ActiveSyncEnabled,IsSynchronized,CloudUPN,UPNsMatch,DisplayName,PrimarySMTP,UPNSMTPMatch,IsLicensed,GoodAddresses,RoutingAddress,FlipUPNPassword,Migrating,MailboxMigrated,ActiveSyncEnabledPostMigration,ForwardingPostMigration,PreflightComplete,MoveRequest,MoveStatus,MoveBatch,ErrorCloud,ErrorOnPrem,ErrorCreatingMoveRequest"
        Set-Content -Path $CsvFileName -Value $Header

    }
    else {
        Write-Warning "File already exists.  Please choose another file name and try again."
    }
}