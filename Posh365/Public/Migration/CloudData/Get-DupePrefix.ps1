function Get-DupePrefix {
    <#
    .SYNOPSIS
    Compare to tenants recipients for duplicate prefixes

    .DESCRIPTION
    Compare to tenants recipients for duplicate prefixes

    Contoso Tenant:
    jane@contoso.com

    Fabrikam Tanant:
    jane@fabrikam.com

    Jane is a duplicate prefix

    .PARAMETER SourceFilePath
    xml file create from running the following in the Source Tenant

    Get-EXORecipient -ResultSize Unlimited -PropertySet All | Export-Clixml .\SourceRecipients.xml

    .PARAMETER TargetFilePath
    xml file create from running the following in the Target Tenant

    Get-EXORecipient -ResultSize Unlimited -PropertySet All | Export-Clixml .\TargetRecipients.xml

    .EXAMPLE
    Get-DupePrefix -SourceFilePath .\SourceRecipients.xml -TargetFilePath .\TargetRecipients.xml | Export-PoshExcel .\DupesBetweenTenants.xlsx

    .NOTES

    #>

    param (

        [Parameter()]
        $SourceFilePath,

        [Parameter()]
        $TargetFilePath
    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )

    if (-not ($null = Test-Path $PoshPath)) {
        $null = New-Item $PoshPath -type Directory -Force:$true -ErrorAction SilentlyContinue
    }

    $SourceHash = Invoke-GetDupePrefix -Data $SourceFilePath -PoshPath $PoshPath -FilePath $SourceFilePath
    $TargetHash = Invoke-GetDupePrefix -Data $TargetFilePath -PoshPath $PoshPath -FilePath $TargetFilePath -Target

    foreach ($SourceKey in $SourceHash.keys) {
        if ($TargetHash.ContainsKey($SourceKey)) {
            [PSCustomObject]@{
                Prefix                     = $SourceKey
                SourceDisplayName          = $SourceHash[$SourceKey]['DisplayName']
                SourceRecipientTypeDetails = $SourceHash[$SourceKey]['RecipientTypeDetails']
                SourceAddress              = $SourceHash[$SourceKey]['Address']
                SourcePrimarySmtpAdress    = $SourceHash[$SourceKey]['PrimarySmtpAddress']
                SourceEmailAddresses       = $SourceHash[$SourceKey]['EmailAddresses']
                TargetDisplayName          = $TargetHash[$SourceKey]['DisplayName']
                TargetRecipientTypeDetails = $TargetHash[$SourceKey]['RecipientTypeDetails']
                TargetAddress              = $TargetHash[$SourceKey]['Address']
                TargetPrimarySmtpAdress    = $TargetHash[$SourceKey]['PrimarySmtpAddress']
                TargetEmailAddresses       = $TargetHash[$SourceKey]['EmailAddresses']
            }
        }
    }
}