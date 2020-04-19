function Convert-RecipientsToHash {
    [CmdletBinding()]
    param (
        [Parameter()]
        $OnPremRecipientXML
    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }

    if (-not $OnPremRecipientXML) {
        $OnPremRecipientXML = Join-Path -Path $PoshPath -ChildPath 'OnPremRecipient.xml'
        Get-Recipient -ResultSize Unlimited | Select-Object * | Export-Clixml -Path $OnPremRecipientXML
    }

    $RecipientList = Import-Clixml $OnPremRecipientXML
    $Hash = @{ }
    foreach ($Recipient in $RecipientList) {
        $Hash[$Recipient.PrimarySmtpAddress] = @{
            GUID                 = $Recipient.GUID
            RecipientTypeDetails = $Recipient.RecipientTypeDetails
            Identity             = $Recipient.Identity
            Alias                = $Recipient.Alias
            DisplayName          = $Recipient.DisplayName
            Name                 = $Recipient.Name
        }
    }
    $OutputXml = Join-Path -Path $PoshPath -ChildPath 'OnPremRecipientHash_PrimaryToGUID.xml'
    Write-Host "Hash has been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$OutputXml" -ForegroundColor Green
    $Hash | Export-Clixml $OutputXml
}
