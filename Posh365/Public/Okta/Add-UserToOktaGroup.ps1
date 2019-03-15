function Add-UserToOktaGroup {
    <#
    .SYNOPSIS
    Add Users to Okta Groups

    .DESCRIPTION
    Add any user that lives in Okta to Okta Groups (these are groups mastered in Okta Only)

    .PARAMETER GroupName
    The name of the Okta group

    .PARAMETER UserPrincipalName
    To add a user to a group without feeding from pipeline use this see example below

    .PARAMETER User
    This is used by the script when feeding users via pipeline

    .EXAMPLE
    Import-Csv .\users.csv | Add-UserToOktaGroup -GroupName 'Accounting' -Verbose

    .EXAMPLE
    Add-UserToOktaGroup -GroupName 'Accounting' -UserPrincipalName 'jane@contoso.com' -Verbose

    .EXAMPLE
    Add-UserToOktaGroup -GroupName 'Accounting' -UserPrincipalName 'jane@contoso.com','joe@contoso.com' -Verbose

    .NOTES
    CSV must have at least one column with header named login

    for example...

    DisplayName, Login, Email
    Jane Smith, Jane@contoso.com, Jane@contoso.com
    Joe Smith, Joe@contoso.com, Joe@contoso.com

    OR perhaps just one column

    Login
    Jane@contoso.com
    Joe@contoso.com
    Fred@contoso.com
    Sally@contoso.com

    #>

    [CmdletBinding(DefaultParameterSetName = 'UPN')]
    param(

        [Parameter(Position = 0, Mandatory)]
        [string]
        $GroupName,

        [Parameter(Position = 1, ParameterSetName = "UPN")]
        [Alias("UPN")]
        [string[]]
        $UserPrincipalName,

        [Parameter()]
        [string] $ErrorLog,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = "Pipeline")]
        [Alias("InputObject")]
        [object[]]
        $User

    )
    begin {
        $GroupId = Get-OktaGroupReport -Filter 'type eq "OKTA_GROUP"' |
            Where-Object Name -eq $GroupName |
            Select-Object -ExpandProperty id

        if (-not $GroupId) {
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                [ArgumentException]::new("Group $GroupName not found. Please try again, or locate the group name first with <Get-OktaGroupReport -SearchString TheFirstFewLettersOfGroupName>."),
                'Okta.GroupNotFound',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $GroupName
            )

            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }

        Write-Information ("Group: {0} ID: {1}" -f $GroupName, $GroupId)
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "UPN" {
                foreach ($Object in $UserPrincipalName) {
                    $Url = $OKTACredential.GetNetworkCredential().username
                    $Token = $OKTACredential.GetNetworkCredential().Password
                    $UserLU = Get-SingleOktaUserReport -Login $Object
                    $Headers = @{
                        "Authorization" = "SSWS $Token"
                        "Accept"        = "application/json"
                        "Content-Type"  = "application/json"
                    }

                    $RestSplat = @{
                        Uri     = 'https://{0}.okta.com/api/v1/groups/{1}/users/{2}' -f $Url, $GroupId, $UserLU.id
                        Headers = $Headers
                        Method  = 'Put'
                    }
                    $null = Invoke-WebRequest @RestSplat -Verbose:$false

                    Write-Verbose ("Adding: {0} ID: {1}" -f $Object, $UserLU.id)
                }
            }
            "Pipeline" {
                if ($MyInvocation.ExpectingInput) {
                    $User = , $User
                }

                foreach ($Object in $User) {
                    $Url = $OKTACredential.GetNetworkCredential().username
                    $Token = $OKTACredential.GetNetworkCredential().Password
                    try {
                        $UserLU = Get-SingleOktaUserReport -Login $Object.Login -ErrorAction Stop
                        write-host $UserLU.status
                        if ($UserLu.status -eq 'DEPROVISIONED') {
                            Write-Host "USER DEPROVISIONED: $($Object.Login)" -ForegroundColor RED
                            if ($ErrorLog) {
                                Add-Content -Path $ErrorLog -Value ("USERDEPROVISIONED" + "," + $Object.Login + "," + "USERDEPROVISIONED")
                            }
                            continue
                        }
                        else {

                            Write-Host "USER FOUND: $($Object.Login)" -ForegroundColor Green

                            $Headers = @{
                                "Authorization" = "SSWS $Token"
                                "Accept"        = "application/json"
                                "Content-Type"  = "application/json"
                            }

                            $RestSplat = @{
                                Uri     = 'https://{0}.okta.com/api/v1/groups/{1}/users/{2}' -f $Url, $GroupId, $UserLU.id
                                Headers = $Headers
                                Method  = 'Put'
                            }
                            try {
                                Write-Verbose ("Adding: {0} ID: {1}" -f $Object.Login, $UserLU.id)
                                $null = Invoke-WebRequest @RestSplat -Verbose:$false -ErrorAction Stop
                                Write-Host "SUCCESS ADD: $($Object.Login)" -ForegroundColor Green
                            }
                            catch {
                                Write-Host "FAILED ADD: $($Object.Login)" -ForegroundColor Red
                                if ($ErrorLog) {
                                    Add-Content -Path $ErrorLog -Value ("FAILEDTOADD" + "," + $Object.Login + "," + $($_.Exception.Message))
                                }

                            }
                        }
                    }
                    catch {
                        Write-Host "USER NOT FOUND:`t$($Object.Login)" -ForegroundColor Red
                        if ($ErrorLog) {
                            Add-Content -Path $ErrorLog -Value ("USERNOTFOUND" + "," + $Object.Login + "," + $($_.Exception.Message))
                        }
                    }
                }
            }
        }
    }
    end {

    }

}
