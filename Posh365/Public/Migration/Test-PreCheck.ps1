function Test-PreCheck {
    param (
        [Parameter(Mandatory = $true)]
        [string] $CsvFilePath
    )
    $User = Import-Csv $CsvFilePath
    foreach ($User in $UserList) {
        try {

            $Cloud = Get-MsolUser -UserPrincipalName $User.UserPrincipalName -ErrorAction Stop | Select-Object @(
                'DisplayName'
                @{
                    Name       = "Routing"
                    Expression = { $_.ProxyAddresses | Where-Object { $_ -like '*@*.mail.onmicrosoft.com' } }
                }
            )

            [pscustomobject]@{
                Notes       = 'SUCCESS'
                DisplayName = $Cloud.DisplayName
                User        = $User.UserPrincipalName
                Routing     = $Cloud.Routing
                Result      = 'SUCCESS'
                Message     = 'SUCCESS'
            }
        }
        catch {
            [pscustomobject]@{
                Notes       = 'FAILED'
                DisplayName = 'FAILED'
                Routing     = 'FAILED'
                User        = $User.UserPrincipalName
                Result      = 'FAILED'
                Message     = $_.Exception.Message
            }
        }
    }
}
