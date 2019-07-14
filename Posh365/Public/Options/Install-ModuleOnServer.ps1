function Install-ModuleOnServer {
    <#
    .SYNOPSIS
    Installs

    .DESCRIPTION
    Long description

    .PARAMETER Server
    Parameter description

    .PARAMETER Module
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
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
        Write-Host "`nAttempting to install module here: $Path`n" -ForegroundColor White
        if (Test-Path $Path) {
            $SaveSplat = @{
                Name        = $Module
                Path        = $Path
                Force       = $true
                ErrorAction = 'Stop'
            }
            try {
                $ModulePath = Join-Path $Path $Module
                Save-Module @SaveSplat
                $Latest = (Get-ChildItem -Directory -Path $ModulePath -Force | Sort-Object LastWriteTime -Descending)[0].fullname
                Get-ChildItem -Path $Latest | Copy-Item -Destination $ModulePath -Recurse -Force -ErrorAction Stop
                Write-Host "Successfully installed $Module module`n" -ForegroundColor Green
                Remove-Item -Path $Latest -Recurse -Force -Confirm:$false

                if ($Module -eq 'Posh365') {
                    $SaveExcel = @{
                        Name        = 'ImportExcel'
                        Path        = $Path
                        Force       = $true
                        ErrorAction = 'Stop'
                    }
                    $ExcelPath = Join-Path $Path 'ImportExcel'
                    Save-Module @SaveExcel
                    $ExcelLatest = (Get-ChildItem -Directory -Path $ExcelPath -Force | Sort-Object LastWriteTime -Descending)[0].fullname
                    Get-ChildItem -Path $ExcelLatest | Copy-Item -Destination $ExcelPath -Recurse -Force -ErrorAction Stop
                    Write-Host "Successfully installed $Module module dependency, ImportExcel`n" -ForegroundColor Green
                    Remove-Item -Path $ExcelLatest -Recurse -Force -Confirm:$false

                    $SavePoshRS = @{
                        Name        = 'PoshRSJob'
                        Path        = $Path
                        Force       = $true
                        ErrorAction = 'Stop'
                    }
                    $PoshRSPath = Join-Path $Path 'PoshRSJob'
                    Save-Module @SavePoshRS
                    $PoshRSLatest = (Get-ChildItem -Directory -Path $PoshRSPath -Force | Sort-Object LastWriteTime -Descending)[0].fullname
                    Get-ChildItem -Path $PoshRSLatest | Copy-Item -Destination $PoshRSPath -Recurse  -Force -ErrorAction Stop
                    Write-Host "Successfully installed $Module module dependency, PoshRSJob`n" -ForegroundColor Green
                    Remove-Item -Path $PoshRSLatest -Recurse -Force -Confirm:$false
                }
                Write-Host "Please restart PowerShell on $Server" -ForegroundColor Cyan
                Write-Host "When starting PowerShell, make sure to Run As Administrator`n" -ForegroundColor Cyan
                Write-Host "if you get this error: `"Import-Module : [path] cannot be loaded because running scripts is disabled on this system`"" -ForegroundColor DarkYellow
                Write-Host "Type the following command on $Server`: Set-ExecutionPolicy RemoteSigned -Force`n" -ForegroundColor DarkYellow
                $Here = @'
$gci = @{
    Path    = "C:\Program Files\WindowsPowerShell\Modules\Posh365"
    Filter  = '*.ps1'
    Recurse = $true
}
Get-ChildItem @gci | % {try{. $_.fullname}catch{}}
'@
                Write-Host "If $Server has PowerShell 2 (common with Exchange 2010)," -ForegroundColor Magenta
                Write-Host "copy and paste this code block in PowerShell on $Server" -ForegroundColor Magenta
                Write-Host "`n#####################################################`n" -ForegroundColor White
                Write-Host $Here -ForegroundColor Magenta
                Write-Host "`n#####################################################`n" -ForegroundColor White
            }
            catch {
                Write-Host "Failed to install $Module module." -BackgroundColor Yellow -ForegroundColor Black
                $_.Exception.Message
            }
        }
        else {
            Write-Host "Path $Path not found." -BackgroundColor Yellow -ForegroundColor Black
            Write-Host "Unable to install $Module module." -BackgroundColor Yellow -ForegroundColor Black
        }
    }
}
