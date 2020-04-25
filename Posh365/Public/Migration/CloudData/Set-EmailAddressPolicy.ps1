function Set-EmailAddressPolicy {
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
        $Enable,

        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )
    Get-PSSession | Remove-PSSession
    Connect-Exchange @PSBoundParameters -PromptConfirm
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

    Write-Host "Choose the Remote Mailboxes to set their EmailAddressPolicyEnabled to $Enable" -ForegroundColor Black -BackgroundColor White
    Write-Host "To select use Ctrl/Shift + click (individual) or Ctrl + A (All)" -ForegroundColor Black -BackgroundColor White

    $Choice = Select-SetEmailAddressPolicy -RemoteMailboxList $RemoteMailboxList |
    Out-GridView -OutputMode Multiple -Title "Choose the Remote Mailboxes to set their EmailAddressPolicyEnabled to $Enable"
    $ChoiceCSV = Join-Path -Path $PoshPath -ChildPath ('Before set EmailAddressPolicyEnabled to {0} _ {1}.csv' -f $Enable, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Choice | Export-Csv $ChoiceCSV -NoTypeInformation -Encoding UTF8

    if ($Choice) { Get-DecisionbyOGV } else { Write-Host "Halting as nothing was selected" ; continue }
    $Result = Invoke-SetEmailAddressPolicy -Choice $Choice -Hash $RMHash
    $Result | Out-GridView -Title ('Results of Setting Email Address Policy to {0}. [ Count: {1} ]' -f $Enable, $Result.Count)
    $ResultCSV = Join-Path -Path $PoshPath -ChildPath ('After set EmailAddressPolicyEnabled ({0}) to {1} _ {2}.csv' -f $Result.Count, $Enable, [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Result | Export-Csv $ResultCSV
}
