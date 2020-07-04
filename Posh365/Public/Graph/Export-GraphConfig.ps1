function Export-GraphConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Tenant
    )
    Get-RSJob -State Completed | Remove-RSJob -force
    $null = Start-RSJob -ArgumentList $Tenant -ScriptBlock {
        param($Tenant)
        $PoshPath = Join-Path -Path $Env:USERPROFILE -ChildPath '.Posh365/Credentials/Graph'
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
        }
        if (-not (Test-Path $PoshPath)) { New-Item $PoshPath @ItemSplat }
        $TenantPath = Join-Path -Path $PoshPath -ChildPath $Tenant
        if (-not (Test-Path $TenantPath)) { $null = New-Item $TenantPath @ItemSplat }

        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Application]::EnableVisualStyles()

        $Form = New-Object system.Windows.Forms.Form
        $Form.ClientSize = '400,450'
        $Form.text = "Microsoft Graph Credential Export Tool"
        $Form.BackColor = "#354CA1"
        $Form.TopMost = $true
        $Form.FormBorderStyle = "FixedDialog"
        $Form.ShowInTaskbar = $true
        $Form.StartPosition = "centerscreen"

        $TenantPanel = New-Object system.Windows.Forms.Panel
        $TenantPanel.height = 290
        $TenantPanel.width = 388
        $TenantPanel.location = New-Object System.Drawing.Point(5, 4)

        $TenantConfigExportButton = New-Object system.Windows.Forms.Button
        $TenantConfigExportButton.text = "Export Tenant Config"
        $TenantConfigExportButton.width = 375
        $TenantConfigExportButton.height = 30
        $TenantConfigExportButton.Anchor = 'top,right,left'
        $TenantConfigExportButton.location = New-Object System.Drawing.Point(13, 136)
        $TenantConfigExportButton.Font = 'Microsoft Sans Serif,10,style=Bold'
        $TenantConfigExportButton.ForeColor = "#cecece"
        $TenantConfigExportButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $TenantConfigExportButton.FlatAppearance.BorderColor = [System.Drawing.Color]::black
        $TenantConfigExportButton.FlatAppearance.BorderSize = 0
        $TenantConfigExportButton.BackColor = "#171717"

        $TenantCredsExportButton = New-Object system.Windows.Forms.Button
        $TenantCredsExportButton.text = "Export Tenant Credentials"
        $TenantCredsExportButton.width = 375
        $TenantCredsExportButton.height = 30
        $TenantCredsExportButton.Anchor = 'top,right,left'
        $TenantCredsExportButton.location = New-Object System.Drawing.Point(13, 240)
        $TenantCredsExportButton.Font = 'Microsoft Sans Serif,10,style=Bold'
        $TenantCredsExportButton.ForeColor = "#cecece"
        $TenantCredsExportButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $TenantCredsExportButton.FlatAppearance.BorderColor = [System.Drawing.Color]::black
        $TenantCredsExportButton.FlatAppearance.BorderSize = 0
        $TenantCredsExportButton.BackColor = "#171717"

        $ClientInfoTextBox = New-Object system.Windows.Forms.TextBox
        $ClientInfoTextBox.multiline = $true
        $ClientInfoTextBox.width = 390
        $ClientInfoTextBox.height = 130
        $ClientInfoTextBox.Anchor = 'top,right,left'
        $ClientInfoTextBox.location = New-Object System.Drawing.Point(5, 300)
        $ClientInfoTextBox.Font = 'Microsoft Sans Serif,10'
        $ClientInfoTextBox.BackColor = "#000000"
        $ClientInfoTextBox.ForeColor = "#5bde09"
        $ClientInfoTextBox.BorderStyle = "none"

        $TenantLabel = New-Object system.Windows.Forms.Label
        $TenantLabel.text = $Tenant
        $TenantLabel.AutoSize = $true
        $TenantLabel.width = 25
        $TenantLabel.height = 10
        $TenantLabel.location = New-Object System.Drawing.Point(173, 9)
        $TenantLabel.Font = 'Microsoft Sans Serif,14,style=Bold'
        $TenantLabel.ForeColor = "#cecece"

        $ClientIDLabel = New-Object system.Windows.Forms.Label
        $ClientIDLabel.text = "Client ID:"
        $ClientIDLabel.AutoSize = $true
        $ClientIDLabel.width = 25
        $ClientIDLabel.height = 10
        $ClientIDLabel.location = New-Object System.Drawing.Point(13, 36)
        $ClientIDLabel.Font = 'Microsoft Sans Serif,10'
        $ClientIDLabel.ForeColor = "#cecece"

        $ClientIDTextBox = New-Object system.Windows.Forms.TextBox
        $ClientIDTextBox.multiline = $false
        $ClientIDTextBox.BackColor = "#171717"
        $ClientIDTextBox.width = 300
        $ClientIDTextBox.height = 30
        $ClientIDTextBox.location = New-Object System.Drawing.Point(93, 36)
        $ClientIDTextBox.Font = 'Microsoft Sans Serif,10'
        $ClientIDTextBox.ForeColor = "#ffffff"
        $ClientIDTextBox.BorderStyle = "None"

        $TenantIDLabel = New-Object system.Windows.Forms.Label
        $TenantIDLabel.text = "Tenant ID:"
        $TenantIDLabel.AutoSize = $true
        $TenantIDLabel.width = 25
        $TenantIDLabel.height = 10
        $TenantIDLabel.location = New-Object System.Drawing.Point(13, 73)
        $TenantIDLabel.Font = 'Microsoft Sans Serif,10'
        $TenantIDLabel.ForeColor = "#cecece"

        $TenantIDTextBox = New-Object system.Windows.Forms.TextBox
        $TenantIDTextBox.multiline = $false
        $TenantIDTextBox.width = 294
        $TenantIDTextBox.height = 30
        $TenantIDTextBox.location = New-Object System.Drawing.Point(93, 73)
        $TenantIDTextBox.Font = 'Microsoft Sans Serif,10'
        $TenantIDTextBox.BackColor = "#171717"
        $TenantIDTextBox.ForeColor = "#ffffff"
        $TenantIDTextBox.BorderStyle = "None"

        $ClientSecLabel = New-Object system.Windows.Forms.Label
        $ClientSecLabel.text = "Secret:"
        $ClientSecLabel.AutoSize = $true
        $ClientSecLabel.width = 25
        $ClientSecLabel.height = 10
        $ClientSecLabel.location = New-Object System.Drawing.Point(13, 105)
        $ClientSecLabel.Font = 'Microsoft Sans Serif,10'
        $ClientSecLabel.ForeColor = "#cecece"

        $ClientSecTextBox = New-Object system.Windows.Forms.MaskedTextBox
        $ClientsecTextBox.PasswordChar = '*'
        $ClientSecTextBox.multiline = $false
        $ClientSecTextBox.width = 294
        $ClientSecTextBox.height = 30
        $ClientSecTextBox.location = New-Object System.Drawing.Point(93, 107)
        $ClientSecTextBox.Font = 'Microsoft Sans Serif,10'
        $ClientSecTextBox.BackColor = "#171717"
        $ClientSecTextBox.ForeColor = "#ffffff"
        $ClientSecTextBox.BorderStyle = "None"

        $UsernameLabel = New-Object system.Windows.Forms.Label
        $UsernameLabel.text = "Username:"
        $UsernameLabel.AutoSize = $true
        $UsernameLabel.width = 25
        $UsernameLabel.height = 10
        $UsernameLabel.location = New-Object System.Drawing.Point(13, 180)
        $UsernameLabel.Font = 'Microsoft Sans Serif,10'
        $UsernameLabel.ForeColor = "#cecece"

        $UsernameTextBox = New-Object system.Windows.Forms.TextBox
        $UsernameTextBox.multiline = $false
        $UsernameTextBox.width = 290
        $UsernameTextBox.height = 30
        $UsernameTextBox.location = New-Object System.Drawing.Point(96, 180)
        $UsernameTextBox.Font = 'Microsoft Sans Serif,10'
        $UsernameTextBox.BackColor = "#171717"
        $UsernameTextBox.ForeColor = "#ffffff"
        $UsernameTextBox.BorderStyle = "None"

        $PasswordLabel = New-Object system.Windows.Forms.Label
        $PasswordLabel.text = "Password:"
        $PasswordLabel.AutoSize = $true
        $PasswordLabel.width = 25
        $PasswordLabel.height = 10
        $PasswordLabel.location = New-Object System.Drawing.Point(13, 210)
        $PasswordLabel.Font = 'Microsoft Sans Serif,10'
        $PasswordLabel.ForeColor = "#cecece"

        $PasswordMTextBox = New-Object system.Windows.Forms.MaskedTextBox
        $PasswordMTextBox.multiline = $false
        $PasswordMTextBox.width = 291
        $PasswordMTextBox.height = 30
        $PasswordMTextBox.location = New-Object System.Drawing.Point(95, 210)
        $PasswordMTextBox.Font = 'Microsoft Sans Serif,10'
        $PasswordMTextBox.PasswordChar = '*'
        $PasswordMTextBox.BackColor = "#171717"
        $PasswordMTextBox.ForeColor = "#ffffff"
        $PasswordMTextBox.BorderStyle = "None"

        $Form.controls.AddRange(@($ConnectionPanel, $TenantPanel, $ClientInfoTextBox))

        $TenantPanel.controls.AddRange(@(
                $TenantLabel, $ClientIDLabel, $ClientIDTextBox, $TenantIDLabel, $TenantIDTextBox
                $ClientSecLabel, $ClientSecTextBox, $UsernameLabel, $UsernameTextBox, $PasswordLabel
                $PasswordMTextBox, $TenantConfigExportButton, $TenantCredsExportButton
            ))
        $TenantConfigExportButton.Add_Click(
            {
                try {
                    $Script:TenantObject = [PSCustomObject]@{
                        TenantClientID = $ClientIDTextBox.text
                        TenantTenantID = $TenantIDTextBox.text
                        TenantSecret   = $ClientSecTextBox.text | ConvertTo-SecureString -AsPlainText -Force
                    }
                    $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Tenant)
                    [PSCustomObject]@{
                        Cred     = [PSCredential]::new($TenantObject.TenantTenantID, $TenantObject.TenantSecret)
                        ClientId = $TenantObject.TenantClientID
                    } | Export-Clixml -Path $TenantConfig
                    $ClientInfoTextBox.AppendText(('Tenant configuration encrypted to: {0}{1}' -f $TenantConfig, [Environment]::NewLine))
                }
                catch {
                    $ClientInfoTextBox.AppendText(($_.Exception.Message, [Environment]::NewLine))
                }
            }
        )
        $TenantCredsExportButton.Add_Click(
            {
                try {
                    $Script:TenantCredObj = [PSCustomObject]@{
                        TenantUsername = $UsernameTextBox.text
                        TenantPassword = $PasswordMTextBox.text | ConvertTo-SecureString -AsPlainText -Force
                    }
                    $TenantCred = Join-Path -Path $TenantPath -ChildPath ('{0}Cred.xml' -f $Tenant)
                    [PSCredential]::new($TenantCredObj.TenantUsername, $TenantCredObj.TenantPassword) | Export-Clixml -Path $TenantCred

                    $ClientInfoTextBox.AppendText(('Tenant credential encrypted to: {0}{1}' -f $TenantCred, [Environment]::NewLine))
                }
                catch {
                    $ClientInfoTextBox.AppendText(($_.Exception.Message, [Environment]::NewLine))
                }
            }
        )
        [void]$Form.ShowDialog()
    }
}
