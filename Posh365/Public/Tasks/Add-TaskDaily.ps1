function Add-TaskDaily {
    <#
    .SYNOPSIS
        Create Scheduled Tasks that run daily

    .DESCRIPTION
        Create Scheduled Tasks that run daily

    .PARAMETER TaskName
        Name of the Scheduled Task to create

    .PARAMETER User
        User name would under which the Scheduled Task will run
        Either Domain\User or ComputerName\User
            
    .PARAMETER DaysInterval
        Denotes how often to run the task.  3 would indicate once every 3 days.

    .PARAMETER At
        Start "At" this time.  For example 4am or 5pm

    .PARAMETER Disabled
        If used, Task will be created as "Disabled".  Otherwise Task will be Enabled by default

    .PARAMETER Executable
        Which executable this Scheduled Task will execute

    .PARAMETER Argument
        The arguments to pass to the executable

    .EXAMPLE
        Add-TaskDaily -TaskName "SetLitigationHold_Nighly" -User "Server01\kevin" -Executable "PowerShell.exe" -Argument '-ExecutionPolicy RemoteSigned -Command "Set-LitigationHold"' -DaysInterval 1 -At 1am

    .NOTES
        General notes
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string] $TaskName,
        
        [Parameter(Mandatory = $true)]
        [string] $User,

        [Parameter(Mandatory = $true)]
        [int] $DaysInterval,

        [Parameter(Mandatory = $true)]
        [datetime] $At,

        [Parameter(Mandatory = $false)]
        [switch] $Disabled,

        [Parameter(Mandatory = $true)]
        [string] $Executable,
        
        [Parameter(Mandatory = $true)]
        [string] $Argument
    )

    $SchedTaskCred = Get-Credential $User -Message "Scheduled Task Service Account Credentials"
    $SchedTaskCredUser = $SchedTaskCred.UserName
    $SchedTaskCredPwd = $SchedTaskCred.GetNetworkCredential().Password

    $ActionSplat = @{
        Execute  = $Executable
        Argument = $Argument
    }

    $TriggerSplat = @{
        Daily        = $true
        At           = $At
        DaysInterval = $DaysInterval
    }

    $SettingsSplat = @{
        StartWhenAvailable         = $true
        DontStopIfGoingOnBatteries = $true
        AllowStartIfOnBatteries    = $true
    }

    if ($Disabled) {
        $SettingsSplat.Add("Disable", $true)
    }

    $Action = New-ScheduledTaskAction @ActionSplat
    $Trigger = New-ScheduledTaskTrigger @TriggerSplat
    $Settings = New-ScheduledTaskSettingsSet @SettingsSplat  

    $TaskSplat = @{
        Action   = $Action
        Trigger  = $Trigger
        Settings = $Settings
    }

    $Task = New-ScheduledTask @TaskSplat

    $RegisterSplat = @{
        TaskName    = $TaskName
        InputObject = $Task
        User        = $SchedTaskCredUser
        Password    = $SchedTaskCredPwd
    }

    Register-ScheduledTask @RegisterSplat

}