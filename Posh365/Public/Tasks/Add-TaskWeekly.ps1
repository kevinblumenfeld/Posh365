function Add-TaskWeekly {
    <#
    .SYNOPSIS
        Create Scheduled Tasks that run on a weekly schedule

    .DESCRIPTION
        Create Scheduled Tasks that run on a weekly schedule
        Make sure directory structure is in place

    .PARAMETER TaskName
        Name of the Scheduled Task to create

    .PARAMETER User
        User name would under which the Scheduled Task will run
        Either Domain\User or ComputerName\User

    .PARAMETER WeeksInterval
        Denotes how often to run the task.  3 would indicate once every 3 weeks.

    .PARAMETER DaysOfWeek
        Denotes which days of the week to run the task.  Monday,Tuesday,Thursday,Sunday
        Do not use quotes around the argument

    .PARAMETER At
        Start "At" this time.  For example 4am or 5pm

    .PARAMETER Disabled
        If used, Task will be created as "Disabled".  Otherwise Task will be Enabled by default

    .PARAMETER Executable
        Which executable this Scheduled Task will execute

    .PARAMETER Argument
        The arguments to pass to the executable

    .EXAMPLE
        Add-TaskWeekly -TaskName "TaskToSetLitHold_Weekly" -User "Server01\Service" -Executable "PowerShell.exe" -Argument '-ExecutionPolicy RemoteSigned -Command "Set-LitigationHold"' -At 10:35am -DaysOfWeek Monday, Tuesday, Wednesday -WeeksInterval 2

    .EXAMPLE

    $TaskSplat = @{
        TaskName      = "Lit_Hold_Task"
        User          = "srv01\user"
        Executable    = "PowerShell.exe"
        Argument      = '-ExecutionPolicy RemoteSigned -Command Set-LitigationHold -LogFilePath c:\LitLog\ -LogFile LitLog.txt -Owner admin@lapcm.onmicrosoft.com'
        At            = "11:22am"
        DaysOfWeek    = "Monday", "Tuesday", "Wednesday"
        WeeksInterval = 1
    }
    
    Add-TaskWeekly @TaskSplat

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
        [DayOfWeek[]] $DaysOfWeek,

        [Parameter(Mandatory = $true)]
        [int] $WeeksInterval,

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
        Weekly        = $true
        At            = $At
        WeeksInterval = $WeeksInterval
        DaysOfWeek    = $DaysOfWeek
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