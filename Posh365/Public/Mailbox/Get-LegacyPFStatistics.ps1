function Get-LegacyPFStatistics {
    <#

    #>
    [CmdletBinding()]
    param (

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [Microsoft.Exchange.Data.Mapi.PublicFolder] $PublicFolder
    )
    Begin {

    }
    Process {
        foreach ($CurPublicFolder in $PublicFolder) {
            $ParentPath = $CurPublicFolder.ParentPath
            $FolderType = $CurPublicFolder.FolderType
            $MailEnabled = $CurPublicFolder.MailEnabled
            $CurPublicFolder | Get-PublicFolderStatistics | Select-Object @(
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