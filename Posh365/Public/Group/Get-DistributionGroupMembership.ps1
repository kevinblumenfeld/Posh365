function Get-DistributionGroupMembership {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string[]]$Identity,
        [switch]$Recurse,
        [string[]]$Processed
    )
    begin {
        if (-not $processed) {
            $Processed = @()
        }
    }    
    process {
        foreach ($CurIdentity in $Identity) {
            if (-not $PSCmdlet.ShouldProcess($CurIdentity)) {
                continue
            }
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
            $Filter = "members -eq '{0}'" -f $Recipient.DistinguishedName
            Get-Group -ResultSize Unlimited -filter $Filter | 
                Where-Object {$_.WindowsEmailAddress -notin $Processed} |
                ForEach-Object {
                $_
                $Results += $_
            }
            if (-not $Recurse) {
                continue
            }
            Foreach ($Result in $Results) {
                #Skip "Office 365 Groups" as they fail recipient checks and cannot be members of other groups
                if ($Result.RecipientTypeDetails -in 'NonUniversalGroup', 'GroupMailbox') {
                    Continue
                }
                Write-Verbose "Start recursing for '$($Result.WindowsEmailAddress)'."
                Get-DGMembership -Identity $Result.Guid.ToString() -Recurse -Processed $Processed
                Write-Verbose "Done recursing for '$($Result.WindowsEmailAddress)'."
            }#End Foreach result
        } #End Foreach Identity
    } #End Process
} #End Function