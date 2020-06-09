Function Set-EXODGPerms {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER IncludeSendOnBehalf
    Parameter description

    .EXAMPLE
    Set-EXODGPerms -IncludeSendOnBehalf | Out-GridView

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $IncludeSendOnBehalf
    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath('Desktop')) -ChildPath Posh365 )
    $SendAsList = Import-Csv (Join-Path $PoshPath "EXO_DGSendAs.csv")
    $SAChoice = $SendAsList | Out-GridView -OutputMode Multiple -Title 'Choose Distribution Groups to which we will apply SEND AS permissions'
    if ($IncludeSendOnBehalf) {
        $SOBList = Import-Csv (Join-Path $PoshPath "EXO_DGSendOnBehalf.csv")
        $SOBChoice = $SOBList | Out-GridView -OutputMode Multiple -Title 'Choose Distribution Groups to which we will apply SEND ON BEHALF permissions'
    }
    if ($SAChoice[0].Permission -eq 'SendAs') {
        $iSA = 0
        $Count = $SAChoice.count
        foreach ($SendAs in $SAChoice) {
            $iSA++
            try {
                $SAParams = @{
                    Identity      = $SendAs.PrimarySmtpAddress
                    Trustee       = $SendAs.GrantedSMTP
                    AccessRights  = 'SendAs'
                    ErrorAction   = 'Stop'
                    WarningAction = 'SilentlyContinue'
                    Confirm       = $false
                }
                $SAResult = Add-RecipientPermission @SAParams
                [PSCustomObject]@{
                    Num          = "[$iSA of $Count]"
                    Log          = 'SUCCESS'
                    Identity     = $SAResult.Identity
                    Trustee      = $SAResult.Trustee
                    AccessRights = @($SAResult.AccessRights) -ne '' -join '|'
                }
            }
            catch {
                [PSCustomObject]@{
                    Num          = "[$iSA of $Count]"
                    Log          = $_.Exception.Message
                    Identity     = $SendAs.PrimarySmtpAddress
                    Trustee      = $SendAs.GrantedSMTP
                    AccessRights = 'SENDAS'
                }
            }
        }
    }
    if ($SOBChoice[0].Permission -eq 'SendOnBehalf') {
        $iSOB = 0
        $SOBCount = $SOBChoice.count
        foreach ($SendOnBehalf in $SOBChoice) {
            $iSOB++
            try {
                $GroupSOB = [System.Collections.Generic.List[string]]::New()
                $CurrentSOB = Get-DistributionGroup -Identity $SendOnBehalf.PrimarySmtpAddress
                $GroupSOB.AddRange($CurrentSOB.GrantSendOnBehalfTo.ToArray([string]))
                $GroupSOB.Add($SendOnBehalf.GrantedSMTP)
                $SOBParams = @{
                    Identity            = $SendOnBehalf.PrimarySmtpAddress
                    GrantSendOnBehalfTo = $GroupSOB
                    ErrorAction         = 'Stop'
                    WarningAction       = 'SilentlyContinue'
                }
                Set-DistributionGroup @SOBParams
                [PSCustomObject]@{
                    Num          = "[$iSOB of $SOBCount]"
                    Log          = 'SUCCESS'
                    Identity     = $SendOnBehalf.PrimarySmtpAddress
                    Trustee      = $SendOnBehalf.GrantedSMTP
                    AccessRights = 'SENDONBEHALF'
                }
            }
            catch {
                [PSCustomObject]@{
                    Num          = "[$iSOB of $SOBCount]"
                    Log          = $_.Exception.Message
                    Identity     = $SendOnBehalf.PrimarySmtpAddress
                    Trustee      = $SendOnBehalf.GrantedSMTP
                    AccessRights = 'SENDONBEHALF'
                }
            }
        }
    }
}
