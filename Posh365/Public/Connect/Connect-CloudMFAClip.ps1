function Connect-CloudMFAClip {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [Parameter(Mandatory, Position = 0)]
        $CredFile
    )
    end {
        Microsoft.PowerShell.Utility\Add-Type -As System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Click OK to copy password to clipboard")
        [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
        $Credential.GetNetworkCredential().Password | CLIP
    }
}
