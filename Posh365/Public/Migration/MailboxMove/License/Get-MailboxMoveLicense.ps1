function Get-MailboxMoveLicense {
    param (
        [Parameter()]
        [switch]
        $IncludeRecipientType
      )
    end {

        $PoshPath = (Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath Posh365 )

        $ItemSplat = @{
            Type        = 'Directory'
            Force       = $true
            ErrorAction = 'SilentlyContinue'
            Path        = $PoshPath
        }
        $null = New-Item @ItemSplat

        $ExcelSplat = @{
            Path                    = (Join-Path -Path $PoshPath -ChildPath ('Licenses_{0}.xlsx' -f [DateTime]::Now.ToString('yyyy-MM-dd-hhmm')))
            TableStyle              = 'Medium2'
            FreezeTopRowFirstColumn = $true
            AutoSize                = $true
            BoldTopRow              = $false
            ClearSheet              = $true
            ErrorAction             = 'SilentlyContinue'
        }
        Write-Host 'Creating Excel file . . . ' -ForegroundColor Cyan
        $UserChoice = Get-AzureADUser -filter "UserType eq 'Member'" -All:$true

        $Splat = @{
            OnePerLine           = $true
            IncludeRecipientType = $IncludeRecipientType
            All                  = $true
            UserChoice           = $UserChoice
        }

        Invoke-GetMailboxMoveLicenseUserSku @Splat | Export-Excel @ExcelSplat
        Write-Host 'Excel file saved in the folder Posh365, on the Desktop' -ForegroundColor Green
    }
}
