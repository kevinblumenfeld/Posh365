function Import-ExchangeFullAccess { 
    <#
    .SYNOPSIS
    Import Full Access Permissions from a CSV via the pipeline

    .DESCRIPTION
    Import Full Access Permissions from a CSV via the pipeline
    Script expects Data Source to have 2 headers named, PrimarySmtpAddress & ObjectWithAccess
    You can replace values in ObjectWithAccess with Domain, NewDomain parameters

    .PARAMETER Domain
    Find this domain in ObjectWithAccess and change it to value in NewDomain parameter

    .PARAMETER NewDomain
    ObjectWithAccess domain will be changed to this domain

    .PARAMETER DontAutoMap
    Parameter description

    .PARAMETER Row
    Parameter description

    .EXAMPLE
    Import-Csv c:\scripts\FAPerms.csv | Import-ExchangeFullAccess -Verbose
    
    .EXAMPLE
    Import-Csv c:\scripts\FAPerms.csv | Import-ExchangeFullAccess -Domain "fabrikam.com" -NewDomain "contoso.com" -Verbose
    
    .EXAMPLE
    Import-Csv c:\scripts\FAPerms.csv | Import-ExchangeFullAccess -Domain "fabrikam.com" -NewDomain "contoso.com" -DontAutoMap -Verbose

    .NOTES
    General notes
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter()]
        [switch] $DontAutoMap,

        [Parameter()]
        [string] $Domain,

        [Parameter()]
        [string] $NewDomain,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
        $Row
    )
    begin {
        
        $CurrentErrorActionPref = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'

        if ($Domain -and (! $NewDomain)) {
            Write-Warning "Must use NewDomain parameter when specifying Domain parameter"
            break
        }
        if ($NewDomain -and (! $Domain)) {
            Write-Warning "Must use Domain parameter when specifying NewDomain parameter"
            break
        }

        $OutputPath = '.\'
        $LogFileName = $(get-date -Format yyyy-MM-dd_HH-mm-ss)
        $Log = Join-Path $OutputPath ($LogFileName + "-ImportExchange_FULLACCESS.csv")
        $headerstring = ("Identity" + "," + "AccessRights" + "," + "ObjectWithAccess" + "," + "DontAutoMap" + "," + "Message")
        Out-File -FilePath $Log -InputObject $headerstring -Encoding UTF8 -Append

    }
    process {
        foreach ($CurRow in $Row) {

            $Identity = $CurRow.PrimarySmtpAddress
            $ObjectWithAccess = $CurRow.ObjectWithAccess

            if ($Domain) {
                $ObjectWithAccess = $ObjectWithAccess | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }

            if ($Identity -and $ObjectWithAccess) {

                try {

                    $AddFullAccess = @{

                        Identity     = $Identity
                        AccessRights = "FullAccess"
                        User         = $ObjectWithAccess
                        Confirm      = $False
                        AutoMapping  = $DontAutoMap -eq $false
                        ErrorAction  = 'Stop'

                    }

                    Add-MailboxPermission @AddFullAccess

                    Write-Verbose "$Identity has given Full Access to `t $ObjectWithAccess"

                    $Identity + "," + 'FULLACCESS' + "," + $ObjectWithAccess + "," + $DontAutoMap + "," + 'SUCCESS' | 
                        Out-file $Log -Encoding UTF8 -Append

                }
                catch {

                    Write-Warning "$Identity Failed to give Full Access to `t $ObjectWithAccess"
                    $WhyFailed = $_.Exception.Message
                    
                    $Identity + "," + 'FULLACCESS' + "," + $ObjectWithAccess + "," + $DontAutoMap + "," + $WhyFailed | 
                        Out-file $Log -Encoding UTF8 -Append
                }
            }
            else {
                Write-Verbose "SKIPPED DUE TO MISSING INFO, Identity: $Identity or ObjectWithAccess: $ObjectWithAccess"
            }
        }
    }
    end {
        $ErrorActionPreference = $CurrentErrorActionPref
    }
}
