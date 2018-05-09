function Add-365RecipientEmailAddresses { 
    <#
.SYNOPSIS
Add Recipients Email Addresses

.DESCRIPTION
Add Recipients Email Addresses and other functions

.EXAMPLE

#>
    [CmdletBinding()]
    param (

    )

    $currentErrorActionPrefs = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    $OutputPath = 'C:\Scripts\ContosoOLD'
    $LogFile = ($(get-date -Format yyyy-MM-dd_HH-mm-ss) + "-Failed.csv")

    $NewTenantFile = 'C:\Scripts\ContosoNEW\ContosoTECHINCGCmbx.csv'
    $OldTenantFile = 'C:\Scripts\ContosoOLD\FINAL.csv'
    $AllOldFile = 'C:\Scripts\ContosoOLD\ContosoMBXOLD.csv'

    $FailLog = Join-Path $OutputPath $LogFile
    $errheaderstring = "DisplayName,RemovePrimary,RemoveSecondaryToMakePrimary,AddPrimary,AddBackonMicrosoft,RemoveCurPrimary,Error"
    Out-File -FilePath $FailLog -InputObject $errheaderstring -Encoding UTF8 -append

    $hashold = @{}
    Import-Csv $OldTenantFile | ForEach-Object {
        $hashold.add($_.DisplayName, ($_.primarysmtpaddress))
    }

    $Newt = Import-Csv $NewTenantFile | Where-Object {
        $_.RecipientTypeDetails -eq 'UserMailbox' -and
        $_.EmailAddresses -cmatch 'SMTP:' -and
        $_.EmailAddresses -match "@Contosotechincgc.onmicrosoft.com"
    } 
    ForEach ($CurNewt in $Newt) {
        Try {
            ## Verify Case of domain.onmicrosoft.com address as case dependent command follows ##
            $Remove = $CurNewt.EmailAddresses -split ';' | Where-Object {
                $_ -clike "SMTP:*@Contosotechincgc.onmicrosoft.com"
            }

            $DisplayName = $CurNewt.DisplayName
            $RemovesmtptomakeSMTP = $("smtp:" + ($hashold[$DisplayName]))
            $Add = $("SMTP:" + ($hashold[$DisplayName]))

            [ARRAY]$Remove = $Remove

            $CurPrimary = (Get-Mailbox $Displayname).primarysmtpaddress
            $CurPrimary = "SMTP:" + $CurPrimary

            Write-Verbose "----------"
            Write-Verbose "Display Name            : `t $DisplayName"
            Write-Verbose "Remove Primary onMicro  : `t $Remove"
            Write-Verbose "Remove2ndaryMakeSMTP    : `t $RemovesmtptomakeSMTP"
            Write-Verbose "Add Desired Primary     : `t $Add"
            Write-Verbose "AddBackonMicrosoft      : `t $("smtp:" + ($Remove.substring(5)))"
            Write-Verbose "CurPrimary              : `t $CurPrimary"
            Write-Verbose "----------"

            if ($Remove) {
                Set-Mailbox -Identity $DisplayName -EmailAddresses @{
                    Remove = "$Remove", "$RemovesmtptomakeSMTP", "$CurPrimary"
                    Add    = "$Add", $(("smtp:" + $($Remove.substring(5))))
                }                
            }
        }
        Catch {
            Write-Warning $_
            $DisplayName + "," + $Remove + "," + $RemovesmtptomakeSMTP + "," + $Add + "," + $("smtp:" + ($Remove.substring(5))) + "," + $CurPrimary + "," + $_ |
                Out-file $FailLog -Encoding UTF8 -append
        }
    }
    $AllOld = Import-Csv $AllOldFile
    Foreach ($CurAllOld in $AllOld) {
        $Secondary = $CurAllOld.EmailAddresses -split ';' |  Where-Object {
            $_ -clike "smtp:*" -and
            $_ -notlike "*onmicrosoft.com"
        }
        [ARRAY]$Secondary = $Secondary
        foreach ($CurSecondary in $Secondary) {
            Write-Verbose "----------"
            Write-Verbose "DisplayName      : $($CurAllOld.DisplayName)"
            Write-Verbose "Secondary        : $CurSecondary"
            Write-Verbose "----------"
            Set-Mailbox -Identity $CurAllOld.DisplayName -EmailAddresses @{
                Add = "$CurSecondary"
            }        
        }
    }

    $SIP = Get-365RecipientEmailAddresses | Where-Object {
        $_.emailaddress -like "SIP:*"
    }
    Foreach ($CurSIP in $SIP) {
        Write-Host "----------"
        Write-Host "DisplayName      : $($CurSIP.DisplayName)"
        Write-Host "Remove SIP       : $($CurSIP.EmailAddress)"
        Write-Host "Add SIP          : $("SIP:" + $CurSIP.PrimarySMTPAddress)"
        Write-Host "----------"
        Set-Mailbox -Identity $CurSIP.DisplayName -EmailAddresses @{
            Remove = $CurSIP.EmailAddress
            Add    = "SIP:" + $CurSIP.PrimarySMTPAddress
        }
    }

    <#

    # Modify UPN to Match PrimarySMTPAddress
    $UPNandPrimary = @(
        @{n = "UserPrincipalName" ; e = {$_.UserPrincipalName}},
        @{n = "PrimarySMTPAddress" ; e = {( $_.proxyAddresses -split ";" |  Where-Object {$_ -cmatch "SMTP:*"}).Substring(5)}}
    )

    $UP = Get-365MsolUser  | Where-Object {
        $_.userprincipalname -notlike "*sada*" -and
        $_.userprincipalname -notlike "*admin*"
    } | Select-Object $UPNandPrimary

    foreach ($CurUP in $UP) {Set-MsolUserPrincipalName -UserPrincipalName $CurUP.UserPrincipalName -NewUserPrincipalName $CurUP.PrimarySMTPAddress}
#>

    <#
    $Fwd = Import-Csv "C:\Scripts\ContosoOLD\testmay37pm\Contoso_Forwards.csv"

    foreach ($CurFwd in $Fwd) {
        $FwdHash = @{    
            Identity                   = $CurFwd.DisplayName
            DeliverToMailboxAndForward = $True
            ForwardingSmtpAddress      = $CurFwd.ForwardingSmtpAddress
        }        
        $params = @{}
        if ($CurFwd.ForwardingSmtpAddress) {
            ForEach ($key in $FwdHash.keys) {
                if ($($FwdHash.item($key))) {
                    $params.add($key, $($FwdHash.item($key)))
                }
            }   
            Set-Mailbox @params
        }
    }
    #>
    $ErrorActionPreference = $currentErrorActionPrefs
}

