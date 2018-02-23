Function Grant-FullAccessToMailbox {
    <#
    .SYNOPSIS
    Grants Full Access mailbox permissions for one or more users over another mailbox

    .EXAMPLE
    "fred.smith@contoso.com","frank.jones@contoso.com" | Grant-FullAccessToMailbox -Mailbox "john.smith@contoso.com"
   
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $Mailbox,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $UserNeedingAccess
    )
    
    Begin {

        $RootPath = $env:USERPROFILE + "\ps\"
        $User = $env:USERNAME
    
        While (!(Get-Content ($RootPath + "$($user).DomainController") -ErrorAction SilentlyContinue | ? {$_.count -gt 0})) {
            Select-DomainController
        }
        $DomainController = Get-Content ($RootPath + "$($user).DomainController")   
        
        While (!(Get-Content ($RootPath + "$($user).TargetAddressSuffix") -ErrorAction SilentlyContinue | Where-Object {$_.count -gt 0})) {
            Select-TargetAddressSuffix
        }
        $targetAddressSuffix = Get-Content ($RootPath + "$($user).TargetAddressSuffix")

        try {
            (Get-CloudAcceptedDomain -erroraction stop)[0] | Out-Null
        }
        catch {
            Connect-Cloud $targetAddressSuffix -ExchangeOnline -EXOPrefix
        }

    }
    Process {
        
        Add-CloudMailboxPermission -AccessRights FullAccess -Identity $Mailbox -User $UserNeedingAccess
    }
    End {
    
    }
}    
