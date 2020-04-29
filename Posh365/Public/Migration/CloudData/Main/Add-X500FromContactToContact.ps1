using namespace System.Management.Automation.Host
function Add-X500FromContactToContact {
    [CmdletBinding()]
    param (

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    Get-PSSession | Remove-PSSession
    Connect-Exchange -DontViewEntireForest:$DontViewEntireForest -PromptConfirm

    Get-DestinationRecipientHash -Type MailContact

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    $TargetHash = Join-Path -Path $PoshPath -ChildPath 'TargetContactHash.xml'
    $SourceHash = Join-Path -Path $PoshPath -ChildPath 'SourceContactHash.xml'

    if (-not (Test-Path $TargetHash) -or -not (Test-Path $SourceHash)) {
        Write-Host "Missing one or both files" -ForegroundColor Red
        Write-Host "1) $TargetHash" -ForegroundColor Cyan
        Write-Host "2) $SourceHash" -ForegroundColor Cyan
        return
    }
    else {
        $Target = Import-Clixml $TargetHash
        $Source = Import-Clixml $SourceHash
    }

    $MatchingPrimaryCSV = Join-Path -Path $PoshPath -ChildPath 'MatchingPrimary.csv'
    $ResultObject = Compare-AddX500FromContact -Target $Target -Source $Source | Sort-Object TargetDisplayName

    $ResultObject | Out-GridView -Title "Results of comparison between source and target - Looking for Source ExternalEmailAddress matches with Target PrimarySmtpAddress"
    $ResultObject | Export-Csv $MatchingPrimaryCSV -NoTypeInformation -Encoding UTF8
    Write-Host "Comparison has been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$MatchingPrimaryCSV`t`n`t`n" -ForegroundColor Green

    Write-Host "Comparing Source to Target . . ." -BackgroundColor White -ForegroundColor Black
    $Yes = [ChoiceDescription]::new('&Yes', 'WriteX500: Yes')
    $No = [ChoiceDescription]::new('&No', 'WriteX500: No')
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Title = 'Please inspect the results comparing Source ExternalEmailAddress to Target PrimarySmtpAddress'
    $Question = 'Select ( Y ) to choose the mailboxes where x500 addresses will be added. The x500s will be added from the LegacyExchageDN column and x500 column (if present)'
    $YesNo = $host.ui.PromptForChoice($Title, $Question, $Options, 1)
    switch ($YesNo) {
        0 {
            $TargetResult = Join-Path -Path $PoshPath -ChildPath 'TargetResult.csv'
            Write-Host "Choose Recipients to add X500s then click OK - To select use Ctrl/Shift + click (individual) or Ctrl + A (All)" -ForegroundColor Black -BackgroundColor White
            $AddProxyList = Invoke-Addx500FromContact -MatchingPrimary $ResultObject | Out-GridView -OutputMode Multiple -Title "Choose Recipients to add X500s then click OK - To select use Ctrl/Shift + click (individual) or Ctrl + A (All)"
            $UserSelection = Add-ProxyToRecipient -Type MailContact -AddProxyList $AddProxyList
            $UserSelection | Out-GridView -Title 'Results of adding Email Addresses to Target Mail Contacts'
            $UserSelection | Export-Csv $TargetResult -NoTypeInformation -Encoding UTF8 -Append
            Write-Host "Log has been exported to: " -ForegroundColor Cyan -NoNewline
            Write-Host "$TargetResult" -ForegroundColor Green
        }
        1 { return }
    }
}
