function Sync-RemoteRoutingAddress {
    [CmdletBinding()]
    param (
    )

    # Consider using AD so we dont tickle Mailboxes!!!
    ##########
    # ADD SERVER !!!!!! for RM or AD

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -Type Directory -Force -ErrorAction SilentlyContinue
    }
    while (-not $InitialDomain) {
        $InitialDomain = Select-CloudDataConnection -Type 'MailUsers' -TenantLocation 'Source' -OnlyEXO
    }

    $SourceMeuXML = Join-Path -Path $PoshPath -ChildPath ('Sync-RRA_Source_MailUsers_{0}_{1}.xml' -f $InitialDomain, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $MEUList = Get-MailUser -ResultSize Unlimited
    $MEUList | Select-Object * | Export-Clixml -Path $SourceMeuXML

    $SourceMoveRequestXML = Join-Path -Path $PoshPath -ChildPath ('Sync-RRA_Source_MoveRequests_{0}_{1}.xml' -f $InitialDomain, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $MoveChoice = Get-MoveRequest -ResultSize Unlimited | Out-GridView -Title 'Choose - COMPLETED - Move Requests. To be matched to Remote Mailboxes' -OutputMode Multiple
    $MoveChoice | Select-Object * | Export-Clixml -Path $SourceMoveRequestXML

    $MoveHash = @{ }
    foreach ($Move in $MoveChoice) {
        $MoveHash[$Move.ExchangeGuid] = @{
            DisplayName               = $Move.DisplayName
            Alias                     = $Move.Alias
            Guid                      = $Move.Guid
            ExternalDirectoryObjectId = $Move.ExternalDirectoryObjectId
            Identity                  = $Move.Identity
            Status                    = $Move.Identity
        }
    }
    # MailUser is added to the MEUHash only if the ExchangeGUID is found in a move request
    $MeuHash = @{ }
    foreach ($Meu in $MEUList) {
        if ($MoveHash.ContainsKey($Meu.ExchangeGuid)) {
            $MeuHash[$Meu.ExchangeGuid] = @{
                DisplayName               = $Meu.DisplayName
                ExternalEmailAddress      = $Meu.ExternalEmailAddress
                ArchiveGuid               = $Meu.ArchiveGuid
                Alias                     = $Meu.Alias
                EmailAddresses            = @($Meu.EmailAddresses) -ne '' -join '|'
                Guid                      = $Meu.Guid
                ImmutableId               = $Meu.ImmutableId
                ExternalDirectoryObjectId = $Meu.ExternalDirectoryObjectId
                Identity                  = $Meu.Identity
                UserPrincipalName         = $Meu.UserPrincipalName
                ForwardingAddress         = $Meu.ForwardingAddress
            }
        }
    }
    Get-PSSession | Remove-PSSession
    Connect-Exchange -PromptConfirm

    $SourceRemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath ('Sync-RRA_Source_RemoteMailbox_{0}_{1}.xml' -f $InitialDomain, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $RemoteMailboxList = Get-RemoteMailbox -ResultSize Unlimited
    $RemoteMailboxList | Select-Object * | Export-Clixml -Path $SourceRemoteMailboxXML

    $RemoteMailboxHash = @{ }
    foreach ($RemoteMailbox in $RemoteMailboxList) {
        $RemoteMailboxHash[$RemoteMailbox.ExchangeGuid] = @{
            DisplayName                  = $RemoteMailbox.DisplayName
            RemoteRoutingAddress         = $RemoteMailbox.RemoteRoutingAddress
            PrimarySmtpAddress           = $RemoteMailbox.PrimarySmtpAddress
            EmailAddresses               = @($RemoteMailbox.EmailAddresses) -ne '' -join '|'
            ArchiveGuid                  = $RemoteMailbox.ArchiveGuid
            Guid                         = $RemoteMailbox.Guid
            Identity                     = $RemoteMailbox.Identity
            UserPrincipalName            = $RemoteMailbox.UserPrincipalName
            ForwardingAddress            = $RemoteMailbox.ForwardingAddress
            OnPremisesOrganizationalUnit = $RemoteMailbox.OnPremisesOrganizationalUnit
        }
    }
    $i = 0
    $Total = @($MoveHash.Keys).count
    $MailboxMatchMove = foreach ($MoveKey in $MoveHash.keys) {
        $i++
        if ($RemoteMailboxHash.ContainsKey($MoveKey) -and
            $MeuHash.ContainsKey($MoveKey) -and
            $MoveKey -ne '00000000-0000-0000-0000-000000000000') {
            [PSCustomObject]@{
                Num                          = '[{0} of {1}]' -f $i, $Total
                DisplayName                  = $RemoteMailboxHash[$MoveKey]['DisplayName']
                OnPremisesOrganizationalUnit = $RemoteMailboxHash[$MoveKey]['OnPremisesOrganizationalUnit']
                RequestedRRA                 = $MeuHash[$MoveKey]['ExternalEmailAddress']
                CurrentRRA                   = $RemoteMailboxHash[$MoveKey]['RemoteRoutingAddress']
                PrimarySmtpAddress           = $RemoteMailboxHash[$MoveKey]['PrimarySmtpAddress']
                UserPrincipalName            = $RemoteMailboxHash[$MoveKey]['UserPrincipalName']
                ForwardingAddress            = $RemoteMailboxHash[$MoveKey]['ForwardingAddress']
                ExchangeGuid                 = $MoveKey
                ArchiveGuid                  = $RemoteMailboxHash[$MoveKey]['ArchiveGuid']
                EmailAddresses               = $RemoteMailboxHash[$MoveKey]['EmailAddresses']
                RMGuid                       = $RemoteMailboxHash[$MoveKey]['Guid']
                MEUGuid                      = $MeuHash[$MoveKey]['Guid']
            }
        }
        else {
            Write-Host ('[{0} of {1}] Move Request {2} ExchangeGuid is all zeros, missing from MEU or RemoteMailbox hashtables' -f $i, $Total, $MoveHash[$MoveKey]['DisplayName']) -ForegroundColor Red
            Write-Host ('[{0} of {1}] Move Request {2} found in MEU hashtable: {3}' -f $i, $Total, $MoveHash[$MoveKey]['DisplayName'], $MeuHash.ContainsKey($MoveKey))
            Write-Host ('[{0} of {1}] Move Request {2} found in RemoteMailbox hashtable: {3}' -f $i, $Total, $MoveHash[$MoveKey]['DisplayName'], $RemoteMailboxHash.ContainsKey($MoveKey))
            Write-Host ('[{0} of {1}] Move Request {2} ExchangeGuid is 00000000-0000-0000-0000-000000000000: {3}' -f $i, $Total, $MoveHash[$MoveKey]['DisplayName'], ($MoveKey -eq '00000000-0000-0000-0000-000000000000'))
        }
    }
    $ResultCsv = Join-Path -Path $PoshPath -ChildPath 'Sync-RRA_Target_RemoteMailbox_RESULTS.csv'
    $RemoteMailboxChoice = $MailboxMatchMove | Out-GridView -OutputMode Multiple -Title 'Choose the Remote Mailboxes to stamp with RequestedRRA'
    while ($RemoteMailboxChoice) {
        $Result = Invoke-SyncRemoteRoutingAddress -RemoteMailboxChoice $RemoteMailboxChoice
        $Result | Export-Csv $ResultCsv -NoTypeInformation -Append -Force
        $Result | Out-GridView -Title 'Results of RRA stamping'
        $RemoteMailboxChoice = $MailboxMatchMove | Sort-Object DisplayName, OnPremisesOrganizationalUnit |
        Out-GridView -OutputMode Multiple -Title 'Choose the Remote Mailboxes to stamp with RequestedRRA'
    }

}
