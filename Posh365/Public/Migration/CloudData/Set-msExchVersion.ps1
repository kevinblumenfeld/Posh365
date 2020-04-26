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
    if (-not $SkipConnection) {
        Get-PSSession | Remove-PSSession
        Connect-Exchange @PSBoundParameters -PromptConfirm
    }

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox.xml'

    if (-not (Test-Path $RemoteMailboxXML)) {
        Write-Host "Fetching Remote Mailboxes..." -ForegroundColor Cyan
        Get-RemoteMailbox -ResultSize unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
        $RemoteMailboxList = Import-Clixml $RemoteMailboxXML
        return
    }
    else {
        $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OnPremisesOrganizationalUnit
    }

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

    Write-Host "Choose which Remote Mailboxes in which to disable their Email Address Policy" -ForegroundColor Black -BackgroundColor White
    Write-Host "To select use Ctrl/Shift + click (individual) or Ctrl + A (All)" -ForegroundColor Black -BackgroundColor White

    $Choice = Select-DisableMailboxEmailAddressPolicy -RemoteMailboxList $RemoteMailboxList |
    Out-GridView -OutputMode Multiple -Title "Choose which Remote Mailboxes in which to disable their Email Address Policy"
    $ChoiceCSV = Join-Path -Path $PoshPath -ChildPath ('Before Disable EAP {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Choice | Export-Csv $ChoiceCSV -NoTypeInformation -Encoding UTF8

    if ($Choice) { Get-DecisionbyOGV } else { Write-Host "Halting as nothing was selected" ; continue }
    $Result = Invoke-DisableMailboxEmailAddressPolicy -Choice $Choice -Hash $RMHash
    $Result | Out-GridView -Title ('Results of Disabling Email Address Policy  [ Count: {0} ]' -f $Result.Count)
    $ResultCSV = Join-Path -Path $PoshPath -ChildPath ('After Disable EAP { 0 }.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Result | Export-Csv $ResultCSV
}
