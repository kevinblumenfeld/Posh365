function Add-UserToOktaGroup {
    <#
    .SYNOPSIS
    Add Uses to Okta Groups

    .DESCRIPTION
    Add any user that lives in Okta to Okta Groups (these are groups mastered in Okta Only)

    .PARAMETER UserList
    This is a list of logins (Microsoft uses the term UserPrincipalName) fed by pipeline (See Examples)

    .PARAMETER GroupName
    This is the name of the Okta Group

    .EXAMPLE
    Import-Csv .\users2add.csv | Add-UserToOktaGroup -GroupName "Accounting"

    .NOTES
    CSV must have at least one column with header named either UserPrincipalName OR Login

    for example...

    DisplayName, UserPrincipalName, Email
    Jane Smith, Jane@contoso.com, Jane@contoso.com
    Joe Smith, Joe@contoso.com, Joe@contoso.com

    OR

    DisplayName, Login, Email
    Jane Smith, Jane@contoso.com, Jane@contoso.com
    Joe Smith, Joe@contoso.com, Joe@contoso.com

    OR

    Login
    Jane@contoso.com
    Joe@contoso.com
    Fred@contoso.com
    Sally@contoso.com

    #>

    Param (

        [Parameter(Mandatory)]
        [string] $GroupName,

        [Parameter(ValueFromPipeline)]
        [Alias("Login", "UserPrincipalName")]
        $UserList

    )
    begin {
        $GroupId = (Get-OktaGroupReport -filter 'type eq "OKTA_GROUP"' | Where-Object {$_.Name -eq $GroupName}).id
        if (-not $GroupId) {
            Write-Host "-------------------------------------------------------------------" -ForegroundColor "Red" -BackgroundColor "White"
            Write-Host "              Group: NOT FOUND. PLEASE TRY AGAIN!                  " -ForegroundColor "Red" -BackgroundColor "White"
            Write-Host "              Try finding your group like this...                  " -ForegroundColor "Red" -BackgroundColor "White"
            Write-Host "  Get-OktaGroupReport -SearchString TheFirstFewLettersOfGroupName  " -ForegroundColor "Red" -BackgroundColor "White"
            Write-Host "-------------------------------------------------------------------" -ForegroundColor "Red" -BackgroundColor "White"
            break
        }
        Write-Host "Group: $GroupName     ID:$GroupId" -ForegroundColor "Blue" -BackgroundColor "White"
    }
    process {
        foreach ($User in $UserList) {
            $Login = $User.Login
            $Url = $OKTACredential.GetNetworkCredential().username
            $Token = $OKTACredential.GetNetworkCredential().Password
            $Headers = @{
                "Authorization" = "SSWS $Token"
                "Accept"        = "application/json"
                "Content-Type"  = "application/json"
            }
            $UserId = (Get-SingleOktaUserReport -Login $Login).id

            $RestSplat = @{
                Uri     = 'https://{0}.okta.com/api/v1/groups/{1}/users/{2}' -f $Url, $GroupId, $UserId
                Headers = $Headers
                Method  = 'Put'
            }
            $Response = Invoke-WebRequest @RestSplat

            Write-Host -ForegroundColor Green "Adding:`t$Login`tID:$UserId"
        }
    }
    end {

    }

}
