function Import-ExchangeSendAs { 
    <#
    .SYNOPSIS
    Import SendAs Permissions from a CSV via the pipeline

    .DESCRIPTION
    Import SendAs Permissions from a CSV via the pipeline
    Script expects Data Source to have 2 headers named, UserPrincipalName & ObjectWithAccess
    You can replace values in ObjectWithAccess with Domain, NewDomain parameters

    .PARAMETER Domain
    Find this domain in ObjectWithAccess and change it to value in NewDomain parameter

    .PARAMETER NewDomain
    ObjectWithAccess domain will be changed to this domain

    .PARAMETER Row
    Parameter description

    .EXAMPLE
    Import-Csv c:\scripts\SAPerms.csv | Import-ExchangeSendAs -Verbose
    
    .EXAMPLE
    Import-Csv c:\scripts\SAPerms.csv | Import-ExchangeSendAs -Domain "fabrikam.com" -NewDomain "contoso.com" -Verbose

    .NOTES
    General notes
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

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
        $Log = Join-Path $OutputPath ($LogFileName + "-ImportExchange_SendAs.csv")
        $headerstring = ("Identity" + "," + "AccessRights" + "," + "ObjectWithAccess" + "," + "Message")
        Out-File -FilePath $Log -InputObject $headerstring -Encoding UTF8 -Append

    }
    process {
        foreach ($CurRow in $Row) {

            $Identity = $CurRow.UserPrincipalName
            $ObjectWithAccess = $CurRow.ObjectWithAccess

            if ($Domain) {
                $ObjectWithAccess = $ObjectWithAccess | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }

            if ($Identity -and $ObjectWithAccess) {

                try {

                    $AddSendAs = @{

                        Identity     = $Identity
                        AccessRights = "SendAs"
                        Trustee      = $ObjectWithAccess
                        Confirm      = $False
                        ErrorAction  = 'Stop'

                    }

                    Add-RecipientPermission @AddSendAs

                    Write-Verbose "$Identity has given SendAs to `t $ObjectWithAccess"

                    $Identity + "," + 'SendAs' + "," + $ObjectWithAccess + "," + 'SUCCESS' | 
                        Out-file $Log -Encoding UTF8 -Append

                }
                catch {

                    Write-Warning "$Identity Failed to give SendAs to `t $ObjectWithAccess"
                    $WhyFailed = $_.Exception.Message
                    
                    $Identity + "," + 'SendAs' + "," + $ObjectWithAccess + "," + $WhyFailed | 
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
