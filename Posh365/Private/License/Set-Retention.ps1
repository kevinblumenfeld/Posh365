Function Set-Retention {
    <#
    .SYNOPSIS
    
    .EXAMPLE

    #>
    [CmdletBinding()]
    Param (
    
        [Parameter()]
        [string[]] $UserPrincipalName,
    
        [Parameter()]
        [string] $RetentionPolicyToAdd
    )

    $RootPath = $env:USERPROFILE + "\ps\"
    $User = $env:USERNAME

    $targetAddressSuffix = Get-Content ($RootPath + "$($user).TargetAddressSuffix")

    $RetentionJob = Start-Job -Name Set-Retention {
        $UserPrincipalName = $args[0]
        $RententionPolicyToAdd = $args[1]
        $targetAddressSuffix = $args[2]
        Connect-Cloud $targetAddressSuffix -ExchangeOnline -EXOPrefix
        while (!(Get-Mailbox $UserPrincipalName -ErrorAction SilentlyContinue)) {
            Start-Sleep -Seconds 30
        }
        Set-CloudMailbox $UserPrincipalName -RetentionPolicy $RetentionPolicyToAdd
        Get-PSSession | Remove-PSSession
    } -ArgumentList $UserPrincipalName, $RetentionPolicyToAdd, $targetAddressSuffix | Out-Null 
}    
