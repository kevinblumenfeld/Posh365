function Get-DestinationRecipientHash {
    [CmdletBinding()]
    param (
    [Parameter(Mandatory)]
    [ValidateSet('RemoteMailbox','MailContact')]
    $Type
    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }


    if ($Type -eq 'RemoteMailbox') {
        $File = 'TargetRemoteMailbox.xml'
        $HashFile = 'TargetRemoteMailboxHash.xml'
    }
    else {
        $File = 'TargetMailContact.xml'
        $HashFile = 'TargetMailContactHash.xml'
    }
    $RemoteXML = Join-Path -Path $PoshPath -ChildPath $File
    if (-not (Test-Path $RemoteXML)) {
        Write-Host "XML ($RemoteXML) needed was not found.  Creating now . . . " -ForegroundColor White

            Get-Recipient -ResultSize Unlimited -RecipientTypeDetails RemoteUserMailbox, RemoteRoomMailbox, RemoteEquipmentMailbox, RemoteSharedMailbox |

        Select-Object * | Export-Clixml -Path $RemoteXML
    }
    else {
        Write-Host "Found the XML created earlier: ($RemoteXML) . . . " -ForegroundColor Green
    }

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
