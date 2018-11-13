function Get-OktaAppUserHash {
    param (

    )
    $App = Get-OktaApp
    Foreach ($CurApp in $App.id) {
        $Users = @{}
        Get-OktaAppUser -AppId $CurApp | ForEach-Object {
            if (-not $Users.Contains($CurApp)) {
                $Users[$CurApp] = [system.collections.arraylist]::new()
            } 
            $null = $Users[$CurApp].Add($_.id)
        }
        $Users       
    }
}