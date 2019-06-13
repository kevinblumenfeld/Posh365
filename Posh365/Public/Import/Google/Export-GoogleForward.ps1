
function Export-GoogleForward {


    [CmdletBinding()]
    Param
    (

    )

    $AllGS = Get-GSUser -Filter *
    foreach ($All in $AllGS) {
        $fwd = Get-GSGmailAutoForwardingSettings -User $All.User | Select-Object -ExpandProperty EmailAddress
        [PSCustomObject]@{
            Name    = $All.Name.FullName
            User    = $All.User
            Forward = $fwd
        }
    }
}
