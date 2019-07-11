function Connect-CloudMFAClip {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory, Position = 0)]
        $CredFile
    )
    end {
        [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
        $Username = $Credential.Username
        $Password = $Credential.GetNetworkCredential().Password
        Start-RSJob -ArgumentList $Username, $Password -ScriptBlock {
            param($Username, $Password)
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.Application]::EnableVisualStyles()

            $Posh365 = New-Object system.Windows.Forms.Form
            $Posh365.ClientSize = '400,400'
            $Posh365.text = "Posh365"
            $Posh365.BackColor = "#4a90e2"
            $Posh365.TopMost = $false

            $Username = New-Object system.Windows.Forms.Button
            $Username.BackColor = "#ffffff"
            $Username.text = "Copy Username"
            $Username.width = 377
            $Username.height = 68
            $Username.location = New-Object System.Drawing.Point(8, 25)
            $Username.Font = 'Microsoft Sans Serif,30,style=Bold'
            $Username.ForeColor = "#000000"
            $Username.Add_Click( { $Using:Username | CLIP })

            $Password = New-Object system.Windows.Forms.Button
            $Password.BackColor = "#ffffff"
            $Password.text = "Copy Password"
            $Password.width = 377
            $Password.height = 68
            $Password.location = New-Object System.Drawing.Point(8, 100)
            $Password.Font = 'Microsoft Sans Serif,30,style=Bold'
            $Password.ForeColor = "#000000"
            $Password.Add_Click( { $Using:Password | CLIP })

            $Posh365.controls.AddRange(@($Username, $Password))

            [void]$Posh365.ShowDialog()
        }
    }
}
