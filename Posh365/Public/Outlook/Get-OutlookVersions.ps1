function Get-OutlookVersions {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .EXAMPLE
    $OutlookData = Get-OutlookVersions
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

    )
    end {
        $Data = [System.Collections.Generic.List[string]]::New()
        $ServerList = @(Get-ExchangeServer | Where-Object {
                (($_.IsClientAccessServer -eq '$true') -and (($_.AdminDisplayVersion).major -eq '14')) -or
                (($_.IsMailboxServer -eq '$true') -and (($_.AdminDisplayVersion).major -ge '15'))
            } | Select-Object @(
                'Name'
                @{
                    Name       = 'Path'
                    Expression = { ("\\$($_.fqdn)\" + "$($_.Datapath)").Replace(':', '$').Replace('Mailbox', 'Logging\RPC Client Access') }
                }
            )
        )
        foreach ($Server in $ServerList) {
            $FileList = @(
                Get-ChildItem -Path $Server.Path -Filter *.log |
                Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-5) } |
                Select-Object @(
                    @{
                        Name       = 'File'
                        Expression = { ("$($Server.Path)" + "\$($_.Name)") }
                    }
                )
            )
        }
        foreach ($File in $FileList) {
            Write-Host "Working with file $($File.File)" -ForegroundColor DarkYellow
            $Data.Add((Invoke-GetOutlookData $File.File))
        }
        $Data
    }
}
