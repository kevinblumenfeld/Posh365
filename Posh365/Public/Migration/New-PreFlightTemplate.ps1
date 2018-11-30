function New-PreFlightTemplate {
    param (
        
        [Parameter(Mandatory)]
        [string] $FileNamePath
    )
    
    if (-not (Test-Path $FileNamePath)) {

        $Header = "Check,MailboxType,RecipientType,BatchName,RemoteHostName,UserPrincipalName,RetentionPolicy,ForwardingAddress,ForwardingSmtpAddress,DeliverToMailboxAndForward,samAccountName,ActiveSyncEnabled,IsSynchronized,CloudUPN,UPNsMatch,DisplayName,PrimarySMTP,UPNSMTPMatch,IsLicensed,GoodAddresses,RoutingAddress,FlipUPNPassword,Migrating,MailboxMigrated,ActiveSyncEnabledPostMigration,ForwardingPostMigration,PreflightComplete,MoveRequest,MoveStatus,MoveBatch,ErrorCloud,ErrorOnPrem"
        Set-Content -Path $FileNamePath -Value $Header

    }
    else {
        Write-Warning "File already exists.  Please choose another file name and try again."
    }
}