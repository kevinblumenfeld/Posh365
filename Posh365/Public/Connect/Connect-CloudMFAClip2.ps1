function Connect-CloudMFAClip2 {
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0)]
        $CredFile
    )
    end {
        Add-Type -AssemblyName System.Windows.Forms
        $form1 = New-Object System.Windows.Forms.Form
        $Pass_Btn = New-Object System.Windows.Forms.Button
        $User_Btn = New-Object System.Windows.Forms.Button
        $Info_GB = New-Object System.Windows.Forms.Groupbox
        $Sidebar_GB = New-Object System.Windows.Forms.Groupbox

        $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

        $form1.Text = 'Click Username or Password to copy to clipboard'
        $form1.Name = 'Form1'
        $form1.StartPosition = 'CenterScreen'
        $form1.ClientSize = '725, 450'
        $Form1.KeyPreview = $True
        $Form1.Add_KeyDown( {
                if ($_.KeyCode -eq 'Escape') {
                    $Form1.Close()
                }
            })
        $Form1.Add_Resize( {
                TC_Refresh
            })
        $Form1.ShowInTaskbar = $True

        $Info_GB.Location = '0, 0'
        $Info_GB.Size = '750, 60'
        $Info_GB.Dock = 'Top'
        $Info_GB.BringToFront()
        $Info_GB.Text = 'Posh365'
        $form1.Controls.Add($Info_GB)

        $Sidebar_GB.Location = '751, 0'
        $Sidebar_GB.Size = '650,25'
        $Sidebar_GB.Dock = 'Right'
        $Sidebar_GB.SendToBack()
        $Sidebar_GB.Text = 'Posh365'
        $form1.Controls.Add($Sidebar_GB)

        $Pass_Btn.TabIndex = 4
        $Pass_Btn.Name = 'Pass_Btn'
        $Pass_Btn.Size = '200,50'
        $Pass_Btn.UseVisualStyleBackColor = $True
        $Pass_Btn.Text = 'Copy password to clipboard'
        $Pass_Btn.Location = '92,15'
        $Pass_Btn.add_Click($button1_RunOnClick)
        $Sidebar_GB.Controls.Add($Pass_Btn)

        $User_Btn.TabIndex = 5
        $User_Btn.Name = 'CPass_Btn'
        $User_Btn.Size = '200,50'
        $User_Btn.UseVisualStyleBackColor = $True
        $User_Btn.Text = 'Copy username to clipboard'
        $User_Btn.Location = '2,15'
        $User_Btn.add_Click($User_Btn_RunOnClick)
        $Sidebar_GB.Controls.Add($User_Btn)

        $OnLoadForm_StateCorrection = {
            $form1.WindowState = $InitialFormWindowState
        }

        $InitialFormWindowState = $form1.WindowState
        $form1.add_Load($OnLoadForm_StateCorrection)
        $form1.ShowDialog() | Out-Null

        <# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    connectcloud
#>

        Add-Type -AssemblyName System.Windows.Forms

        $Posh365 = New-Object system.Windows.Forms.Form
        $Posh365.ClientSize = '400,400'
        $Posh365.text = "Posh365"
        $Posh365.BackColor = "#4a90e2"
        $Posh365.TopMost = $false

        $Username = New-Object system.Windows.Forms.Button
        $Username.BackColor = "#ffffff"
        $Username.text = "Username"
        $Username.width = 377
        $Username.height = 68
        $Username.location = New-Object System.Drawing.Point(8, 25)
        $Username.Font = 'Microsoft Sans Serif,40'
        $Username.ForeColor = "#000000"

        $Password = New-Object system.Windows.Forms.Button
        $Password.BackColor = "#ffffff"
        $Password.text = "Password"
        $Password.width = 377
        $Password.height = 68
        $Password.location = New-Object System.Drawing.Point(8, 100)
        $Password.Font = 'Microsoft Sans Serif,40'
        $Password.ForeColor = "#000000"

        $Posh365.controls.AddRange(@($Username, $Password))
        $Username.Add_Click(($Credential.UserName))

        [void]$Posh365.ShowDialog()
    }
}
