function Import-PrimarySmtpasUpn {
    param (

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $MailboxList,

        [Parameter(Mandatory = $true)]
        [string] $ErrorLog

    )

    Foreach ($Mailbox in $MailboxList) {
        $DisplayName = $Mailbox.DisplayName
        $PrimarySmtpAddress = $Mailbox.PrimarySMTPAddress
        $Name = $Mailbox.Name
        $Guid = $Mailbox.Guid
        Write-Host "Name `t $Name`tDisplayName $DisplayName"
        try {
            $Mbx = Get-Mailbox -identity $Guid -erroraction stop
            $MbxDisplayName = $Mbx.DisplayName
            Write-Host "SUCCESS GET $MbxDisplayName" -ForegroundColor Green
            try {
                $Mbx | Set-Mailbox -UserPrincipalName $PrimarySmtpAddress -erroraction stop
                Write-Host "SUCCESS SET $MbxDisplayName" -ForegroundColor Green
            }
            catch {
                Write-Host "FAILED SET: $DisplayName" -ForegroundColor Red
                Add-Content -Path $ErrorLog -Value ("SETFailed" + "," + $DisplayName + "," + $($_.Exception.Message))
            }
        }
        catch {
            Write-Host "FAILED GET: $DisplayName" -ForegroundColor Red
            Add-Content -Path $ErrorLog -Value ("GETFailed" + "," + $DisplayName + "," + $($_.Exception.Message))
        }
    }
}

