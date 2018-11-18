function Get-Cred {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [string] $Tenant,

        [parameter(Position = 1, Mandatory = $true)]
        [string] $Type,
        
        [switch] $DeleteCreds
    )

    begin {
        if ($Tenant -match 'onmicrosoft') {
            $Tenant = $Tenant.Split(".")[0]
        }

        $RootPath = $env:USERPROFILE + "\ps\"
        $KeyPath = $Rootpath + "creds\"
        $UserFileName = "$($Tenant).$($Type)UCred"
        $PassFileName = "$($Tenant).$($Type)Cred"
    }
    process {
        if ($DeleteCreds) {
            Try {
                Remove-Item ($KeyPath + $PassFileName) -ErrorAction Stop
            }
            Catch {
                Write-Warning "While the attempt to delete credentials failed, this may be normal. Please try to connect again."
            }
            Try {
                Remove-Item ($KeyPath + $UserFileName) -ErrorAction Stop
            }
            Catch {
                break
            }
        }
        if (Test-Path ($KeyPath + $PassFileName)) {
            $Pass = Get-Content ($KeyPath + $PassFileName) | ConvertTo-SecureString
            $User = Get-Content ($KeyPath + $UserFileName)
            $Cred = Try {
                New-Object System.Management.Automation.PSCredential -ArgumentList $User, $Pass -ErrorAction Stop 
            }
            Catch {
                if ($_.exception.Message -match '"userName" is not valid. Change the value of the "userName" argument and run the operation again') {
                    Connect-Cloud $Tenant -DeleteCreds
                    Write-Warning "                    Bad Username                                    "
                    Write-Warning "          Please try your last command again...                     "
                    Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                    Break
                }
                Else {
                    $error[0]
                }
            }
        }
        else {
            $Cred = Get-Credential -Message "ENTER USERNAME & PASSWORD FOR OFFICE 365/AZURE AD"
            if ($Cred.Password) {
                $Cred.Password | ConvertFrom-SecureString | Out-File ($KeyPath + $PassFileName) -Force
            }
            else {
                Connect-Cloud $Tenant -DeleteCreds
                Write-Warning "                 No Password Present                                "
                Write-Warning "          Please Try your last command again...                     "
                Write-Warning "...you will be prompted to enter your Office 365 credentials again. "
                Break
            }
            $Cred.UserName | Out-File ($KeyPath + $UserFileName)
        }

    }
    end {
        $Cred
    } 
}