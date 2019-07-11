function Connect-CloudMFAClip {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [Parameter(Mandatory, Position = 0)]
        $CredFile
    )
    end {
        Add-Type -AssemblyName System.Windows.Forms
        $button = [System.Windows.Forms.MessageBox]::Show('Press OK Clip Password')
        If ($button -eq 'OK') {
            [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
            $credential.GetNetworkCredential().Password | Set-Clipboard
        }
    }
}
