function Set-msExchVersion {

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $SkipConnection,

        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    if (-not (Get-Module ActiveDirectory -ListAvailable)) {
        Write-Host 'Active Directory PowerShell Module not found.  Halting Script.' -ForegroundColor Red
        continue
    }
    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    Import-Module ActiveDirectory -force
    Write-Host 'Creating XML of all Active Directory Users with the following values in the attribute, msExchRecipientTypeDetails:' -ForegroundColor Gray
    Write-Host '2147483648 (RemoteMailbox), 8589934592 (RemoteRoomMailbox), 17179869184 (RemoteEquipmentMailbox), 34359738368 (RemoteSharedMailbox)' -ForegroundColor Cyan
    $ADUserXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_msExchVersion.xml'
    $ADParams = @{
        LDAPFilter    = '(|(msExchRecipientTypeDetails=8589934592)(msExchRecipientTypeDetails=2147483648)(msExchRecipientTypeDetails=17179869184)(msExchRecipientTypeDetails=34359738368))'
        Properties    = '*'
        ResultSetSize = $null
    }
    $UserList = Get-ADUser @ADParams
    $UserList | Export-Clixml $ADUserXML

    $VersionList = $UserList | Group-Object msExchVersion | Sort-Object Count -Descending
    $ShowVersion = [System.Collections.Generic.List[PSObject]]::New()
    foreach ($Version in $VersionList) {
        $ShowVersion.Add([PSCustomObject]@{
                'Count'   = $Version.Count
                'Version' = $Version.Name
            })
    }
    $ShowVersion | Out-GridView -Title 'Current breakdown of msExchVersions found in Remote Mailboxes'

    if (-not $SkipConnection) {
        Get-PSSession | Remove-PSSession
        Connect-Exchange @PSBoundParameters -PromptConfirm
    }

    $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_msExchVersion.xml'
    Write-Host 'Fetching Remote Mailboxes...' -ForegroundColor Cyan

    Get-RemoteMailbox -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
    $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OnPremisesOrganizationalUnit

    Write-Host "Remote Mailboxes found in Active Directory (via msExchRecipientTypeDetails). Count:  $($UserList.Count)  " -ForegroundColor DarkBlue -BackgroundColor White
    Write-Host "Remote Mailboxes found in Exchange (via Get-RemoteMailbox). Count: $($RemoteMailboxList.Count)  " -ForegroundColor DarkBlue -BackgroundColor White
    Write-Host "  We will only effect change on those found in Exchange  " -ForegroundColor DarkRed -BackgroundColor White

    $RMHash = @{ }
    foreach ($RM in $RemoteMailboxList) {
        $RMHash[$RM.Guid.ToString()] = @{
            DisplayName                  = $RM.DisplayName
            EmailAddressPolicyEnabled    = $RM.EmailAddressPolicyEnabled
            OnPremisesOrganizationalUnit = $RM.OnPremisesOrganizationalUnit
            Alias                        = $RM.Alias
            PrimarySmtpAddress           = $RM.PrimarySmtpAddress
            EmailCount                   = $RM.EmailAddresses.Count
            EmailAddresses               = @($RM.EmailAddresses) -match 'smtp:' -join '|'
            EmailAddressesNotSmtp        = @($RemoteMailbox.EmailAddresses) -notmatch 'smtp:' -join '|'
        }
    }

    Write-Host 'Choose which Remote Mailboxes in which to disable their Email Address Policy' -ForegroundColor Black -BackgroundColor White
    Write-Host 'To select use Ctrl/Shift + click (Individual) or Ctrl + A (All)' -ForegroundColor Black -BackgroundColor White

    $Choice = Select-DisableMailboxEmailAddressPolicy -RemoteMailboxList $RemoteMailboxList |
    Out-GridView -OutputMode Multiple -Title 'Choose which Remote Mailboxes in which to disable their Email Address Policy'
    $ChoiceCSV = Join-Path -Path $PoshPath -ChildPath ('Before Disable EAP {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Choice | Export-Csv $ChoiceCSV -NoTypeInformation -Encoding UTF8

    if ($Choice) { Get-DecisionbyOGV } else { Write-Host 'Halting as nothing was selected' ; continue }
    $Result = Invoke-DisableMailboxEmailAddressPolicy -Choice $Choice -Hash $RMHash
    $Result | Out-GridView -Title ('Results of Disabling Email Address Policy  [ Count: {0} ]' -f $Result.Count)
    $ResultCSV = Join-Path -Path $PoshPath -ChildPath ('After Disable EAP {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Result | Export-Csv $ResultCSV -NoTypeInformation
}
