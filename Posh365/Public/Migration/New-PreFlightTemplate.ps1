function New-PreFlightTemplate {
    param (
        
        [Parameter(Mandatory)]
        [string] $FileNamePath
    )
    
    $Header = "Check,MailboxType,RecipientType,BatchName,RemoteHostName,UserPrincipalName,RetentionPolicy,ForwardingAddress,ForwardingSmtpAddress,DeliverToMailboxAndForward,samAccountName,ActiveSyncEnabled,IsSynchronized,CloudUPN,UPNsMatch,DisplayName,PrimarySMTP,UPNSMTPMatch,IsLicensed,GoodAddresses,RoutingAddress,FlipUPNPassword,Migrating,MailboxMigrated,ActiveSyncEnabledPostMigration,ForwardingPostMigration,PreflightComplete,MoveRequest,MoveStatus,MoveBatch,ErrorCloud,ErrorOnPrem"
    $Header | Export-Csv $FileNamePath -NoTypeInformation -Encoding UTF8
}