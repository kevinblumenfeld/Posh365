function Get-DestinationRecipientHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('RemoteMailbox', 'MailContact')]
        $Type
    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not (Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }
    if ($Type -eq 'RemoteMailbox') {
        $File = 'TargetRemoteMailbox.xml'
        $HashFile = 'TargetRemoteMailboxHash.xml'
        $Recip = @('RemoteUserMailbox', 'RemoteRoomMailbox', 'RemoteEquipmentMailbox', 'RemoteSharedMailbox')
    }
    else {
        $File = ('TargetContact_{0}.xml' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm'))
        $HashFile = 'TargetContactHash.xml'
        $Recip = @('MailContact')
    }
    $RemoteXML = Join-Path -Path $PoshPath -ChildPath $File
    Get-Recipient -ResultSize Unlimited -RecipientTypeDetails $Recip | Select-Object * | Export-Clixml -Path $RemoteXML

    Write-Host "Using the XML to create a hashtable . . . " -ForegroundColor White
    $RecipientList = Import-Clixml $RemoteXML
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
    $OutputXml = Join-Path -Path $PoshPath -ChildPath $HashFile
    Write-Host "Hash has been exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$OutputXml" -ForegroundColor Green
    $Hash | Export-Clixml $OutputXml
}
