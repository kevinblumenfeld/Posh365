function Compare-Guid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
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
        break
    }

    Get-PSSession | Remove-PSSession
    Connect-ExchangeOnline
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    $SourceFile = Join-Path -Path $SourcePath -ChildPath ('CompareGuid_{0}.csv' -f $InitialDomain)

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
    $CompareResult | Out-GridView -Title 'Results of Guid Comparison'
    $CompareResult | Export-Csv $SourceFile


    $Yes = [ChoiceDescription]::new('&Yes', 'Set-RemoteDomain: Yes')
    $No = [ChoiceDescription]::new('&No', 'Set-RemoteDomain: No')
    $Question = 'Are you ready to stamp ExchangeGuid in this tenant... {0} ?' -f $InitialDomain
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

    switch ($Menu) {
        0 { <#  Set-RemoteDomain #>  }
        1 { break }
    }


}