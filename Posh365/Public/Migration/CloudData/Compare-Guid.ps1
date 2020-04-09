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

    $AddGuidList = $CompareResult | Where-Object { -not $_.MailboxGuidMatch }
    $GuidResult = Set-ExchangeGuid -AddGuidList $AddGuidList
    $GuidResult | Out-GridView -Title "Results of Adding Guid to Tenant: $InitialDomain"
    $ResultFile = Join-Path -Path $SourcePath -ChildPath ('Guid_Result_{0}.csv' -f $InitialDomain)
    $GuidResult | Export-Csv $ResultFile -NoTypeInformation
}