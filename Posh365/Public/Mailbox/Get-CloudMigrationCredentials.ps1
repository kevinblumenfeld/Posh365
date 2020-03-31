function Get-CloudMigrationCredentials {


    param (
        [Parameter()]
        [string]
        $Source,

        [Parameter()]
        [string]
        $Destination
    )

    $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath Posh365 )
    $TenantPath = Join-Path -Path $PoshPath -ChildPath ('{0}-{1}' -f $Source, $Destination)
    $ConfigPath = Join-Path -Path $TenantPath -ChildPath 'Configurations'
    $LogPath = Join-Path -Path $TenantPath -ChildPath 'Logs'

    if (-not ($null = Test-Path $LogPath)) {
        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
        }
        $null = New-Item $PoshPath @ItemSplat
        $null = New-Item $ConfigPath @ItemSplat
        $null = New-Item $LogPath @ItemSplat
    }
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $Form = [System.Windows.Forms.Form]::New()
    $Form.ClientSize = '800,450'
    $Form.text = "MsTeams Chat Migration Tool"
    $Form.BackColor = "#262626"
    $Form.TopMost = $true
    $Form.FormBorderStyle = "FixedDialog"
    $Form.ShowInTaskbar = $true
    $Form.StartPosition = "centerscreen"

    $SourcePanel = [System.Windows.Forms.Panel]::New()
    $SourcePanel.height = 290
    $SourcePanel.width = 388
    $SourcePanel.location = [System.Drawing.Point](5, 4)

    $DestPanel = [System.Windows.Forms.Panel]::New()
    $DestPanel.height = 290
    $DestPanel.width = 388
    $DestPanel.Anchor = 'top,right'
    $DestPanel.location = [System.Drawing.Point](397, 4)

    $SourceConfigExportBT = [System.Windows.Forms.Button]::New()
    $SourceConfigExportBT.text = "Export Source Config"
    $SourceConfigExportBT.width = 375
    $SourceConfigExportBT.height = 30
    $SourceConfigExportBT.Anchor = 'top,right,left'
    $SourceConfigExportBT.location = [System.Drawing.Point](13, 136)
    $SourceConfigExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $SourceConfigExportBT.ForeColor = "#cecece"
    $SourceConfigExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $SourceConfigExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $SourceConfigExportBT.FlatAppearance.BorderSize = 0
    $SourceConfigExportBT.BackColor = "#171717"

    $DestConfigExportBT = [System.Windows.Forms.Button]::New()
    $DestConfigExportBT.text = "Export Destination Config"
    $DestConfigExportBT.width = 375
    $DestConfigExportBT.height = 30
    $DestConfigExportBT.Anchor = 'top,right,left'
    $DestConfigExportBT.location = [System.Drawing.Point](13, 136)
    $DestConfigExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $DestConfigExportBT.ForeColor = "#cecece"
    $DestConfigExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $DestConfigExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $DestConfigExportBT.FlatAppearance.BorderSize = 0
    $DestConfigExportBT.BackColor = "#171717"

    $SourceCredsExportBT = [System.Windows.Forms.Button]::New()
    $SourceCredsExportBT.text = "Export Source Credentials"
    $SourceCredsExportBT.width = 375
    $SourceCredsExportBT.height = 30
    $SourceCredsExportBT.Anchor = 'top,right,left'
    $SourceCredsExportBT.location = [System.Drawing.Point](13, 240)
    $SourceCredsExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $SourceCredsExportBT.ForeColor = "#cecece"
    $SourceCredsExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $SourceCredsExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $SourceCredsExportBT.FlatAppearance.BorderSize = 0
    $SourceCredsExportBT.BackColor = "#171717"

    $DestCredsExportBT = [System.Windows.Forms.Button]::New()
    $DestCredsExportBT.text = "Export Destination Credentials"
    $DestCredsExportBT.width = 375
    $DestCredsExportBT.height = 30
    $DestCredsExportBT.Anchor = 'top,right,left'
    $DestCredsExportBT.location = [System.Drawing.Point](13, 240)
    $DestCredsExportBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $DestCredsExportBT.ForeColor = "#cecece"
    $DestCredsExportBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $DestCredsExportBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $DestCredsExportBT.FlatAppearance.BorderSize = 0
    $DestCredsExportBT.BackColor = "#171717"

    $FinishBT = [System.Windows.Forms.Button]::New()
    $FinishBT.text = "Finish"
    $FinishBT.width = 360
    $FinishBT.height = 30
    $FinishBT.Anchor = 'top,right,left'
    $FinishBT.location = [System.Drawing.Point](220, 410)
    $FinishBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $FinishBT.ForeColor = "#cecece"
    $FinishBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $FinishBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $FinishBT.FlatAppearance.BorderSize = 0
    $FinishBT.BackColor = "#171717"

    $ClientInfoTB = [System.Windows.Forms.TextBox]::New()
    $ClientInfoTB.multiline = $true
    $ClientInfoTB.width = 790
    $ClientInfoTB.height = 100
    $ClientInfoTB.Anchor = 'top,right,left'
    $ClientInfoTB.location = [System.Drawing.Point](5, 300)
    $ClientInfoTB.Font = 'Microsoft Sans Serif,10'
    $ClientInfoTB.BackColor = "#000000"
    $ClientInfoTB.ForeColor = "#5bde09"
    $ClientInfoTB.BorderStyle = "none"

    $SourceLB = [System.Windows.Forms.Label]::New()
    $SourceLB.text = "Source"
    $SourceLB.AutoSize = $true
    $SourceLB.width = 25
    $SourceLB.height = 10
    $SourceLB.location = [System.Drawing.Point](173, 9)
    $SourceLB.Font = 'Microsoft Sans Serif,10,style=Bold,Underline'
    $SourceLB.ForeColor = "#cecece"

    $DestinationLB = [System.Windows.Forms.Label]::New()
    $DestinationLB.text = "Destination"
    $DestinationLB.AutoSize = $true
    $DestinationLB.width = 25
    $DestinationLB.height = 10
    $DestinationLB.Anchor = 'top'
    $DestinationLB.location = [System.Drawing.Point](162, 7)
    $DestinationLB.Font = 'Microsoft Sans Serif,10,style=Bold,Underline'
    $DestinationLB.ForeColor = "#cecece"

    $ClientIDLBsource = [System.Windows.Forms.Label]::New()
    $ClientIDLBsource.text = "Client ID:"
    $ClientIDLBsource.AutoSize = $true
    $ClientIDLBsource.width = 25
    $ClientIDLBsource.height = 10
    $ClientIDLBsource.location = [System.Drawing.Point](13, 36)
    $ClientIDLBsource.Font = 'Microsoft Sans Serif,10'
    $ClientIDLBsource.ForeColor = "#cecece"

    $ClientIDLBdest = [System.Windows.Forms.Label]::New()
    $ClientIDLBdest.text = "Client ID:"
    $ClientIDLBdest.AutoSize = $true
    $ClientIDLBdest.width = 25
    $ClientIDLBdest.height = 10
    $ClientIDLBdest.location = [System.Drawing.Point](13, 36)
    $ClientIDLBdest.Font = 'Microsoft Sans Serif,10'
    $ClientIDLBdest.ForeColor = "#cecece"

    $ClientIDTBsource = [System.Windows.Forms.TextBox]::New()
    $ClientIDTBsource.multiline = $false
    $ClientIDTBsource.BackColor = "#171717"
    $ClientIDTBsource.width = 300
    $ClientIDTBsource.height = 30
    $ClientIDTBsource.location = [System.Drawing.Point](88, 36)
    $ClientIDTBsource.Font = 'Microsoft Sans Serif,10'
    $ClientIDTBsource.ForeColor = "#ffffff"
    $ClientIDTBsource.BorderStyle = "None"

    $ClientIDTBdest = [System.Windows.Forms.TextBox]::New()
    $ClientIDTBdest.multiline = $false
    $ClientIDTBdest.width = 300
    $ClientIDTBdest.height = 30
    $ClientIDTBdest.Anchor = 'top'
    $ClientIDTBdest.location = [System.Drawing.Point](88, 36)
    $ClientIDTBdest.Font = 'Microsoft Sans Serif,10'
    $ClientIDTBdest.BackColor = "#171717"
    $ClientIDTBdest.ForeColor = "#ffffff"
    $ClientIDTBdest.BorderStyle = "None"

    $TenantIDLBsource = [System.Windows.Forms.Label]::New()
    $TenantIDLBsource.text = "Tenant ID:"
    $TenantIDLBsource.AutoSize = $true
    $TenantIDLBsource.width = 25
    $TenantIDLBsource.height = 10
    $TenantIDLBsource.location = [System.Drawing.Point](13, 72)
    $TenantIDLBsource.Font = 'Microsoft Sans Serif,10'
    $TenantIDLBsource.ForeColor = "#cecece"

    $TenantIDLBdest = [System.Windows.Forms.Label]::New()
    $TenantIDLBdest.text = "Tenant ID:"
    $TenantIDLBdest.AutoSize = $true
    $TenantIDLBdest.width = 25
    $TenantIDLBdest.height = 10
    $TenantIDLBdest.Anchor = 'top,right'
    $TenantIDLBdest.location = [System.Drawing.Point](13, 72)
    $TenantIDLBdest.Font = 'Microsoft Sans Serif,10'
    $TenantIDLBdest.ForeColor = "#cecece"

    $TenantIDTBsource = [System.Windows.Forms.TextBox]::New()
    $TenantIDTBsource.multiline = $false
    $TenantIDTBsource.width = 294
    $TenantIDTBsource.height = 30
    $TenantIDTBsource.location = [System.Drawing.Point](93, 73)
    $TenantIDTBsource.Font = 'Microsoft Sans Serif,10'
    $TenantIDTBsource.BackColor = "#171717"
    $TenantIDTBsource.ForeColor = "#ffffff"
    $TenantIDTBsource.BorderStyle = "None"

    $TenantIDTBdest = [System.Windows.Forms.TextBox]::New()
    $TenantIDTBdest.multiline = $false
    $TenantIDTBdest.width = 294
    $TenantIDTBdest.height = 30
    $TenantIDTBdest.Anchor = 'top'
    $TenantIDTBdest.location = [System.Drawing.Point](93, 73)
    $TenantIDTBdest.Font = 'Microsoft Sans Serif,10'
    $TenantIDTBdest.BackColor = "#171717"
    $TenantIDTBdest.ForeColor = "#ffffff"
    $TenantIDTBdest.BorderStyle = "None"

    $ClientSecLBsource = [System.Windows.Forms.Label]::New()
    $ClientSecLBsource.text = "Client Secret:"
    $ClientSecLBsource.AutoSize = $true
    $ClientSecLBsource.width = 25
    $ClientSecLBsource.height = 10
    $ClientSecLBsource.location = [System.Drawing.Point](13, 105)
    $ClientSecLBsource.Font = 'Microsoft Sans Serif,10'
    $ClientSecLBsource.ForeColor = "#cecece"

    $ClientSecLBdest = [System.Windows.Forms.Label]::New()
    $ClientSecLBdest.text = "Client Secret:"
    $ClientSecLBdest.AutoSize = $true
    $ClientSecLBdest.width = 25
    $ClientSecLBdest.height = 10
    $ClientSecLBdest.Anchor = 'top,right'
    $ClientSecLBdest.location = [System.Drawing.Point](13, 105)
    $ClientSecLBdest.Font = 'Microsoft Sans Serif,10'
    $ClientSecLBdest.ForeColor = "#cecece"

    $ClientSecTBsource = [System.Windows.Forms.MaskedTextBox]::New()
    $ClientsecTBsource.PasswordChar = '*'
    $ClientSecTBsource.multiline = $false
    $ClientSecTBsource.width = 276
    $ClientSecTBsource.height = 30
    $ClientSecTBsource.location = [System.Drawing.Point](110, 107)
    $ClientSecTBsource.Font = 'Microsoft Sans Serif,10'
    $ClientSecTBsource.BackColor = "#171717"
    $ClientSecTBsource.ForeColor = "#ffffff"
    $ClientSecTBsource.BorderStyle = "None"

    $ClientSecTBdest = [System.Windows.Forms.MaskedTextBox]::New()
    $ClientsecTBdest.PasswordChar = '*'
    $ClientSecTBdest.multiline = $false
    $ClientSecTBdest.width = 276
    $ClientSecTBdest.height = 30
    $ClientSecTBdest.Anchor = 'top'
    $ClientSecTBdest.location = [System.Drawing.Point](110, 107)
    $ClientSecTBdest.Font = 'Microsoft Sans Serif,10'
    $ClientSecTBdest.BackColor = "#171717"
    $ClientSecTBdest.ForeColor = "#ffffff"
    $ClientSecTBdest.BorderStyle = "None"

    $UsernameLBsource = [System.Windows.Forms.Label]::New()
    $UsernameLBsource.text = "Username:"
    $UsernameLBsource.AutoSize = $true
    $UsernameLBsource.width = 25
    $UsernameLBsource.height = 10
    $UsernameLBsource.location = [System.Drawing.Point](13, 180)
    $UsernameLBsource.Font = 'Microsoft Sans Serif,10'
    $UsernameLBsource.ForeColor = "#cecece"

    $UsernameLBdest = [System.Windows.Forms.Label]::New()
    $UsernameLBdest.text = "Username:"
    $UsernameLBdest.AutoSize = $true
    $UsernameLBdest.width = 25
    $UsernameLBdest.height = 10
    $UsernameLBdest.Anchor = 'top,right'
    $UsernameLBdest.location = [System.Drawing.Point](13, 180)
    $UsernameLBdest.Font = 'Microsoft Sans Serif,10'
    $UsernameLBdest.ForeColor = "#cecece"

    $UsernameTBsource = [System.Windows.Forms.TextBox]::New()
    $UsernameTBsource.multiline = $false
    $UsernameTBsource.width = 290
    $UsernameTBsource.height = 30
    $UsernameTBsource.location = [System.Drawing.Point](96, 180)
    $UsernameTBsource.Font = 'Microsoft Sans Serif,10'
    $UsernameTBsource.BackColor = "#171717"
    $UsernameTBsource.ForeColor = "#ffffff"
    $UsernameTBsource.BorderStyle = "None"

    $UsernameTBdest = [System.Windows.Forms.TextBox]::New()
    $UsernameTBdest.multiline = $false
    $UsernameTBdest.width = 290
    $UsernameTBdest.height = 30
    $UsernameTBdest.Anchor = 'top'
    $UsernameTBdest.location = [System.Drawing.Point](96, 180)
    $UsernameTBdest.Font = 'Microsoft Sans Serif,10'
    $UsernameTBdest.BackColor = "#171717"
    $UsernameTBdest.ForeColor = "#ffffff"
    $UsernameTBdest.BorderStyle = "None"

    $PasswordLBsource = [System.Windows.Forms.Label]::New()
    $PasswordLBsource.text = "Password:"
    $PasswordLBsource.AutoSize = $true
    $PasswordLBsource.width = 25
    $PasswordLBsource.height = 10
    $PasswordLBsource.location = [System.Drawing.Point](13, 210)
    $PasswordLBsource.Font = 'Microsoft Sans Serif,10'
    $PasswordLBsource.ForeColor = "#cecece"

    $PasswordLBdest = [System.Windows.Forms.Label]::New()
    $PasswordLBdest.text = "Password:"
    $PasswordLBdest.AutoSize = $true
    $PasswordLBdest.width = 25
    $PasswordLBdest.height = 10
    $PasswordLBdest.Anchor = 'top,right'
    $PasswordLBdest.location = [System.Drawing.Point](13, 210)
    $PasswordLBdest.Font = 'Microsoft Sans Serif,10'
    $PasswordLBdest.ForeColor = "#cecece"

    $PasswordMTBsource = [System.Windows.Forms.MaskedTextBox]::New()
    $PasswordMTBsource.multiline = $false
    $PasswordMTBsource.width = 291
    $PasswordMTBsource.height = 30
    $PasswordMTBsource.location = [System.Drawing.Point](95, 210)
    $PasswordMTBsource.Font = 'Microsoft Sans Serif,10'
    $PasswordMTBsource.PasswordChar = '*'
    $PasswordMTBsource.BackColor = "#171717"
    $PasswordMTBsource.ForeColor = "#ffffff"
    $PasswordMTBsource.BorderStyle = "None"

    $PasswordMTBdest = [System.Windows.Forms.MaskedTextBox]::New()
    $PasswordMTBdest.multiline = $false
    $PasswordMTBdest.width = 291
    $PasswordMTBdest.height = 30
    $PasswordMTBdest.location = [System.Drawing.Point](95, 210)
    $PasswordMTBdest.Font = 'Microsoft Sans Serif,10'
    $PasswordMTBdest.PasswordChar = '*'
    $PasswordMTBdest.BackColor = "#171717"
    $PasswordMTBdest.ForeColor = "#ffffff"
    $PasswordMTBdest.BorderStyle = "None"

    $Form.controls.AddRange(@($ConnectionPanel, $SourcePanel, $DestPanel, $ClientInfoTB, $FinishBT))

    $SourcePanel.controls.AddRange(@(
            $SourceLB, $ClientIDLBsource, $ClientIDTBsource, $TenantIDLBsource, $TenantIDTBsource
            $ClientSecLBsource, $ClientSecTBsource, $UsernameLBsource, $UsernameTBsource, $PasswordLBsource
            $PasswordMTBsource, $SourceConfigExportBT, $SourceCredsExportBT
        ))
    $DestPanel.controls.AddRange(@(
            $DestinationLB, $ClientIDLBdest, $ClientIDTBdest, $TenantIDLBdest, $TenantIDTBdest, $ClientSecLBdest
            $ClientSecTBdest, $UsernameLBdest, $UsernameTBdest, $PasswordLBdest, $PasswordMTBdest, $DestConfigExportBT, $DestCredsExportBT
        ))
    #################
    # SOURCE CONFIG #
    #################
    $SourceConfigExportBT.Add_Click(
        {
            try {
                # Remove SCRIPT Scope
                $Script:SourceObject = [PSCustomObject]@{
                    SourceClientID = $ClientIDTBsource.text
                    SourceTenantID = $TenantIDTBsource.text
                    SourceSecret   = $ClientSecTBsource.text | ConvertTo-SecureString -AsPlainText -Force
                }
                $SourceConfig = Join-Path -Path $ConfigPath -ChildPath ('{0}-SourceConfig.xml' -f $Source)
                [PSCustomObject]@{
                    Cred     = [PSCredential]::new($SourceObject.SourceTenantID, $SourceObject.SourceSecret)
                    ClientId = $SourceObject.SourceClientID
                } | Export-Clixml -Path $SourceConfig
                $ClientInfoTB.AppendText(('Source configuration encrypted to: {0}{1}' -f $SourceConfig, [Environment]::NewLine))
            }
            catch {
                $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
            }
        }
    )
    #################
    # DEST   CONFIG #
    #################
    $DestConfigExportBT.Add_Click(
        {
            try {
                $Script:DestObject = [PSCustomObject]@{
                    DestClientID = $ClientIDTBdest.text
                    DestTenantID = $TenantIDTBdest.text
                    DestSecret   = $ClientSecTBdest.text | ConvertTo-SecureString -AsPlainText -Force
                }
                $DestConfig = Join-Path -Path $ConfigPath -ChildPath ('{0}-DestConfig.xml' -f $Destination)
                [PSCustomObject]@{
                    Cred     = [PSCredential]::new($DestObject.DestTenantID, $DestObject.DestSecret)
                    ClientId = $DestObject.DestClientID
                } | Export-Clixml -Path $DestConfig
                $ClientInfoTB.AppendText(('Destination configuration encrypted to: {0}{1}' -f $DestConfig, [Environment]::NewLine))
            }
            catch {
                $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
            }
        }
    )
    #################
    # SOURCE  CREDS #
    #################
    $SourceCredsExportBT.Add_Click(
        {
            try {
                $Script:SourceCredObj = [PSCustomObject]@{
                    SourceUsername = $UsernameTBSource.text
                    SourcePassword = $PasswordMTBSource.text | ConvertTo-SecureString -AsPlainText -Force
                }
                $SourceCred = Join-Path -Path $ConfigPath -ChildPath ('{0}-SourceCred.xml' -f $Source)
                [PSCredential]::new($SourceCredObj.SourceUsername, $SourceCredObj.SourcePassword) | Export-Clixml -Path $SourceCred

                $ClientInfoTB.AppendText(('Source credential encrypted to: {0}{1}' -f $SourceCred, [Environment]::NewLine))
            }
            catch {
                $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
            }
        }
    )
    #################
    # DEST    CREDS #
    #################
    $DestCredsExportBT.Add_Click(
        {
            try {
                $Script:DestCredObj = [PSCustomObject]@{
                    DestUsername = $UsernameTBdest.text
                    DestPassword = $PasswordMTBdest.text | ConvertTo-SecureString -AsPlainText -Force
                }
                $DestCred = Join-Path -Path $ConfigPath -ChildPath ('{0}-DestCred.xml' -f $Destination)
                [PSCredential]::new($DestCredObj.DestUsername, $DestCredObj.DestPassword) | Export-Clixml -Path $DestCred
                $ClientInfoTB.AppendText(('Destination credential encrypted to: {0}{1}' -f $DestCred, [Environment]::NewLine))
            }
            catch {
                $ClientInfoTB.AppendText(($_.Exception.Message, [Environment]::NewLine))
            }
        }
    )
    [void]$Form.ShowDialog()
}
