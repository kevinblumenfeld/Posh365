function Add-Task {
    <#
    .SYNOPSIS
        Create Scheduled Tasks

    .DESCRIPTION
        Create Scheduled Tasks

    .PARAMETER TaskName
        Name of the Scheduled Task to create

    .PARAMETER User
        User name would under which the Scheduled Task will run
        Either Domain\User or ComputerName\User

    .PARAMETER Disabled
        If used, Task will be created as "Disabled".  Otherwise Task will be Enabled by default

    .PARAMETER RepeatInMinutes
        How frequently the task should repeat

    .PARAMETER RepetitionDuration
        Repetition Duration is by default, "Indefinitely".
        Only use this parameter to set the duration to something other than "Indefinitely"

    .PARAMETER Executable
        Which executable this Scheduled Task will execute

    .PARAMETER Argument
        The arguments to pass to the executable

    .EXAMPLE
        Add-Task -TaskName "Audit Log Collection" -User "ComputerName\Logs" -RepeatInMinutes 60 -Executable "PowerShell.exe" -Argument '-ExecutionPolicy RemoteSigned -Command "Get-AuditLog -Tenant LAPCM -Path C:\Logs\ -FileName 365Log -TimeFrameInMinutes 60"'
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string] $TaskName,
        
        [Parameter(Mandatory = $true)]
        [string] $User,
        
        [Parameter(Mandatory = $false)]
        [switch] $Disabled,

        [Parameter(Mandatory = $true)]
        [int] $RepeatInMinutes,

        [Parameter(Mandatory = $false)]
        [int] $RepetitionDuration,

        [Parameter(Mandatory = $true)]
        [string] $Executable,
        
        [Parameter(Mandatory = $true)]
        [string] $Argument
    )

    $TaskStartTime = (Get-Date).DateTime
    $Repeat = (New-TimeSpan -Minutes $RepeatInMinutes)
    $SchedTaskCred = Get-Credential $User -Message "Scheduled Task Service Account Credentials"
    $SchedTaskCredUser = $SchedTaskCred.UserName
    $SchedTaskCredPwd = $SchedTaskCred.GetNetworkCredential().Password

    $ActionSplat = @{
        Execute  = $Executable
        Argument = $Argument
    }

    $TriggerSplat = @{
        Once               = $true
        At                 = $TaskStartTime
        RepetitionInterval = $Repeat
    }

    if ($RepetitionDuration) {
        $RepDuration = (New-TimeSpan -Minutes $RepetitionDuration)
        $TriggerSplat.Add("RepetitionDuration", $RepDuration)
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