function Disable-MailboxEmailAddressPolicy {
    <#
    .SYNOPSIS
    Sets Email Address Policy of On-Prem Remote Mailboxes only (for now)
    Disables by default

    .DESCRIPTION
    Sets Email Address Policy of On-Prem Remote Mailboxes only (for now)
    Disables by default

    .PARAMETER OnPremExchangeServer
    Parameter description

    .PARAMETER DeleteExchangeCreds
    Parameter description

    .PARAMETER DontViewEntireForest
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $SkipMailboxesWhereEAPisFalse,

        [Parameter()]
        [switch]
        $SkipConnection,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )
    if (-not $SkipConnection) {
        Get-PSSession | Remove-PSSession
        Connect-Exchange -DontViewEntireForest:$DontViewEntireForest -PromptConfirm
    }

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }

    Write-Host "Fetching Remote Mailboxes..." -ForegroundColor Cyan

    if ($SkipMailboxesWhereEAPisFalse) {
        $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_EAP_TRUE.xml'
        Get-RemoteMailbox -Filter "EmailAddressPolicyEnabled -eq '$true'" -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
    }
    else {
        $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_ALL.xml'
        Get-RemoteMailbox -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
    }
    $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OrganizationalUnit
    $RMHash = Get-RemoteMailboxHash -Key Guid -RemoteMailboxList $RemoteMailboxList

    Write-Host "Choose which Remote Mailboxes in which to disable their Email Address Policy" -ForegroundColor Black -BackgroundColor White
    Write-Host "To select use Ctrl/Shift + click (Individual) or Ctrl + A (All)" -ForegroundColor Black -BackgroundColor White

    $Choice = Select-DisableMailboxEmailAddressPolicy -RemoteMailboxList $RemoteMailboxList |
    Out-GridView -OutputMode Multiple -Title "Choose which Remote Mailboxes in which to disable their Email Address Policy"

    $ChoiceCSV = Join-Path -Path $PoshPath -ChildPath ('Before Disable EAP {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Choice | Export-Csv $ChoiceCSV -NoTypeInformation -Encoding UTF8

    if ($Choice) { Get-DecisionbyOGV } else { Write-Host 'Halting as nothing was selected' ; continue }

    $Result = Invoke-DisableMailboxEmailAddressPolicy -Choice $Choice -Hash $RMHash

    $Result | Out-GridView -Title ('Results of Disabling Email Address Policy  [ Count: {0} ]' -f $Result.Count)
    $ResultCSV = Join-Path -Path $PoshPath -ChildPath ('After Disable EAP {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Result | Export-Csv $ResultCSV -NoTypeInformation
}
