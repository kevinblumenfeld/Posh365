function Invoke-FindSpill {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Tenant,

        [Parameter()]
        [ValidateSet('ConversationHistory', 'Conflicts', 'Drafts', 'localfailures', 'scheduled', 'searchfolders', 'serverfailures', 'syncissues')]
        $__Folder_Other,

        [Parameter()]
        [switch]
        $_Folder_Root,

        [Parameter()]
        [switch]
        $_Folder_Archive,

        [Parameter()]
        [switch]
        $_Folder_Clutter,

        [Parameter()]
        [switch]
        $_Folder_DeletedItems,

        [Parameter()]
        [switch]
        $_Folder_Inbox,

        [Parameter()]
        [switch]
        $_Folder_Outbox,

        [Parameter()]
        [switch]
        $_Folder_RecoverableItems,

        [Parameter()]
        [switch]
        $_Folder_SentItems,

        [Parameter()]
        [switch]
        $_Recurse,

        [Parameter()]
        [switch]
        $DeleteCreds,

        [Parameter()]
        [datetime]
        $MessagesOlderThan,

        [Parameter()]
        [datetime]
        $MessagesNewerThan,

        [Parameter()]
        [switch]
        $OptionToDeleteMessages,

        [Parameter()]
        [string]
        $_Message_Body,

        [Parameter()]
        [string]
        $_Message_Subject,

        [Parameter()]
        [string]
        $_Message_From,

        [Parameter()]
        [string]
        $_Message_CC,

        [Parameter()]
        [int]
        [ValidateSet(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 510, 520, 530, 540, 550, 560, 570, 580, 590, 600, 610, 620, 630, 640, 650, 660, 670, 680, 690, 700, 710, 720, 730, 740, 750, 760, 770, 780, 790, 800, 810, 820, 830, 840, 850, 860, 870, 880, 890, 900, 910, 920, 930, 940, 950, 960, 970, 980, 990, 1000, 2000, 3000, 4000, 5000, 10000, 20000, 30000, 200000)]
        $Count,

        [Parameter()]
        [mailaddress[]]
        $UserPrincipalName
    )
    try {
        Connect-PoshGraph -Tenant $Splat.Tenant
        $FolderList = [System.Collections.Generic.List[string]]::New()
        $Params = @{ }
        if ($Count) { $Params['Top'] = $Count } else { $Params['Top'] = 10 }
        foreach ($Key in $Splat.keys) {
            if ($Splat[$Key] -and $Key -like '_Message_*') {
                $Params[$Key] = $Splat[$Key]
            }
        }
        $Script:IncludeRecoverableItems = $false
        $Recurse = $false
        if ($Splat.keys -contains '_Folder_Root') {
            @('Archive', 'Clutter', 'DeletedItems', 'Inbox', 'Outbox', 'SentItems', 'ConversationHistory'
                'Conflicts', 'Drafts', 'localfailures', 'scheduled', 'searchfolders'
                'serverfailures', 'syncissues').ForEach{ $FolderList.Add($_) }
        }
        else {
            if ($Splat.keys -contains '_Folder_RecoverableItems') { $Script:IncludeRecoverableItems = $true }
            foreach ($Key in $Splat.keys) {
                if ($Splat[$Key] -and $Key -like '_Folder_*' -and $key -ne '_Folder_RecoverableItems' ) { $FolderList.Add($Key.replace('_Folder_', '')) }
                if ($Splat.ContainsKey('__Folder_Other')) { $FolderList.Add($Splat['__Folder_Other']) }
            }
        }

        if ($Splat.ContainsKey('_Recurse')) { $Recurse = $true }

        if ($FolderList) {
            if (-not $Splat['UserPrincipalName']) {
                Get-GraphUserAll | Get-GraphMailFolder -WellKnownFolder $FolderList -Recurse:$Recurse | Get-GraphMailFolderMessageById @Params
            }
            else {
                $Splat['UserPrincipalName'] | Get-GraphUser | Get-GraphMailFolder -WellKnownFolder $FolderList -Recurse:$Recurse | Get-GraphMailFolderMessageById @Params
            }
        }
        if ($Script:IncludeRecoverableItems) {
            if (-not $Splat['UserPrincipalName']) {
                Get-GraphUserAll | Get-GraphUser | Get-GraphMailFolderRecoverableItems -ErrorAction SilentlyContinue | Get-GraphMailFolderMessageById @Params
            }
            else {
                $Splat['UserPrincipalName'] | Get-GraphUser | Get-GraphMailFolderRecoverableItems -ErrorAction SilentlyContinue | Get-GraphMailFolderMessageById @Params
            }
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Cyan
        return
    }
}
