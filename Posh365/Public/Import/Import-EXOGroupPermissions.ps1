function Import-EXOGroupPermissions {
    <#
    .SYNOPSIS
    Applies permissions to Exchange Online Groups

    .DESCRIPTION
    Applies permissions to Exchange Online Groups

    .EXAMPLE
    Import-Csv .\contoso-EXOPermissions_All.csv | Import-EXOGroupPermissions

    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Permission
    )
    Begin {

    }
    Process {
        ForEach ($CurPermission in $Permission) {
            $type = $CurPermission.Permission
            switch ( $type ) {
                SendAs {
                    Write-Verbose "Granting $($CurPermission.Granted) $($CurPermission.Permission) permission over group: $($CurPermission.Object)"
                    Add-RecipientPermission -Identity $CurPermission.PrimarySmtpAddress -Trustee $CurPermission.GrantedSMTP -AccessRights SendAs -Confirm:$False
                }
                SendOnBehalf {
                    Write-Verbose "Granting $($CurPermission.Granted) $($CurPermission.Permission) permission over group: $($CurPermission.Object)"
                    Set-DistributionGroup $CurPermission.PrimarySmtpAddress -GrantSendOnBehalfTo $CurPermission.GrantedSMTP -Confirm:$False
                }
            }
        }
    }
    End {

    }
}
