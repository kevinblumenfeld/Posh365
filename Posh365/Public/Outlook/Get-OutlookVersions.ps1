function Get-OutlookVersions {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .EXAMPLE
    $OutlookData = Get-OutlookVersions -Days 5
    $OutlookData | Select-Object * -Unique | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OutlookReport.csv')
    $OutlookData | Group-Object -Property "client-software-version" | Select-Object @(
        @{
            Name       = 'Version'
            Expression = { $_.Name }
        }
        'Count'
    ) | Export-Csv @CSVSplat -Path (Join-Path -Path $CSV -ChildPath 'Ex_OutlookCount.csv')

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Days
    )
    end {
        $ServerList = @(Get-ExchangeServer | Where-Object {
                (($_.IsClientAccessServer -eq '$true') -and (($_.AdminDisplayVersion).split(' ')[1] -eq '14')) -or
                (($_.IsMailboxServer -eq '$true') -and (($_.AdminDisplayVersion).split(' ')[1] -ge '15'))
            } | Select-Object @(
                'Name'
                @{
                    Name       = 'Path'
                    Expression = { ("\\$($_.fqdn)\" + "$($_.Datapath)").Replace(':', '$').Replace('Mailbox', 'Logging\RPC Client Access') }
                }
            )
        )
        $FileList = foreach ($Server in $ServerList) {
            Write-Verbose "Discovering Logs on`t$($Server.Name)"
            Get-ChildItem -Path $Server.Path -Filter *.log |
            Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-$Days) } |
            Select-Object @(
                @{
                    Name       = 'File'
                    Expression = { ("$($Server.Path)" + "\$($_.Name)") }
                }
            )
        }
        foreach ($File in $FileList) {
            Write-Verbose "Inspecting CAS Logs: $($File.File)"
            Invoke-GetOutlookData -LogPath $File.File
        }
    }
}
