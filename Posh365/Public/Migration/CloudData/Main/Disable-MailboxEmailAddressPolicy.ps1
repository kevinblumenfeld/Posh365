function Disable-MailboxEmailAddressPolicy {
    <#
        .SYNOPSIS
            Sets Email Address Policy of On-Prem Remote Mailboxes only (for now)
            Disables by default

        .DESCRIPTION
            Sets Email Address Policy of On-Prem Remote Mailboxes only (for now)
            Disables by default

        .PARAMETER DomainController
        Parameter description

        .PARAMETER SkipMailboxesWhereEAPisFalse
        Parameter description

        .PARAMETER SkipConnection
        Parameter description

        .PARAMETER DontViewEntireForest
        Parameter description

        .EXAMPLE
        Disable-MailboxEmailAddressPolicy -DomainController DC01

        .NOTES
        General notes
        #>
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [ValidateScript( { Get-ADDomainController -identity $_ } )]
        [string]
        $DomainController,

        [Parameter()]
        [switch]
        $OnlyEAPEnabled,

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

    if ($OnlyEAPEnabled) {
        $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_OnlyEAPEnabled.xml'
        Get-RemoteMailbox -DomainController $DomainController -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
        $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OrganizationalUnit
        Write-Host "Caching ADUser Hashtable..." -ForegroundColor Cyan
        $BadPolicyHash = Get-ADEmailAddressPolicyHash -DomainController $DomainController
        Write-Host "Caching Remote Mailbox Hashtable..." -ForegroundColor Cyan
        $RMHash = Get-RemoteMailboxHash -Key Guid -RemoteMailboxList $RemoteMailboxList
    }
    else {
        $RemoteMailboxXML = Join-Path -Path $PoshPath -ChildPath 'RemoteMailbox_ALL.xml'
        Get-RemoteMailbox -DomainController $DomainController -ResultSize Unlimited | Select-Object * | Export-Clixml $RemoteMailboxXML
        $RemoteMailboxList = Import-Clixml $RemoteMailboxXML | Sort-Object DisplayName, OrganizationalUnit
        $RMHash = Get-RemoteMailboxHash -Key Guid -RemoteMailboxList $RemoteMailboxList
    }
    Write-Host "Choose which Remote Mailboxes in which to disable their Email Address Policy" -ForegroundColor Black -BackgroundColor White
    Write-Host "To select use Ctrl/Shift + click (Individual) or Ctrl + A (All)" -ForegroundColor Black -BackgroundColor White
    $SelectParams = @{ RemoteMailboxList = $RemoteMailboxList }
    if ($OnlyEAPEnabled) { $SelectParams['BadPolicyHash'] = $BadPolicyHash }
    $Choice = Select-DisableMailboxEmailAddressPolicy @SelectParams |
    Out-GridView -OutputMode Multiple -Title "Choose which Remote Mailboxes in which to disable their Email Address Policy"

    if ($OnlyEAPEnabled) {
        $ChoiceCSV = Join-Path -Path $PoshPath -ChildPath ('Before Clearing EAP Policy Attributes {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    }
    else {
        $ChoiceCSV = Join-Path -Path $PoshPath -ChildPath ('Before EAP Changes {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    }
    $Choice | Export-Csv $ChoiceCSV -NoTypeInformation -Encoding UTF8

    if ($Choice) { Get-DecisionbyOGV } else { Write-Host 'Halting as nothing was selected' ; continue }
    if ($OnlyEAPEnabled) {
        $ClearResult = Clear-ADEmailAddressPolicyAttributes -Choice $Choice -Hash $RMHash -BadPolicyHash $BadPolicyHash -DomainController $DomainController
        $ClearResult | Out-GridView -Title ('Results of Clearing EAP Policy Attributes in AD  [ Count: {0} ]' -f @($ClearResult).Count)
        $ClearResultCSV = Join-Path -Path $PoshPath -ChildPath ('After Clearing EAP Policy Attributes {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
        $ClearResult | Export-Csv $ClearResultCSV -NoTypeInformation
        $Result = Invoke-DisableMailboxEmailAddressPolicy -CheckADeap -Choice $Choice -Hash $RMHash -DomainController $DomainController
    }
    else {
        $Result = Invoke-DisableMailboxEmailAddressPolicy -Choice $Choice -Hash $RMHash -DomainController $DomainController
    }
    $Result | Out-GridView -Title ('Results of Disabling Email Address Policy  [ Count: {0} ]' -f @($Result).Count)
    $ResultCSV = Join-Path -Path $PoshPath -ChildPath ('After Disable EAP {0}.csv' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
    $Result | Export-Csv $ResultCSV -NoTypeInformation
}
