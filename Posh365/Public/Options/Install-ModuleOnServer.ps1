function Install-ModuleOnServer {
    <#

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $Server,

        [Parameter()]
        [string] $Module = 'Posh365'
    )
    End {
        $Path = "\\{0}\c$\Program Files\WindowsPowerShell\Modules" -f $Server
        Write-Host "Attempting to install module here: $Path." -BackgroundColor Blue -ForegroundColor White
        if (Test-Path $Path) {
            $SaveSplat = @{
                Name        = $Module
                Path        = $Path
                Force       = $true
                ErrorAction = 'Stop'
            }
            try {
                Save-Module @SaveSplat
                Write-Host "Successfully installed $Module module" -BackgroundColor Blue -ForegroundColor White
                Write-Host "Please restart PowerShell on $Server" -BackgroundColor Blue -ForegroundColor White
                Write-Host "When starting PowerShell, make sure to Run As Administrator" -BackgroundColor Blue -ForegroundColor White
                $Here = @'
$gci = @{
    Path    = "C:\Program Files\WindowsPowerShell\Modules\Posh365"
    Filter  = '*.ps1'
    Recurse = $true
}
Get-ChildItem @gci | % {try{. $_.fullname}catch{}}
'@
                Write-Host "If $Server has PowerShell 2 (common with Exchange 2010)," -BackgroundColor DarkGreen -ForegroundColor White
                Write-Host "copy and paste this code block in PowerShell on $Server" -BackgroundColor DarkGreen -ForegroundColor White
                Write-Host "#####################################################" -BackgroundColor DarkGreen -ForegroundColor White
                Write-Host $Here -BackgroundColor Green -ForegroundColor Black
                Write-Host "#####################################################" -BackgroundColor DarkGreen -ForegroundColor White
            }
            catch {
                Write-Host "Failed to install $Module module." -BackgroundColor Yellow -ForegroundColor Black
            }
        }
        else {
            Write-Host "Path $Path not found." -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "Unable to install $Module module." -BackgroundColor Yellow -ForegroundColor Black
        }
    }
}
