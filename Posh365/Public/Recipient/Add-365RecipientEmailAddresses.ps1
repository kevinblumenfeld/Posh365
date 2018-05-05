function Add-365RecipientEmailAddresses { 
    <#
.SYNOPSIS
Add Recipients Email Addresses

.DESCRIPTION
Add Recipients Email Addresses

.EXAMPLE

#>

    param (

    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    $OutputPath = 'C:\Scripts\JSLOLD'
    $NewTenant = 'C:\Scripts\JSLNEW\JSLTECHINCGCmbx.csv'
    $OldTenant = 'C:\Scripts\JSLOLD\FINAL.csv'
    $AllOld = 'C:\Scripts\JSLOLD\JSLTECHINCGCmbx.csv'

    $failedPath = Join-Path $OutputPath "Failed.csv"
    Out-File -FilePath $failedPath -InputObject $errheaderstring -Encoding UTF8 -append

    $hashold = @{}
    Import-Csv $OldTenant | ForEach-Object {
        $hashold.add($_.DisplayName, ($_.primarysmtpaddress))
    }

    'DisplayName' + "," + 'EmailAddress' + "," + 'Identity' + "," + 'add' + "," + 'Error' + "," + 'remove' | Out-file $failedPath -Encoding UTF8 -append

    $Newt = Import-Csv $NewTenant | Select -First 11 | Where-Object {
        $_.RecipientTypeDetails -eq 'UserMailbox' -and
        $_.EmailAddresses -cmatch 'SMTP:' -and
        $_.EmailAddresses -match "@jsltechincgc.onmicrosoft.com"
    } 
    ForEach ($CurNewt in $Newt) {
        Try {
            $Remove = $CurNewt.EmailAddresses -split ';' | Where-Object {
                $_ -clike "SMTP:*@jsltechincgc.onmicrosoft.com"
            }

            $DisplayName = $CurNewt.DisplayName
            $Identity = $CurNewt.Identity
            $RemovesmtptomakeSMTP = $("smtp:" + ($hashold[$DisplayName]))
            $Add = $("SMTP:" + ($hashold[$DisplayName]))

            [ARRAY]$Remove = $Remove

            $CurPrimary = (Get-Mailbox $Displayname).primarysmtpaddress
            $CurPrimary = "SMTP:" + $CurPrimary

            Write-Host "Display: `t $DisplayName"
            Write-Host "REM    : `t $Remove"
            Write-Host "Add    : `t $Add"
            Write-Host "AddBack: `t $("smtp:" + ($Remove.substring(5)))"
            Write-Host "Make   : `t $($RemovesmtptomakeSMTP)"
            Write-Host "Cur    : `t $($CurPrimary)"

            if ($Remove) {
                Set-Mailbox -Identity $DisplayName -EmailAddresses @{
                    Remove = "$Remove", "$RemovesmtptomakeSMTP", "$CurPrimary"
                    Add    = "$Add", $(("smtp:" + $($Remove.substring(5))))
                }                
            }
            Foreach ($CurAllOld in $AllOld) {
                $AllSecondary = $CurAllOld.EmailAddresses -split ';' |  Where-Object {
                    $_ -clike "smtp:*" -and
                    $_ -notlike "*onmicrosoft.com"
                }
            }
        }
        Catch {
            Write-Warning $_
            $DisplayName + "," + $EmailAddress + "," + $Identity + "," + $add + "," + $_ + "," + $remove | Out-file $failedPath -Encoding UTF8 -append
        }
    }
    $ErrorActionPreference = $currentErrorActionPrefs
}
Add-365RecipientEmailAddresses
