function Get-BTUserHash {
    [CmdletBinding()]
    Param
    (

    )
    end {
        $Script:UserHash = @{ }
        foreach ($User in Get-BT_CustomerEndUser -Ticket $BitTic -IsDeleted:$false -RetrieveAll:$true) {
            if (-not $UserHash.ContainsKey($User.Id.ToString())) {
                $UserHash.Add($User.Id.ToString(), @{
                        DisplayName         = $User.DisplayName
                        FirstName           = $User.FirstName
                        LastName            = $User.LastName
                        PrimaryEmailAddress = $User.PrimaryEmailAddress
                        AgentSendStatus     = $User.AgentSendStatus
                    }
                )
            }
        }
    }
}
