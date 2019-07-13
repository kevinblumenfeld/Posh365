function global:Get-RemotingHandler() {
    <#
    .SYNOPSIS Override Get-PSImplicitRemotingSession function for reconnection
    #>
    $modules = Get-Module tmp_*

    foreach ($module in $modules) {
        [bool]$moduleProcessed = $false
        [string] $moduleUrl = $module.Description
        [int] $queryStringIndex = $moduleUrl.IndexOf("?")

        if ($queryStringIndex -gt 0) {
            $moduleUrl = $moduleUrl.SubString(0, $queryStringIndex)
        }

        if ($moduleUrl.EndsWith("/PowerShell-LiveId", [StringComparison]::OrdinalIgnoreCase) -or $moduleUrl.EndsWith("/PowerShell", [StringComparison]::OrdinalIgnoreCase)) {
            & $module { ${function:Get-PSImplicitRemotingSession} = `
                {
                    param(
                        [Parameter(Mandatory = $true, Position = 0)]
                        [string]
                        $commandName
                    )

                    if (($script:PSSession -eq $null) -or ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')) {
                        Set-PSImplicitRemotingSession `
                        (& $script:GetPSSession `
                                -InstanceId $script:PSSession.InstanceId.Guid `
                                -ErrorAction SilentlyContinue )
                    }
                    if (($script:PSSession -ne $null) -and ($script:PSSession.Runspace.RunspaceStateInfo.State -eq 'Disconnected')) {
                        # If we are handed a disconnected session, try re-connecting it before creating a new session.
                        Set-PSImplicitRemotingSession `
                        (& $script:ConnectPSSession `
                                -Session $script:PSSession `
                                -ErrorAction SilentlyContinue)
                    }
                    if (($script:PSSession -eq $null) -or ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')) {
                        Write-PSImplicitRemotingMessage ('Creating a new Remote PowerShell session using MFA for implicit remoting of "{0}" command ...' -f $commandName)
                        $session = New-ExoPSSession -UserPrincipalName $global:UserPrincipalName -ConnectionUri $global:ConnectionUri -AzureADAuthorizationEndpointUri $global:AzureADAuthorizationEndpointUri -PSSessionOption $global:PSSessionOption -Credential $global:Credential

                        if ($session -ne $null) {
                            Set-PSImplicitRemotingSession -CreatedByModule $true -PSSession $session
                        }

                        RemoveBrokenOrClosedPSSession
                    }
                    if (($script:PSSession -eq $null) -or ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')) {
                        throw 'No session has been associated with this implicit remoting module'
                    }

                    return [Management.Automation.Runspaces.PSSession]$script:PSSession
                } }
        }
    }
}
