function Sync-Guid {
    [CmdletBinding()]
    param (
        [Parameter()]
        $OnPremExchangeServer,

        [Parameter()]
        [switch]
        $DeleteExchangeCreds,

        [Parameter()]
        [switch]
        $DontViewEntireForest
    )

    if ($DeleteExchangeCreds) {
        Connect-Exchange -DeleteExchangeCreds:$true
        continue
    }
    while (-not $OnPremExchangeServer ) {
        Write-Host "Enter the name of the Exchange Server. Example: ExServer01.domain.com"
        $OnPremExchangeServer = Read-Host "Exchange Server Name"
    }
    while (-not $ConfirmExServer) {
        $Yes = [ChoiceDescription]::new('&Yes', 'ExServer: Yes')
        $No = [ChoiceDescription]::new('&No', 'ExServer: No')
        $Options = [ChoiceDescription[]]($Yes, $No)
        $Title = 'Specified Exchange Server: {0}' -f $OnPremExchangeServer
        $Question = 'Is this correct?'
        $YN = $host.ui.PromptForChoice($Title, $Question, $Options, 1)
        switch ($YN) {
            0 { $ConfirmExServer = $true }
            1 {
                Write-Host "`r`nEnter the name of the Exchange Server. Example: ExServer01.domain.com" -ForegroundColor Cyan
                $OnPremExchangeServer = Read-Host "Exchange Server Name"
            }
        }
    }

    $Script:RestartConsole = $null
    Connect-CloudModuleImport -EXO2
    if ($RestartConsole) {
        return
    }

    Get-PSSession | Remove-PSSession
    Write-Host "`r`nEnter Exchange Online credentials for the Target Tenant`r`n" -ForegroundColor Cyan
    Connect-ExchangeOnline
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    $SourceFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Compare_{0}.csv' -f $InitialDomain)

    if (-not ($null = Test-Path $SourcePath)) {
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item $PoshPath @ItemSplat
        $null = New-Item $SourcePath @ItemSplat
    }

    $CompareResult = Invoke-CompareGuid -OnPremExchangeServer $OnPremExchangeServer -DontViewEntireForest:$DontViewEntireForest
    $CompareResult | Out-GridView -Title "Results of Guid Comparison to Tenant: $InitialDomain"
    $CompareResult | Export-Csv $SourceFile -NoTypeInformation

    $AddGuidList = $CompareResult | Where-Object { -not $_.MailboxGuidMatch -or -not $_.ArchiveGuidMatch }
    if ($AddGuidList) {
        $GuidResult = Set-ExchangeGuid -AddGuidList $AddGuidList -OnPremExchangeServer $OnPremExchangeServer -DontViewEntireForest:$DontViewEntireForest
        $GuidResult | Out-GridView -Title "Results of Adding Guid to Tenant: $InitialDomain"
        $ResultFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Result_{0}.csv' -f $InitialDomain)
        $GuidResult | Export-Csv $ResultFile -NoTypeInformation
    }
    else {
        Write-Host "All ExchangeGuid and ArchiveGuid already match" -ForegroundColor Yellow
        continue
    }
}
