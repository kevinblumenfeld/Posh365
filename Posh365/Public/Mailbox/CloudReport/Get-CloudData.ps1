using namespace System.Management.Automation.Host
function Get-CloudData {
    [CmdletBinding()]
    param (
        [Parameter()]
        $ResultSize = 'Unlimited'
    )

    Get-PSSession | Remove-PSSession
    Connect-ExchangeOnline
    $InitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName

    if ($InitialDomain) {
        $Yes = [ChoiceDescription]::new('&Yes', 'Source Domain: Yes')
        $No = [ChoiceDescription]::new('&No', 'Source Domain: No')
        $Question = 'Is this the source tenant {0}?' -f $InitialDomain
        $Options = [ChoiceDescription[]]($Yes, $No)
        $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

        switch ($Menu) {
            0 { }
            1 { break }
        }
    }
    else {
        Write-Host 'Not connected to Exchange Online' -ForegroundColor Red
        break
    }

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $SourcePath = Join-Path -Path $PoshPath -ChildPath $InitialDomain
    $SourceFile = Join-Path -Path $SourcePath -ChildPath ('{0}.csv' -f $InitialDomain)

    if (-not ($null = Test-Path $SourcePath)) {
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item $PoshPath @ItemSplat
        $null = New-Item $SourcePath @ItemSplat
    }

    Write-Host ('{0}Connected to source: ' -f [Environment]::NewLine) -ForegroundColor Cyan -NoNewline
    Write-Host ('{0}{1}' -f $InitialDomain, [Environment]::NewLine) -ForegroundColor Green
    Write-Host 'Writing to: ' -ForegroundColor White -NoNewline
    Write-Host ('{0}{1}' -f $SourceFile, [Environment]::NewLine) -ForegroundColor Yellow

    $SourceData = Invoke-GetCloudData -ResultSize $ResultSize -InitialDomain $InitialDomain
    $SourceData | Export-Csv -Path $SourceFile -NoTypeInformation

    Write-Host ('Source tenant data is complete: {0} {1}' -f $SourceFile, [Environment]::NewLine) -ForegroundColor Green


    $Yes = [ChoiceDescription]::new('&Yes', 'Convert Cloud Data: Yes')
    $No = [ChoiceDescription]::new('&No', 'Convert Cloud Data: No')
    $Question = 'Convert data? (we only create a CSV in this step - we do not write to the tenent)'
    $Options = [ChoiceDescription[]]($Yes, $No)
    $Menu = $host.ui.PromptForChoice($Title, $Question, $Options, 0)

    switch ($Menu) {
        0 {
            Write-Host ('Converting data...{0}' -f [Environment]::NewLine) -ForegroundColor Gray

            Get-PSSession | Remove-PSSession
            Connect-ExchangeOnline
            $TargetInitialDomain = ((Get-AcceptedDomain).where{ $_.InitialDomain }).DomainName
            $TargetFile = Join-Path -Path $SourcePath -ChildPath ('{0}.csv' -f $TargetInitialDomain)

            Write-Host 'Connected to target: ' -ForegroundColor Cyan -NoNewline
            Write-Host ('{0}{1}' -f $TargetInitialDomain, [Environment]::NewLine) -ForegroundColor Green
            Write-Host 'Converted target file: ' -ForegroundColor Gray -NoNewline
            Write-Host ('{0}{1}' -f $TargetFile, [Environment]::NewLine) -ForegroundColor Yellow

            Convert-CloudData -SourceData $SourceData | Export-Csv -Path $TargetFile -NoTypeInformation
        }
        1 {
            Write-Host 'Halting Script' -ForegroundColor Red
            break
        }
    }
}
