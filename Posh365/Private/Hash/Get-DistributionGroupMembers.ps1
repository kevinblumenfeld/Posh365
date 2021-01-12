function Get-DistributionGroupMembers {
    <#

    .SYNOPSIS
    needs to be moved to the new code Get-DistributionGroupMembership

    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$Identity,

        [Parameter()]
        [switch]$Recurse,

        [Parameter()]
        [string[]]$Processed
    )
    begin {
        if (-not $processed) {
            $Processed = @()
        }
    }
    process {
        foreach ($CurIdentity in $Identity) {
            Write-Verbose "Looking up memberships for '$CurIdentity'."
            try {
                $Recipient = Get-Recipient -Identity $CurIdentity -ErrorAction Stop
            }
            catch {
                $ErrorMessage = $_.exception.message
                $Message = "Unable to find recipient '{0}': {1}" -f $CurIdentity, $ErrorMessage
                Write-Error $Message
                continue
            }
            Write-Verbose "Adding '$($Recipient.PrimarySmtpAddress)' to processed list"
            $Processed += $Recipient.PrimarySmtpAddress
            $Results = @()
            Write-Verbose "RTD: '$($Recipient.RecipientTypeDetails)'"
            Get-DistributionGroupMember -Identity $Recipient.DistinguishedName -ResultSize Unlimited |
            Where-Object { $_.PrimarySmtpAddress -notin $Processed } |
            ForEach-Object {
                $_ | Where-Object { $_.RecipientTypeDetails -notin 'NonUniversalGroup', 'GroupMailbox', 'RoleGroup', 'MailNonUniversalGroup', 'MailUniversalSecurityGroup', 'MailUniversalDistributionGroup', 'DynamicDistributionGroup', 'PublicFolder', 'UniversalDistributionGroup', 'UniversalSecurityGroup', 'NonUniversalGroup' } | Select-Object -ExpandProperty DistinguishedName
                $Results += $_
            }
            if (-not $Recurse) {
                continue
            }
            Foreach ($Result in $Results) {
                #Skip "Office 365 Groups" as they fail recipient checks and cannot be members of other groups
                if ($Result.RecipientTypeDetails -in 'NonUniversalGroup', 'GroupMailbox', 'RoleGroup', 'UserMailbox') {
                    Continue
                }
                Write-Verbose "Start recursing for '$($Result.PrimarySmtpAddress)'."
                Get-DistributionGroupMembers -Identity $Result.Guid.ToString() -Recurse -Processed $Processed
                Write-Verbose "Done recursing for '$($Result.PrimarySmtpAddress)'."
            }#End Foreach result
        } #End Foreach Identity
    } #End Process
} #End Function