function Import-ExchangeFolderPermission { 
    <#
    .SYNOPSIS
    Import Folder Permissions from a CSV via the pipeline

    .DESCRIPTION
    Import Folder Permissions from a CSV via the pipeline
    Script expects Data Source to have 3 headers named: Folder, User, DetailLevel
    You can replace values in Folder with Domain, NewDomain parameters

    .PARAMETER Domain
    Find this domain in Folder and change it to value in NewDomain parameter

    .PARAMETER NewDomain
    Folder domain will be changed to this domain

    .PARAMETER Row
    Parameter description

    .EXAMPLE
    Import-Csv c:\scripts\FolderPerms.csv | Import-ExchangeFolderPermission -Verbose
    
    .EXAMPLE
    Import-Csv c:\scripts\FolderPerms.csv | Import-ExchangeFolderPermission -Domain "fabrikam.com" -NewDomain "contoso.com" -Verbose

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
        $Log = Join-Path $OutputPath ($LogFileName + "-ImportExchange_FolderPerms.csv")
        $headerstring = ("Folder" + "," + "AccessRights" + "," + "User" + "," + "Message")
        Out-File -FilePath $Log -InputObject $headerstring -Encoding UTF8 -Append

    }
    process {
        foreach ($CurRow in $Row) {
            
            $Right = ""
            $Folder = $CurRow.Folder
            $User = $CurRow.User
            $Right = [String[]]($CurRow.DetailLevel -split ";" | ForEach-Object ToString)
            
            if ($Domain) {
                $User = $User | ForEach-Object {
                    $_ -replace ([Regex]::Escape($Domain), $NewDomain)
                }
            }

            if (($Folder -and $User -and $AccessRights) -and ($AccessRights -notlike "NT:S-*")) {

                try {
                    
                    $AddMailboxFolderPermission = @{

                        Identity     = $Folder
                        User         = $User
                        AccessRights = $Right
                        Confirm      = $False
                        ErrorAction  = 'Stop'
    
                    }
                        
                    Add-MailboxFolderPermission @AddMailboxFolderPermission

                    Write-Verbose "$Folder Access Rights $Right for User $User"

                    $Folder + "," + $Right + "," + $User + "," + 'SUCCESS' | 
                        Out-file $Log -Encoding UTF8 -Append
                }
                catch {

                    Write-Verbose "$Folder FAILED OR ALREADY EXITS Access Rights $Right for User $User"
                    $WhyFailed = $_.Exception.Message
                    
                    $Folder + "," + $Right + "," + $User + "," + $WhyFailed | 
                        Out-file $Log -Encoding UTF8 -Append
                }
            }
            else {
                Write-Verbose "SKIPPED DUE TO MISSING INFO, Folder: $Folder or AccessRights: $Right or User: $User"
            }
        }
    }
    end {
        $ErrorActionPreference = $CurrentErrorActionPref
    }
}
