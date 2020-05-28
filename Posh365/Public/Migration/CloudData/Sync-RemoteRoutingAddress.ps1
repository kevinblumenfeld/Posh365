using namespace System.Management.Automation.Host
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
    $MRList = Get-MoveRequest -ResultSize Unlimited | Out-GridView -Title 'Choose Move Requests. To be matched to Remote Mailboxes' -OutputMode Multiple
    $MRList | Select-Object * | Export-Clixml -Path $SourceMoveRequestXML

    $MRHash = @{ }
    foreach ($MR in $MRList) {
        $MRHash[$MR.ExchangeGuid] = @{
            DisplayName               = $MR.DisplayName
            Alias                     = $MR.Alias
            Guid                      = $MR.Guid
            ExternalDirectoryObjectId = $MR.ExternalDirectoryObjectId
            Identity                  = $MR.Identity
            Status                    = $MR.Identity
        }
    }
    # MailUser is added to the MEUHash only if the ExchangeGUID is found in a move request
    $MeuHash = @{ }
    foreach ($Meu in $MEUList) {
        if ($MRHash.ContainsKey($Meu.ExchangeGuid)) {
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
    $RMmatchMR = foreach ($MRKey in $MRHash.keys) {
        if ($RemoteMailboxHash.ContainsKey($MRKey) -and $MRKey -ne '00000000-0000-0000-0000-000000000000') {
            # THIS IS THROWING ERROR ###
            [PSCustomObject]@{
                DisplayName                  = $RemoteMailboxHash[$MRKey]['DisplayName']
                OnPremisesOrganizationalUnit = $RemoteMailboxHash[$MRKey]['OnPremisesOrganizationalUnit']
                RequestedRRA                 = $MeuHash[$MRKey]['ExternalEmailAddress']
                CurrentRRA                   = $RemoteMailboxHash[$MRKey]['RemoteRoutingAddress']
                PrimarySmtpAddress           = $RemoteMailboxHash[$MRKey]['PrimarySmtpAddress']
                UserPrincipalName            = $RemoteMailboxHash[$MRKey]['UserPrincipalName']
                ForwardingAddress            = $RemoteMailboxHash[$MRKey]['ForwardingAddress']
                ExchangeGuid                 = $MRKey
                ArchiveGuid                  = $RemoteMailboxHash[$MRKey]['ArchiveGuid']
                EmailAddresses               = $RemoteMailboxHash[$MRKey]['EmailAddresses']
                RMGuid                       = $RemoteMailboxHash[$MRKey]['Guid']
                MEUGuid                      = $MeuHash[$MRKey]['Guid']
            }
        }
    }
    $ResultCsv = Join-Path -Path $PoshPath -ChildPath ('Sync-RRA_Target_RemoteMailbox_RESULTS.xml' -f $InitialDomain, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $RMChoice = $RMmatchMR | Sort-Object DisplayName, OnPremisesOrganizationalUnit |
    Out-GridView -OutputMode Multiple -Title 'Choose the Remote Mailboxes to stamp with RequestedRRA'
    while ($RMChoice) {
        $Result = Select-SyncRemoteRoutingAddress -RMChoice $RMChoice
        $Result | Export-Csv $ResultCsv -NoTypeInformation -Append -Force
        $Result | Out-GridView -Title 'Results of RRA stamping'
        $RMChoice = $RMmatchMR | Sort-Object DisplayName, OnPremisesOrganizationalUnit |
        Out-GridView -OutputMode Multiple -Title 'Choose the Remote Mailboxes to stamp with RequestedRRA'
    }

}
