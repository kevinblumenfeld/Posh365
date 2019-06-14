function Get-LegacyPFStatistics {
    <#

    #>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [Microsoft.Exchange.Data.Mapi.PublicFolder] $PFList
    )
    Begin {

    }
    Process {
        foreach ($PF in $PFList) {
            $ParentPath = $PF.ParentPath
            $FolderType = $PF.FolderType
            $MailEnabled = $PF.MailEnabled
            $PF | Get-PublicFolderStatistics | Select-Object @(
                'Name'
                @{
                    Name       = 'ParentPath'
                    Expression = { $ParentPath }
                }
                'FolderPath'
                @{
                    Name       = 'MailEnabled'
                    Expression = { $MailEnabled }
                }
                @{
                    Name       = 'PublicFolderGB'
                    Expression = {
                        [Math]::Round([Double](((($_.TotalItemSize -split '\(')[1] -split ' ')[0]) -replace ',') / 1GB, 5)
                    }
                }
                @{
                    Name       = 'FolderType'
                    Expression = { $FolderType }
                }
                'LastUserAccessTime'
                'DatabaseName'
            )
        }
    }
    End {

    }
}
