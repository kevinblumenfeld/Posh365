function Connect-CloudMFARunspace {
    param (
        [Parameter(Mandatory)]
        [string]
        $CredFile
    )
    $RunspaceCollection = @()
    [Collections.Arraylist]$Results = @()
    $RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, 2)
    $RunspacePool.Open()

    $BlockConnect = {
        Connect-CloudMFA -Tenant mkevin -ExchangeOnline
    }
    $BlockBox = {
        Add-Type -AssemblyName System.Windows.Forms
        $button = [System.Windows.Forms.MessageBox]::Show('Press OK Clip Password')
        If ($button -eq 'OK') {
            [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path 'C:\Users\kevin.blumenfeld\.posh365\mkevin\Credentials\CC.xml'
            $credential.GetNetworkCredential().Password | Set-Clipboard
        }
    }
    $Powershell = [PowerShell]::Create().AddScript($BlockConnect)
    $Powershell = [PowerShell]::Create().AddScript($BlockBox)
    $Powershell.RunspacePool = $RunspacePool

    [Collections.Arraylist]$RunspaceCollection += New-Object -TypeName PSObject -Property @{
        Runspace   = $PowerShell.BeginInvoke()
        PowerShell = $PowerShell
    }
    [Collections.Arraylist]$RunspaceCollection += New-Object -TypeName PSObject -Property @{
        Runspace   = $PowerShell.BeginInvoke()
        PowerShell = $PowerShell
    }
    While ($RunspaceCollection) {
        Foreach ($Runspace in $RunspaceCollection.ToArray()) {
            If ($Runspace.Runspace.IsCompleted) {
                [void]$Results.Add($Runspace.PowerShell.EndInvoke($Runspace.Runspace))
                $Runspace.PowerShell.Dispose()
                $RunspaceCollection.Remove($Runspace)
            }
        }
    }
    $Results
}
