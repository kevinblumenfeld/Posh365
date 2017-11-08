function Connect-ToExchange {
    param (
        [Parameter(Mandatory = $False)]
        $ExchangeServer,
        [Parameter(Mandatory = $False)]
        [Switch] $DeleteExchangeCreds,
        [Parameter(Mandatory = $False)]
        [Switch] $ViewEntireForest
    )

    $RootPath = $env:USERPROFILE + "\ps\"
    $KeyPath = $Rootpath + "creds\"
    $User = $env:USERNAME

    while (!(Test-Path ($RootPath + "$($user).EXCHServer"))) {
        Select-ExchangeServer
    }
    $ExchangeServer = Get-Content ($RootPath + "$($user).EXCHServer")
    
    # Delete invalid or unwanted credentials
    if ($DeleteExchangeCreds) {
        Try {
            Remove-Item ($KeyPath + "$($user).ExchangeCred") -erroraction stop
        }
        Catch {

        }
        Try {
            Remove-Item ($KeyPath + "$($user).uExchangeCred") -erroraction stop
        }
        Catch {
            
        }
        
    }
    # Create KeyPath Directory
    if (!(Test-Path $KeyPath)) {
        try {
            New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP | Out-Null
        }
        catch {
            throw $_.Exception.Message
        }           
    }
    if (Test-Path ($KeyPath + "$($user).ExchangeCred")) {
        $PwdSecureString = Get-Content ($KeyPath + "$($user).ExchangeCred") | ConvertTo-SecureString
        $UsernameString = Get-Content ($KeyPath + "$($user).uExchangeCred")
        $Credential = Try {
            New-Object System.Management.Automation.PSCredential -ArgumentList $UsernameString, $PwdSecureString -ErrorAction Stop 
        }
        Catch {
            if ($_.exception.Message -match '"userName" is not valid. Change the value of the "userName" argument and run the operation again') {
                Connect-ToExchange -DeleteExchangeCreds
                Write-Host "********************************************************************" -foregroundcolor "darkblue" -backgroundcolor "white"
                Write-Host "                    Bad Username                                    " -foregroundcolor "darkblue" -backgroundcolor "white"
                Write-Host "          Please try your last command again...                     " -foregroundcolor "darkblue" -backgroundcolor "white"
                Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkblue" -backgroundcolor "white"
                Write-Host "********************************************************************" -foregroundcolor "darkblue" -backgroundcolor "white"
                Break
            }
        }
    }
    else {
        $Credential = Get-Credential -Message "Enter a username and password for ONPREM EXCHANGE"
        if ($Credential.Password) {
            $Credential.Password | ConvertFrom-SecureString | Out-File ($KeyPath + "$($user).ExchangeCred") -Force
        }
        else {
            Connect-ToExchange -DeleteExchangeCreds
            Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
            Write-Host "                 No Password Present.                               " -foregroundcolor "darkgreen" -backgroundcolor "white"
            Write-Host "          Please try your last command again...                     " -foregroundcolor "darkgreen" -backgroundcolor "white"
            Write-Host "...you will be prompted to enter your Office 365 credentials again. " -foregroundcolor "darkgreen" -backgroundcolor "white"
            Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
            Break
        }
        $Credential.UserName | Out-File ($KeyPath + "$($user).uExchangeCred")
    }    
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri ("http://" + $ExchangeServer + "/PowerShell/") -Authentication Kerberos -Credential $Credential
    Import-Module (Import-PSSession $Session -Prefix "OnPrem") -Global -Prefix "OnPrem" | Out-Null
    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
    Write-Host "        You are now connected to On-Premises Exchange               " -foregroundcolor "darkgreen" -backgroundcolor "white"
    Write-Host "          All commands are pre-pended with OnPrem, for example:     " -foregroundcolor "darkgreen" -backgroundcolor "white"
    Write-Host "               Get-Mailbox       is      Get-OnPremMailbox          " -foregroundcolor "darkgreen" -backgroundcolor "white"
    Write-Host " This is to prevent overlap of commands between Office 365 and EXO  " -foregroundcolor "darkgreen" -backgroundcolor "white"
    Write-Host "   For example, Get-Mailbox would be used for Office 365 while,     " -foregroundcolor "darkgreen" -backgroundcolor "white"
    Write-Host "     Get-OnPremMailbox would be used for On-Premises Exchange       " -foregroundcolor "darkgreen" -backgroundcolor "white"
    Write-Host "********************************************************************" -foregroundcolor "darkgreen" -backgroundcolor "white"
    if ($ViewEntireForest) {
        Set-ADServerSettings -ViewEntireForest:$True
    }
}
    