function Start-MigrationGUI {
    [CmdletBinding()]
    param (

    )

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $Form = [System.Windows.Forms.Form]::New()
    $Form.ClientSize = '600,750'
    $Form.text = "Form"
    $Form.BackColor = "#262626"
    $Form.TopMost = $false
    $Form.FormBorderStyle = "FixedDialog"
    $Form.ShowInTaskbar = $true
    $Form.StartPosition = "centerscreen"

    $ConnectBT = [System.Windows.Forms.Button]::New()
    $ConnectBT.text = "Connect"
    $ConnectBT.width = 580
    $ConnectBT.height = 40
    $ConnectBT.location = [System.Drawing.Point]::New(10, 10)
    $ConnectBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $ConnectBT.Anchor = 'top,right,left'
    $ConnectBT.ForeColor = "#cecece"
    $ConnectBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ConnectBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $ConnectBT.FlatAppearance.BorderSize = 0
    $ConnectBT.BackColor = "#171717"

    $SelectSourceBT = [System.Windows.Forms.Button]::New()
    $SelectSourceBT.text = "Select Teams and Channels to Migrate"
    $SelectSourceBT.width = 280
    $SelectSourceBT.height = 40
    $SelectSourceBT.location = [System.Drawing.Point]::New(10, 60)
    $SelectSourceBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $SelectSourceBT.Anchor = 'top,right,left'
    $SelectSourceBT.ForeColor = "#cecece"
    $SelectSourceBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $SelectSourceBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $SelectSourceBT.FlatAppearance.BorderSize = 0
    $SelectSourceBT.BackColor = "#171717"

    $ViewTeamsBT = [System.Windows.Forms.Button]::New()
    $ViewTeamsBT.text = "View Selected Teams and Channels"
    $ViewTeamsBT.width = 280
    $ViewTeamsBT.height = 40
    $ViewTeamsBT.location = [System.Drawing.Point]::New(310, 60)
    $ViewTeamsBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $ViewTeamsBT.Anchor = 'top,right,left'
    $ViewTeamsBT.ForeColor = "#cecece"
    $ViewTeamsBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ViewTeamsBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $ViewTeamsBT.FlatAppearance.BorderSize = 0
    $ViewTeamsBT.BackColor = "#171717"

    $TeamsMigrateBT = [System.Windows.Forms.Button]::New()
    $TeamsMigrateBT.text = "Migrate Teams and Channels"
    $TeamsMigrateBT.width = 580
    $TeamsMigrateBT.height = 40
    $TeamsMigrateBT.location = [System.Drawing.Point]::New(10, 110)
    $TeamsMigrateBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $TeamsMigrateBT.ForeColor = "#cecece"
    $TeamsMigrateBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $TeamsMigrateBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $TeamsMigrateBT.FlatAppearance.BorderSize = 0
    $TeamsMigrateBT.BackColor = "#171717"

    $SnapFilesBT = [System.Windows.Forms.Button]::New()
    $SnapFilesBT.text = "Create Snapshot of Files to be Migrated"
    $SnapFilesBT.width = 580
    $SnapFilesBT.height = 40
    $SnapFilesBT.location = [System.Drawing.Point]::New(10, 160)
    $SnapFilesBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $SnapFilesBT.ForeColor = "#cecece"
    $SnapFilesBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $SnapFilesBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $SnapFilesBT.FlatAppearance.BorderSize = 0
    $SnapFilesBT.BackColor = "#171717"

    $ChatMigrateBT = [System.Windows.Forms.Button]::New()
    $ChatMigrateBT.text = "Migrate Chat"
    $ChatMigrateBT.width = 580
    $ChatMigrateBT.height = 40
    $ChatMigrateBT.location = [System.Drawing.Point]::New(10, 210)
    $ChatMigrateBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $ChatMigrateBT.Anchor = 'top,right,left'
    $ChatMigrateBT.ForeColor = "#cecece"
    $ChatMigrateBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ChatMigrateBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $ChatMigrateBT.FlatAppearance.BorderSize = 0
    $ChatMigrateBT.BackColor = "#171717"

    $FilesMigrateBT = [System.Windows.Forms.Button]::New()
    $FilesMigrateBT.text = "Migrate Files"
    $FilesMigrateBT.width = 580
    $FilesMigrateBT.height = 40
    $FilesMigrateBT.location = [System.Drawing.Point]::New(10, 260)
    $FilesMigrateBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $FilesMigrateBT.Anchor = 'top,right,left'
    $FilesMigrateBT.ForeColor = "#cecece"
    $FilesMigrateBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $FilesMigrateBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $FilesMigrateBT.FlatAppearance.BorderSize = 0
    $FilesMigrateBT.BackColor = "#171717"

    $PlaceholderBT = [System.Windows.Forms.Button]::New()
    $PlaceholderBT.text = ""
    $PlaceholderBT.width = 580
    $PlaceholderBT.height = 40
    $PlaceholderBT.location = [System.Drawing.Point]::New(10, 310)
    $PlaceholderBT.Font = 'Microsoft Sans Serif,10,style=Bold'
    $PlaceholderBT.Anchor = 'top,right,left'
    $PlaceholderBT.ForeColor = "#cecece"
    $PlaceholderBT.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $PlaceholderBT.FlatAppearance.BorderColor = [System.Drawing.Color]::black
    $PlaceholderBT.FlatAppearance.BorderSize = 0
    $PlaceholderBT.BackColor = "#171717"

    $Console = [System.Windows.Forms.TextBox]::New()
    $Console.multiline = $true
    $Console.width = 590
    $Console.height = 380
    $Console.location = [System.Drawing.Point]::New(5, 360)
    $Console.Font = 'Microsoft Sans Serif,10'
    $Console.Anchor = 'right,bottom,left'
    $Console.ForeColor = "#ffffff"
    $Console.BorderStyle = "none"
    $Console.BackColor = "#14006b"
    $Console.ScrollBars = "Both"

    $Form.controls.AddRange(@(
            $ConnectBT, $SelectSourceBT, $ViewTeamsBT, $TeamsMigrateBT, $SnapFilesBT
            $FileDestBT, $FolderDestBT, $ChatMigrateBT, $FilesMigrateBT, $PlaceholderBT, $Console
        ))

    $ConnectBT.Add_Click( {
            $Console.AppendText(('[ start ] graph authentication{0}' -f [Environment]::NewLine))
            $GraphSplat = @{
                SourceConfig = $SourceConfig
                SourceCred   = $SourceCred
                DestConfig   = $DestConfig
                DestCred     = $DestCred
            }
            Connect-GTeams @GraphSplat
            $Console.AppendText(('[ end ] graph authentication{0}{0}' -f [Environment]::NewLine))
        })

    $SelectSourceBT.Add_Click( {
            $Console.AppendText(('[ Start ] select source teams  and channels{0}' -f [Environment]::NewLine))
            Get-Source
            $Console.AppendText(('[ end ] select source teams and channels{0}{0}' -f [Environment]::NewLine))
        } )

    $ViewTeamsBT.Add_Click( {
            $Console.AppendText(('[ Start ] check destination for duplicate teams{0}' -f [Environment]::NewLine))
            Get-Map | Out-GridView -Title 'Current mapping between source and target'
            $Console.AppendText(('[ end ] check destination for duplicate teams{0}{0}' -f [Environment]::NewLine))
        } )

    $TeamsMigrateBT.Add_Click( {
            $Console.AppendText(('[ Start ] clone teams and channels{0}' -f [Environment]::NewLine))
            Write-TargetTeamsAndChannels
            Start-Sleep -Seconds 20
            Get-DriveID
            $Console.AppendText(('[ end ] clone teams and channels{0}{0}' -f [Environment]::NewLine))
        } )

    $SnapFilesBT.Add_Click( {
            $Console.AppendText(('[ Start ] fetching source files{0}' -f [Environment]::NewLine))
            Get-ChannelFiles
            $Console.AppendText(('[ end ] fetching source files{0}{0}' -f [Environment]::NewLine))
        } )

    $ChatMigrateBT.Add_Click( {
            $Console.AppendText(('[ Start ] migrating messages{0}' -f [Environment]::NewLine))
            Restore-Chat
            $Console.AppendText(('[ end ] migrating messages{0}{0}' -f [Environment]::NewLine))
        } )

    $FilesMigrateBT.Add_Click( {
            $Console.AppendText(('[ Start ] Get Local Folders, writing to target{0}' -f [Environment]::NewLine))
            Restore-Folder
            $Console.AppendText(('[ End ] Get Local Folders, writing to target{0}{0}' -f [Environment]::NewLine))
            $Console.AppendText(('[ Start ] Get Local Files, writing to target{0}' -f [Environment]::NewLine))
            Restore-File
            $Console.AppendText(('[ End ] Get Local Files, writing to target{0}' -f [Environment]::NewLine))
        } )

    $PlaceholderBT.Add_Click( {
            $Console.AppendText(('[ Start ] Placeholdeder{0}' -f [Environment]::NewLine))
            Get-DriveID
            Get-Map | Out-GridView -Title 'Current mapping between source and target'
            $Console.AppendText(('[ End ] Placeholdeder{0}' -f [Environment]::NewLine))
        } )

    [void]$Form.ShowDialog()
}
