function Sync-AD {

Param ()
    <#
    .SYNOPSIS
    Force Replication on each Domain Controller in the Forest 
    
    .EXAMPLE

    Sync-AD
  
    #>
   
    ### Force Replication on each Domain Controller in the Forest ###
    $session = New-PSSession -ComputerName ($env:LOGONSERVER).Split("\")[2]
    Invoke-Command -Session $session -ScriptBlock {((Get-ADForest).Domains | % { Get-ADdomainController -Filter * -Server $_ }).hostname | % {repadmin /syncall /APeqd $_}}
    Remove-PSSession $session
}