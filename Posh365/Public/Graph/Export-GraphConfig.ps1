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

        $TenantConfigExportBT = New-Object system.Windows.Forms.Button
        $TenantConfigExportBT.text = "Export Tenant Config"
        $TenantConfigExportBT.width = 375
        $TenantConfigExportBT.height = 30
        $TenantConfigExportBT.Anchor = 'top,right,left'
        $TenantConfigExportBT.location = New-Object System.Drawing.Point(13, 136)
        $TenantConfigExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
        $TenantConfigExportBT.ForeColor = "#cecece"
        $TenantConfigExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $TenantConfigExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
        $TenantConfigExportBT.FlatAppearance.BorderSize = 0
        $TenantConfigExportBT.BackColor = "#171717"

        $TenantCredsExportBT = New-Object system.Windows.Forms.Button
        $TenantCredsExportBT.text = "Export Tenant Credentials"
        $TenantCredsExportBT.width = 375
        $TenantCredsExportBT.height = 30
        $TenantCredsExportBT.Anchor = 'top,right,left'
        $TenantCredsExportBT.location = New-Object System.Drawing.Point(13, 240)
        $TenantCredsExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
        $TenantCredsExportBT.ForeColor = "#cecece"
        $TenantCredsExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $TenantCredsExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
        $TenantCredsExportBT.FlatAppearance.BorderSize = 0
        $TenantCredsExportBT.BackColor = "#171717"

        $ClientInfoTB = New-Object system.Windows.Forms.TextBox
        $ClientInfoTB.multiline = $true
        $ClientInfoTB.width = 390
        $ClientInfoTB.height = 120
        $ClientInfoTB.Anchor = 'top,right,left'
        $ClientInfoTB.location = New-Object System.Drawing.Point(5, 300)
        $ClientInfoTB.Font = 'Microsoft Sans Serif,10'
        $ClientInfoTB.BackColor = "#000000"
        $ClientInfoTB.ForeColor = "#5bde09"
        $ClientInfoTB.BorderStyle = "none"

        $TenantLB = New-Object system.Windows.Forms.Label
        $TenantLB.text = $Tenant
        $TenantLB.AutoSize = $true
        $TenantLB.width = 25
        $TenantLB.height = 10
        $TenantLB.location = New-Object System.Drawing.Point(173, 9)
        $TenantLB.Font = 'Microsoft Sans Serif,14,style=Bold'
        $TenantLB.ForeColor = "#cecece"

        $ClientIDLBTenant = New-Object system.Windows.Forms.Label
        $ClientIDLBTenant.text = "Client ID:"
        $ClientIDLBTenant.AutoSize = $true
        $ClientIDLBTenant.width = 25
        $ClientIDLBTenant.height = 10
        $ClientIDLBTenant.location = New-Object System.Drawing.Point(13, 36)
        $ClientIDLBTenant.Font = 'Microsoft Sans Serif,10'
        $ClientIDLBTenant.ForeColor = "#cecece"

        $ClientIDTBTenant = New-Object system.Windows.Forms.TextBox
        $ClientIDTBTenant.multiline = $false
        $ClientIDTBTenant.BackColor = "#171717"
        $ClientIDTBTenant.width = 300
        $ClientIDTBTenant.height = 30
        $ClientIDTBTenant.location = New-Object System.Drawing.Point(93, 36)
        $ClientIDTBTenant.Font = 'Microsoft Sans Serif,10'
        $ClientIDTBTenant.ForeColor = "#ffffff"
        $ClientIDTBTenant.BorderStyle = "None"

        $TenantIDLBTenant = New-Object system.Windows.Forms.Label
        $TenantIDLBTenant.text = "Tenant ID:"
        $TenantIDLBTenant.AutoSize = $true
        $TenantIDLBTenant.width = 25
        $TenantIDLBTenant.height = 10
        $TenantIDLBTenant.location = New-Object System.Drawing.Point(13, 72)
        $TenantIDLBTenant.Font = 'Microsoft Sans Serif,10'
        $TenantIDLBTenant.ForeColor = "#cecece"

        $TenantIDTBTenant = New-Object system.Windows.Forms.TextBox
        $TenantIDTBTenant.multiline = $false
        $TenantIDTBTenant.width = 294
        $TenantIDTBTenant.height = 30
        $TenantIDTBTenant.location = New-Object System.Drawing.Point(93, 73)
        $TenantIDTBTenant.Font = 'Microsoft Sans Serif,10'
        $TenantIDTBTenant.BackColor = "#171717"
        $TenantIDTBTenant.ForeColor = "#ffffff"
        $TenantIDTBTenant.BorderStyle = "None"

        $ClientSecLBTenant = New-Object system.Windows.Forms.Label
        $ClientSecLBTenant.text = "Secret:"
        $ClientSecLBTenant.AutoSize = $true
        $ClientSecLBTenant.width = 25
        $ClientSecLBTenant.height = 10
        $ClientSecLBTenant.location = New-Object System.Drawing.Point(13, 105)
        $ClientSecLBTenant.Font = 'Microsoft Sans Serif,10'
        $ClientSecLBTenant.ForeColor = "#cecece"

        $ClientSecLBdest = New-Object system.Windows.Forms.Label
        $ClientSecLBdest.text = "Client Secret:"
        $ClientSecLBdest.AutoSize = $true
        $ClientSecLBdest.width = 25
        $ClientSecLBdest.height = 10
        $ClientSecLBdest.Anchor = 'top,right'
        $ClientSecLBdest.location = New-Object System.Drawing.Point(13, 105)
        $ClientSecLBdest.Font = 'Microsoft Sans Serif,10'
        $ClientSecLBdest.ForeColor = "#cecece"

        $ClientSecTBTenant = New-Object system.Windows.Forms.MaskedTextBox
        $ClientsecTBTenant.PasswordChar = '*'
        $ClientSecTBTenant.multiline = $false
        $ClientSecTBTenant.width = 276
        $ClientSecTBTenant.height = 30
        $ClientSecTBTenant.location = New-Object System.Drawing.Point(93, 107)
        $ClientSecTBTenant.Font = 'Microsoft Sans Serif,10'
        $ClientSecTBTenant.BackColor = "#171717"
        $ClientSecTBTenant.ForeColor = "#ffffff"
        $ClientSecTBTenant.BorderStyle = "None"

        $ClientSecTBdest = New-Object system.Windows.Forms.MaskedTextBox
        $ClientsecTBdest.PasswordChar = '*'
        $ClientSecTBdest.multiline = $false
        $ClientSecTBdest.width = 276
        $ClientSecTBdest.height = 30
        $ClientSecTBdest.Anchor = 'top'
        $ClientSecTBdest.location = New-Object System.Drawing.Point(93, 107)
        $ClientSecTBdest.Font = 'Microsoft Sans Serif,10'
        $ClientSecTBdest.BackColor = "#171717"
        $ClientSecTBdest.ForeColor = "#ffffff"
        $ClientSecTBdest.BorderStyle = "None"

        $UsernameLBTenant = New-Object system.Windows.Forms.Label
        $UsernameLBTenant.text = "Username:"
        $UsernameLBTenant.AutoSize = $true
        $UsernameLBTenant.width = 25
        $UsernameLBTenant.height = 10
        $UsernameLBTenant.location = New-Object System.Drawing.Point(13, 180)
        $UsernameLBTenant.Font = 'Microsoft Sans Serif,10'
        $UsernameLBTenant.ForeColor = "#cecece"

        $UsernameTBTenant = New-Object system.Windows.Forms.TextBox
        $UsernameTBTenant.multiline = $false
        $UsernameTBTenant.width = 290
        $UsernameTBTenant.height = 30
        $UsernameTBTenant.location = New-Object System.Drawing.Point(96, 180)
        $UsernameTBTenant.Font = 'Microsoft Sans Serif,10'
        $UsernameTBTenant.BackColor = "#171717"
        $UsernameTBTenant.ForeColor = "#ffffff"
        $UsernameTBTenant.BorderStyle = "None"

        $UsernameTBdest = New-Object system.Windows.Forms.TextBox
        $UsernameTBdest.multiline = $false
        $UsernameTBdest.width = 290
        $UsernameTBdest.height = 30
        $UsernameTBdest.Anchor = 'top'
        $UsernameTBdest.location = New-Object System.Drawing.Point(96, 180)
        $UsernameTBdest.Font = 'Microsoft Sans Serif,10'
        $UsernameTBdest.BackColor = "#171717"
        $UsernameTBdest.ForeColor = "#ffffff"
        $UsernameTBdest.BorderStyle = "None"

        $PasswordLBTenant = New-Object system.Windows.Forms.Label
        $PasswordLBTenant.text = "Password:"
        $PasswordLBTenant.AutoSize = $true
        $PasswordLBTenant.width = 25
        $PasswordLBTenant.height = 10
        $PasswordLBTenant.location = New-Object System.Drawing.Point(13, 210)
        $PasswordLBTenant.Font = 'Microsoft Sans Serif,10'
        $PasswordLBTenant.ForeColor = "#cecece"

        $PasswordMTBTenant = New-Object system.Windows.Forms.MaskedTextBox
        $PasswordMTBTenant.multiline = $false
        $PasswordMTBTenant.width = 291
        $PasswordMTBTenant.height = 30
        $PasswordMTBTenant.location = New-Object System.Drawing.Point(95, 210)
        $PasswordMTBTenant.Font = 'Microsoft Sans Serif,10'
        $PasswordMTBTenant.PasswordChar = '*'
        $PasswordMTBTenant.BackColor = "#171717"
        $PasswordMTBTenant.ForeColor = "#ffffff"
        $PasswordMTBTenant.BorderStyle = "None"

        # $PasswordMTBdest = New-Object system.Windows.Forms.MaskedTextBox
        # $PasswordMTBdest.multiline = $false
        # $PasswordMTBdest.width = 291
        # $PasswordMTBdest.height = 30
        # $PasswordMTBdest.location = New-Object System.Drawing.Point(95, 210)
        # $PasswordMTBdest.Font = 'Microsoft Sans Serif,10'
        # $PasswordMTBdest.PasswordChar = '*'
        # $PasswordMTBdest.BackColor = "#171717"
        # $PasswordMTBdest.ForeColor = "#ffffff"
        # $PasswordMTBdest.BorderStyle = "None"

        # $DestPanel = New-Object system.Windows.Forms.Panel
        # $DestPanel.height = 290
        # $DestPanel.width = 388
        # $DestPanel.Anchor = 'top,right'
        # $DestPanel.location = New-Object System.Drawing.Point(397, 4)

        # $DestConfigExportBT = New-Object system.Windows.Forms.Button
        # $DestConfigExportBT.text = "Export Destination Config"
        # $DestConfigExportBT.width = 375
        # $DestConfigExportBT.height = 30
        # $DestConfigExportBT.Anchor = 'top,right,left'
        # $DestConfigExportBT.location = New-Object System.Drawing.Point(13, 136)
        # $DestConfigExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
        # $DestConfigExportBT.ForeColor = "#cecece"
        # $DestConfigExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        # $DestConfigExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
        # $DestConfigExportBT.FlatAppearance.BorderSize = 0
        # $DestConfigExportBT.BackColor = "#171717"

        # $DestCredsExportBT = New-Object system.Windows.Forms.Button
        # $DestCredsExportBT.text = "Export Destination Credentials"
        # $DestCredsExportBT.width = 375
        # $DestCredsExportBT.height = 30
        # $DestCredsExportBT.Anchor = 'top,right,left'
        # $DestCredsExportBT.location = New-Object System.Drawing.Point(13, 240)
        # $DestCredsExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
        # $DestCredsExportBT.ForeColor = "#cecece"
        # $DestCredsExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        # $DestCredsExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
        # $DestCredsExportBT.FlatAppearance.BorderSize = 0
        # $DestCredsExportBT.BackColor = "#171717"

        # $DestinationLB = New-Object system.Windows.Forms.Label
        # $DestinationLB.text = "Destination"
        # $DestinationLB.AutoSize = $true
        # $DestinationLB.width = 25
        # $DestinationLB.height = 10
        # $DestinationLB.Anchor = 'top'
        # $DestinationLB.location = New-Object System.Drawing.Point(162, 7)
        # $DestinationLB.Font = 'Microsoft Sans Serif,10,style=Bold,Underline'
        # $DestinationLB.ForeColor = "#cecece"

        # $ClientIDLBdest = New-Object system.Windows.Forms.Label
        # $ClientIDLBdest.text = "Client ID:"
        # $ClientIDLBdest.AutoSize = $true
        # $ClientIDLBdest.width = 25
        # $ClientIDLBdest.height = 10
        # $ClientIDLBdest.location = New-Object System.Drawing.Point(13, 36)
        # $ClientIDLBdest.Font = 'Microsoft Sans Serif,10'
        # $ClientIDLBdest.ForeColor = "#cecece"

        # $ClientIDTBdest = New-Object system.Windows.Forms.TextBox
        # $ClientIDTBdest.multiline = $false
        # $ClientIDTBdest.width = 300
        # $ClientIDTBdest.height = 30
        # $ClientIDTBdest.Anchor = 'top'
        # $ClientIDTBdest.location = New-Object System.Drawing.Point(88, 36)
        # $ClientIDTBdest.Font = 'Microsoft Sans Serif,10'
        # $ClientIDTBdest.BackColor = "#171717"
        # $ClientIDTBdest.ForeColor = "#ffffff"
        # $ClientIDTBdest.BorderStyle = "None"

        # $TenantIDLBdest = New-Object system.Windows.Forms.Label
        # $TenantIDLBdest.text = "Tenant ID:"
        # $TenantIDLBdest.AutoSize = $true
        # $TenantIDLBdest.width = 25
        # $TenantIDLBdest.height = 10
        # $TenantIDLBdest.Anchor = 'top,right'
        # $TenantIDLBdest.location = New-Object System.Drawing.Point(13, 72)
        # $TenantIDLBdest.Font = 'Microsoft Sans Serif,10'
        # $TenantIDLBdest.ForeColor = "#cecece"

        # $TenantIDTBdest = New-Object system.Windows.Forms.TextBox
        # $TenantIDTBdest.multiline = $false
        # $TenantIDTBdest.width = 294
        # $TenantIDTBdest.height = 30
        # $TenantIDTBdest.Anchor = 'top'
        # $TenantIDTBdest.location = New-Object System.Drawing.Point(93, 73)
        # $TenantIDTBdest.Font = 'Microsoft Sans Serif,10'
        # $TenantIDTBdest.BackColor = "#171717"
        # $TenantIDTBdest.ForeColor = "#ffffff"
        # $TenantIDTBdest.BorderStyle = "None"

        # $UsernameLBdest = New-Object system.Windows.Forms.Label
        # $UsernameLBdest.text = "Username:"
        # $UsernameLBdest.AutoSize = $true
        # $UsernameLBdest.width = 25
        # $UsernameLBdest.height = 10
        # $UsernameLBdest.Anchor = 'top,right'
        # $UsernameLBdest.location = New-Object System.Drawing.Point(13, 180)
        # $UsernameLBdest.Font = 'Microsoft Sans Serif,10'
        # $UsernameLBdest.ForeColor = "#cecece"

        # $PasswordLBdest = New-Object system.Windows.Forms.Label
        # $PasswordLBdest.text = "Password:"
        # $PasswordLBdest.AutoSize = $true
        # $PasswordLBdest.width = 25
        # $PasswordLBdest.height = 10
        # $PasswordLBdest.Anchor = 'top,right'
        # $PasswordLBdest.location = New-Object System.Drawing.Point(13, 210)
        # $PasswordLBdest.Font = 'Microsoft Sans Serif,10'
        # $PasswordLBdest.ForeColor = "#cecece"

        $Form.controls.AddRange(@($ConnectionPanel, $TenantPanel, $ClientInfoTB))

        $TenantPanel.controls.AddRange(@(
                $TenantLB, $ClientIDLBTenant, $ClientIDTBTenant, $TenantIDLBTenant, $TenantIDTBTenant
                $ClientSecLBTenant, $ClientSecTBTenant, $UsernameLBTenant, $UsernameTBTenant, $PasswordLBTenant
                $PasswordMTBTenant, $TenantConfigExportBT, $TenantCredsExportBT
            ))
        # $DestPanel.controls.AddRange(@(
        #         $DestinationLB, $ClientIDLBdest, $ClientIDTBdest, $TenantIDLBdest, $TenantIDTBdest, $ClientSecLBdest
        #         $ClientSecTBdest, $UsernameLBdest, $UsernameTBdest, $PasswordLBdest, $PasswordMTBdest, $DestConfigExportBT, $DestCredsExportBT
        #     ))
        #################
        # Tenant CONFIG #
        #################
        $TenantConfigExportBT.Add_Click(
            {
                try {
                    # Remove SCRIPT Scope
                    $Script:TenantObject = [PSCustomObject]@{
                        TenantClientID = $ClientIDTBTenant.text
                        TenantTenantID = $TenantIDTBTenant.text
                        TenantSecret   = $ClientSecTBTenant.text | ConvertTo-SecureString -AsPlainText -Force
                    }
                    $TenantConfig = Join-Path -Path $TenantPath -ChildPath ('{0}Config.xml' -f $Tenant)
                    [PSCustomObject]@{
                        Cred     = [PSCredential]::new($TenantObject.TenantTenantID, $TenantObject.TenantSecret)
                        ClientId = $TenantObject.TenantClientID
                    } | Export-Clixml -Path $TenantConfig
                    $ClientInfoTB.AppendText(('Tenant configuration encrypted to: {0}{1}' -f $TenantConfig, [Environment]::NewLine))
                }
                catch {
                    $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
                }
            }
        )
        #################
        # DEST   CONFIG #
        #################
        # $DestConfigExportBT.Add_Click(
        #     {
        #         try {
        #             $Script:DestObject = [PSCustomObject]@{
        #                 DestClientID = $ClientIDTBdest.text
        #                 DestTenantID = $TenantIDTBdest.text
        #                 DestSecret   = $ClientSecTBdest.text | ConvertTo-SecureString -AsPlainText -Force
        #             }
        #             $DestConfig = Join-Path -Path $DestinationPath -ChildPath ('{0}Config.xml' -f $Destination)
        #             [PSCustomObject]@{
        #                 Cred     = [PSCredential]::new($DestObject.DestTenantID, $DestObject.DestSecret)
        #                 ClientId = $DestObject.DestClientID
        #             } | Export-Clixml -Path $DestConfig
        #             $ClientInfoTB.AppendText(('Destination configuration encrypted to: {0}{1}' -f $DestConfig, [Environment]::NewLine))
        #         }
        #         catch {
        #             $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
        #         }
        #     }
        # )
        #################
        # Tenant  CREDS #
        #################
        $TenantCredsExportBT.Add_Click(
            {
                try {
                    $Script:TenantCredObj = [PSCustomObject]@{
                        TenantUsername = $UsernameTBTenant.text
                        TenantPassword = $PasswordMTBTenant.text | ConvertTo-SecureString -AsPlainText -Force
                    }
                    $TenantCred = Join-Path -Path $TenantPath -ChildPath ('{0}Cred.xml' -f $Tenant)
                    [PSCredential]::new($TenantCredObj.TenantUsername, $TenantCredObj.TenantPassword) | Export-Clixml -Path $TenantCred

                    $ClientInfoTB.AppendText(('Tenant credential encrypted to: {0}{1}' -f $TenantCred, [Environment]::NewLine))
                }
                catch {
                    $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
                }
            }
        )
        #################
        # DEST    CREDS #
        #################
        # $DestCredsExportBT.Add_Click(
        #     {
        #         try {
        #             $Script:DestCredObj = [PSCustomObject]@{
        #                 DestUsername = $UsernameTBdest.text
        #                 DestPassword = $PasswordMTBdest.text | ConvertTo-SecureString -AsPlainText -Force
        #             }
        #             $DestCred = Join-Path -Path $DestinationPath -ChildPath ('{0}Cred.xml' -f $Destination)
        #             [PSCredential]::new($DestCredObj.DestUsername, $DestCredObj.DestPassword) | Export-Clixml -Path $DestCred
        #             $ClientInfoTB.AppendText(('Destination credential encrypted to: {0}{1}' -f $DestCred, [Environment]::NewLine))
        #         }
        #         catch {
        #             $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
        #         }
        #     }
        # )
        [void]$Form.ShowDialog()
    }
}
