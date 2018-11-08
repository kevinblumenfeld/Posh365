function Test-PreCheck {
    param (
        [Parameter(Mandatory = $true)]
        [string] $CsvFilePath
    )
    $User = Import-Csv $CsvFilePath
    foreach ($CurUser in $User) {
        try {
            $User = $CurUser.User

            $Properties = @(
                "DisplayName"
            )
            $Calculated = @(
                @{n = "Routing" ; e = {( $_.ProxyAddresses | Where-Object {$_ -like '*@*.mail.onmicrosoft.com'})}}
            )
            $Cloud = Get-MsolUser -UserPrincipalName $User -ErrorAction Stop | 
                Select-Object ($Properties + $Calculated)

            [pscustomobject]@{
                Notes       = ""
                DisplayName = $Cloud.DisplayName
                User        = $User
                Routing     = $Cloud.Routing
                Result      = "SUCCESS"
                Message     = ""
            }
        }
        catch {
            $WhyFailed = $_.Exception.Message
            [pscustomobject]@{
                Notes       = ""
                DisplayName = ""
                Routing     = ""
                User        = $User
                Result      = "FAILED"
                Message     = $WhyFailed
            }
        }
    }
}
