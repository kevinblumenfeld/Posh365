function Get-GraphUserContacts {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $MailboxList
    )
    process {
        foreach ($Mailbox in $MailboxList) {
            Write-Host "Mailbox: $($Mailbox.UserPrincipalName)" -ForegroundColor Green
            if ([datetime]::UtcNow -ge $TimeToRefresh) { Connect-PoshGraphRefresh }
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/v1.0/users/{0}/contacts?$top=1000" -f $Mailbox.UserPrincipalName
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            (Invoke-RestMethod @RestSplat -Verbose:$false).value
        }
    }
}
